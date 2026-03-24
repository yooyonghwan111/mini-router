## SVA Assertion Items

### Source: AMBA AXI-Stream Protocol Spec (IHI0051B)

#### 1. Handshake Rules
- [p.2-18] TVALID once asserted, must remain asserted until handshake
- [p.2-18] Transmitter must not wait for TREADY before asserting TVALID  
  => Guaranteed by TB driver, not SVA         
    (SVA cannot distinguish between "waiting for TREADY" and "no data to send")         
- [p.2-18] TDATA must remain stable while TVALID is asserted

#### 2. Reset Rules  
- [p.2-28] During reset, TVALID must be driven LOW

#### 3. Packet Rules
- [p.2-26] Number of TLAST assertions must be preserved
