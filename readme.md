<!-- Badges -->
<p>
  <img src="https://img.shields.io/github/last-commit/Erfun-ABD/Elevator-State-machine" alt="last update" />
</p>

<!-- About the Project -->
## About the Project

### Features

- [x] 4 floors
- [x] `AC`
- [x] `DISP` floor number
- [x] `Open`/Close door after 3 clock cycles
- [x] prioritize requests depending on moving direction
- [x] asynch RESET


### Input Signals

- call buttons on elevator panel
  - `F1 F2 F3 F4`
- up/down buttons on each floor
  - `U1 U2 U3 U4`
  - `D1 D2 D3 D4`
- floor sensors
  - `S1 S2 S3 S4`

## Implementation

### Request Handling

If a call button is pressed, the elevator will store the request in a `register` till it reaches the floor. Requests will be cleared with the `clr` signal of `register`.
```systemverilog 
register regF(.in(F), .clr(clrF), .out(F_));
```

### Variables

```systemverilog
wire B1, B2, B3, B4, NB;
assign B1 = F1_ | U1_ | D1_;
assign B2 = F2_ | U2_ | D2_;
assign B3 = F3_ | U3_ | D3_;
assign B4 = F4_ | U4_ | D4_;
assign NB = ~(B1 | B2 | B3 | B4);
```
`B1`-`B4` is activated if there isn't any request to the floor. `NB` is activated if there is no request at all.

### State Machine

<div align="center"> 
  <img src="Elevator State diagram.png" alt="screenshot" />
</div>

- `AC`
  - `0: up`
  - `1: down`
  - `2: stop`
- `Open`
  - `0: close door`
  - `1: open door`

### Time Handling
  
  ```systemverilog
  always @(posedge CLK) begin
    if (Open == 1)
        counter <= counter + 1;
    else
        counter <= 0;
  end
  ```
  After the door is opened, the `counter` will start counting. When it reaches 3, the door will be closed.

  ```systemverilog  
  wait(counter == 3);
  ```