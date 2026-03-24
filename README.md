# Mini Router Design Specification

**Document Version:** 1.0  
**Status:** Released  
**Author:** Design Team  
**Date:** 2026-03-22

---

## 1. Overview

The `mini_router_top` is a 4-input × 2-output AXI-Stream packet router.  
It receives AXI-Stream packets from 4 upstream input ports and routes them to one of 2 downstream output ports based on the `tdest` signal.  
Each input port has an internal FIFO for buffering. Arbitration between competing input ports is performed independently per output port using a Round-Robin algorithm.

---

## 2. Block Diagram

```
![mini_router_top Block Diagram](System_Architect/mini_router_architecture.png)
```

---

## 3. Parameters

| Parameter | Default | Description                  |
|-----------|---------|------------------------------|
| D_WIDTH   | 8       | Data width (bits)            |
| DEPTH     | 4       | FIFO depth (entries)         |

---

## 4. Port List

### 4.1 Global Signals

| Port   | Direction | Width | Description        |
|--------|-----------|-------|--------------------|
| clk    | input     | 1     | System clock       |
| rst_n  | input     | 1     | Active-low reset   |

### 4.2 Slave Side (Upstream → mini_router)

| Port       | Direction | Width     | Description                          |
|------------|-----------|-----------|--------------------------------------|
| s_tdata_0  | input     | D_WIDTH   | Input data, port 0                   |
| s_tdata_1  | input     | D_WIDTH   | Input data, port 1                   |
| s_tdata_2  | input     | D_WIDTH   | Input data, port 2                   |
| s_tdata_3  | input     | D_WIDTH   | Input data, port 3                   |
| s_tvalid   | input     | 4         | Valid signal per input port          |
| s_tlast    | input     | 4         | Packet end indicator per input port  |
| s_tdest    | input     | 4         | Destination port select (1-bit each) |
| s_tready   | output    | 4         | Backpressure to upstream             |

> `s_tdest[n] = 0` → route to output port 0  
> `s_tdest[n] = 1` → route to output port 1

### 4.3 Master Side (mini_router → Downstream)

| Port      | Direction | Width   | Description                        |
|-----------|-----------|---------|------------------------------------|
| m_tdata_0 | output    | D_WIDTH | Output data, port 0                |
| m_tdata_1 | output    | D_WIDTH | Output data, port 1                |
| m_tvalid  | output    | 2       | Valid signal per output port       |
| m_tlast   | output    | 2       | Packet end indicator per output    |
| m_tready  | input     | 2       | Backpressure from downstream       |

---

## 5. Sub-module Descriptions

### 5.1 sync_fifo (×4)

- One FIFO per input port, parameterized by D_WIDTH and DEPTH.
- Write enable is gated by `s_tvalid & ~full` (no write when full).
- Read enable is driven by arbitration grant (`grant0 | grant1`).
- `s_tready[n] = ~fifo_full[n]` (AXI-S backpressure).

### 5.2 route_ctrl

- Generates `req0[3:0]` and `req1[3:0]` from `tvalid` and `tdest`.
  - `req0[n] = tvalid[n] && (tdest[n] == 0)`
  - `req1[n] = tvalid[n] && (tdest[n] == 1)`
- Contains two independent `arbiter_rr` instances, one per output port.
- Passes `m_tready[0]` and `m_tready[1]` as `tready` to each arbiter for stall control.

### 5.3 arbiter_rr

- Round-Robin arbitration among 4 requesters.
- `last_grant` register tracks the most recently granted port.
- `last_grant` updates only when `tlast && tready` (packet boundary, no stall).
- When `tready = 0`: grant is held (stall). When `tready = 1`: grant updates.
- Output `grant[3:0]` is one-hot encoded.

### 5.4 crossbar (4×2)

- Pure combinational switch.
- Selects input data/valid/last based on `grant0` and `grant1`.
- Independently routes to output port 0 and output port 1.
- No registers; zero latency.

---

## 6. Functional Description

### 6.1 Normal Routing

1. Upstream sends packet with `s_tvalid[n]=1`, `s_tdest[n]`, `s_tlast[n]`.
2. Data is written into `sync_fifo[n]` if not full.
3. `route_ctrl` asserts the corresponding `req` based on `tdest`.
4. `arbiter_rr` grants one requester per output port (Round-Robin).
5. `crossbar` routes FIFO output data to the granted output port.
6. Packet ends when `tlast` is asserted; arbiter updates `last_grant`.

### 6.2 Backpressure Handling

- **Upstream backpressure:** `s_tready[n] = ~fifo_full[n]`. Upstream must stop sending when `s_tready=0`.
- **Downstream backpressure:** `m_tready[n]=0` stalls the corresponding arbiter. Grant is held; `last_grant` does not update until `tlast && tready`.

### 6.3 Contention

- When multiple input ports target the same output port simultaneously, `arbiter_rr` grants one at a time in Round-Robin order.
- The losing ports' requests remain pending until the current packet ends (`tlast`).

### 6.4 Reset Behavior

- All registers reset to 0 on `rst_n=0` (active-low).
- `last_grant`, `grant`, `wptr`, `rptr`, `dout` all initialize to 0.

---

## 7. Timing

- **Clock:** Single clock domain.
- **FIFO write latency:** Data appears in FIFO on the next cycle after `wr_en`.
- **FIFO read latency:** `dout` updates 1 cycle after `rd_en`.
- **Arbitration latency:** `grant` is a registered output; 1-cycle latency from `req` change.
- **Crossbar latency:** Combinational; 0 cycles.
- **End-to-end latency (min):** 2 cycles (FIFO write → FIFO read → crossbar output).

---

## 8. Known Limitations / Out of Scope

- `s_tdest` is sampled at write time but routing uses the stored FIFO data's destination implicitly via `s_tdest` passed directly to `route_ctrl`. FIFO does not store `tdest`; `tdest` must remain stable per packet.
- No support for multicast (one packet to both outputs simultaneously).
- No packet ordering guarantee across different input ports targeting the same output.
- FIFO overflow protection: write is suppressed when full, but no error flag is exposed at top level.
- No QoS or priority mechanism beyond Round-Robin.