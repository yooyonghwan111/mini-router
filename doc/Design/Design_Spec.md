# Mini Router Design Specification

**Document Version:** 1.1  
**Status:** Released  
**Author:** Design Team  
**Date:** 2026-04-04

---

## 1. Overview

The `mini_router_top` is a 4-input × 2-output AXI-Stream packet router.  
It receives AXI-Stream packets from 4 upstream input ports and routes them to one of 2 downstream output ports based on the `tdest` signal.  
Each input port has an internal FIFO for buffering. Arbitration between competing input ports is performed independently per output port using a Round-Robin algorithm.

---

## 2. Block Diagram

![mini_router_top Block Diagram](../System_Architect/mini_router_architecture.png)

---

## 3. Parameters

| Parameter   | Default | Description                              |
|-------------|---------|------------------------------------------|
| D_WIDTH     | 8       | Data width (bits)                        |
| FIFO_DEPTH  | 4       | FIFO depth (entries)                     |
| FIFO_WIDTH  | D_WIDTH + 4 | Internal FIFO word width: {tdata, tid, tdest, tlast} |

---

## 4. Port List

### 4.1 Global Signals

| Port   | Direction | Width | Description        |
|--------|-----------|-------|--------------------|
| clk    | input     | 1     | System clock       |
| rst_n  | input     | 1     | Active-low reset   |

### 4.2 Slave Side (Upstream → mini_router)

| Port        | Direction | Width   | Description                          |
|-------------|-----------|---------|--------------------------------------|
| s_tdata_0~3 | input     | D_WIDTH | Input data, port 0~3                 |
| s_tid_0~3   | input     | 2       | Transaction ID per input port        |
| s_tdest_0~3 | input     | 1       | Destination port select per port     |
| s_tlast_0~3 | input     | 1       | Packet end indicator per input port  |
| s_tvalid_0~3| input     | 1       | Valid signal per input port          |
| s_tready_0~3| output    | 1       | Backpressure to upstream             |

> `s_tdest[n] = 0` → route to output port 0  
> `s_tdest[n] = 1` → route to output port 1

### 4.3 Master Side (mini_router → Downstream)

| Port        | Direction | Width   | Description                        |
|-------------|-----------|---------|------------------------------------|
| m_tdata_0~1 | output    | D_WIDTH | Output data, port 0~1             |
| m_tid_0~1   | output    | 2       | Transaction ID per output port     |
| m_tlast_0~1 | output    | 1       | Packet end indicator per output    |
| m_tvalid_0~1| output    | 1       | Valid signal per output port       |
| m_tready_0~1| input     | 1       | Backpressure from downstream       |

---

## 5. Internal Signal Structure

### 5.1 FIFO Packed Format

All signals entering the FIFO are packed into a single word:

```
FIFO word = {tdata[D_WIDTH-1:0], tid[1:0], tdest[0], tlast[0]}
           = [FIFO_WIDTH-1:4]    [3:2]      [1]        [0]
```

- `FIFO_WIDTH = D_WIDTH + 4` (tdata + tid(2) + tdest(1) + tlast(1))

---

## 6. Sub-module Descriptions

### 6.1 sync_fifo (×4)

- One FIFO per input port, parameterized by `FIFO_DEPTH` and `FIFO_WIDTH`.
- **FWFT (First Word Fall Through):** Output is combinational (`assign tdata_out = fifo[rptr]`). No read latency.
- Write enable: `s_tvalid & s_tready` (= `s_tvalid & ~fifo_full`)
- Read enable: `(grant_0[n] && m_tready_0) || (grant_1[n] && m_tready_1)` (beat-level)
- `s_tready[n] = ~fifo_full[n]` (AXI-S backpressure)
- Full condition: `wptr[MSB] != rptr[MSB] && wptr[MSB-1:0] == rptr[MSB-1:0]`
- Empty condition: `wptr == rptr`

### 6.2 route_ctrl

- Generates `req_0[3:0]` and `req_1[3:0]` from FIFO empty flags and `tdest`.
  - `req_0[n] = ~fifo_empty[n] && (fifo_dout[n][1] == 0)`  (tdest=0)
  - `req_1[n] = ~fifo_empty[n] && (fifo_dout[n][1] == 1)`  (tdest=1)
- Contains two independent `arbiter_rr` instances, one per output port.
- Passes `m_tready_0`, `m_tready_1` and `m_tlast_0`, `m_tlast_1` to each arbiter.

### 6.3 arbiter_rr

- Round-Robin arbitration among 4 requesters.
- Output `grant[3:0]` is one-hot encoded.
- Grant updates at **packet boundary** only: `ready && last` condition.
- When no request exists after packet end: `grant <= 4'b0000`.
- **Self-reassignment prevention:** Current grant port excluded from RR candidate check.
- When `ready = 0`: grant is held (stall).

### 6.4 crossbar (4×2)

- Pure combinational MUX-based switch.
- Selects `tdata`, `tid`, `tdest`, `tlast`, `tvalid` from FIFO outputs based on `grant_0` and `grant_1`.
- Independently routes to output port 0 and output port 1.
- No registers; zero latency.

---

## 7. Functional Description

### 7.1 Normal Routing

1. Upstream sends packet: `s_tvalid[n]=1`, `s_tdest[n]`, `s_tlast[n]`, `s_tid[n]`.
2. Data is packed as `{tdata, tid, tdest, tlast}` and written into `sync_fifo[n]` if not full.
3. `route_ctrl` generates `req` based on `~fifo_empty` and stored `tdest`.
4. `arbiter_rr` grants one requester per output port in Round-Robin order.
5. `crossbar` routes FIFO output data to the granted output port.
6. Packet ends when `tlast` is asserted; arbiter updates to next RR candidate.

### 7.2 Backpressure Handling

- **Upstream backpressure:** `s_tready[n] = ~fifo_full[n]`. Upstream must stop sending when `s_tready=0`.
- **Downstream backpressure:** `m_tready[n]=0` stalls the arbiter. Grant is held; does not update until `tlast && tready`.
- `rd_en` is gated by `m_tready`, so FIFO read is suppressed during downstream stall.

### 7.3 Contention

- When multiple input ports target the same output port simultaneously, `arbiter_rr` grants one at a time in Round-Robin order.
- Losing ports remain pending until the current packet ends (`tlast`).
- Both output port arbiters operate independently.

### 7.4 Reset Behavior

- Active-low reset (`rst_n=0`).
- `grant`, `wptr`, `rptr` all reset to 0.
- FIFO output (`tdata_out`) is combinational from reset state → output is 0 after reset.

---

## 8. Timing

| Path                        | Latency     | Note                              |
|-----------------------------|-------------|-----------------------------------|
| FIFO write                  | 1 cycle     | Data stored on next posedge       |
| FIFO read (FWFT)            | 0 cycle     | Combinational output              |
| Arbitration (arbiter_rr)    | 1 cycle     | Registered grant output           |
| Crossbar                    | 0 cycle     | Pure combinational                |
| End-to-end (min)            | 1 cycle     | FIFO write → FWFT out → crossbar  |

---

## 9. Known Limitations / Out of Scope

- `tdest` is stored in FIFO as part of packed word. Must remain stable within a packet (per beat).
- `tid` is stored in FIFO but contention scenarios are limited to one packet per port sequentially (TID-based interleaving not supported).
- No support for multicast (one packet to both outputs simultaneously).
- No packet ordering guarantee across different input ports targeting the same output.
- FIFO overflow protection: write is suppressed when full, but no error flag is exposed at top level.
- No QoS or priority mechanism beyond Round-Robin.
- `m_dest_0`, `m_dest_1` (crossbar outputs) are not connected at top level.
