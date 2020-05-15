PROGRAM QualityControl
  VAR_INPUT
    Start : BOOL;
    Stop : BOOL;
    Detector : BOOL;
  END_VAR
  VAR
    LatchingCoil : BOOL;
  END_VAR
  VAR_OUTPUT
    ConveyorMotors : BOOL;
    OperateGate : BOOL;
  END_VAR
  VAR
    CounterDN : BOOL;
    TimerDN : BOOL;
    Counter : CTU;
    Timer : TON;
    R_TRIG1 : R_TRIG;
  END_VAR

  LatchingCoil := NOT(Stop) AND (LatchingCoil OR Start);
  ConveyorMotors := LatchingCoil;
  R_TRIG1(CLK := Detector AND LatchingCoil);
  Counter(CU := R_TRIG1.Q, R := TimerDN, PV := 1000);
  CounterDN := Counter.Q;
  OperateGate := CounterDN AND LatchingCoil;
  Timer(IN := CounterDN AND LatchingCoil, PT := T#20ms);
  TimerDN := Timer.Q;
END_PROGRAM


CONFIGURATION Config0

  RESOURCE Res0 ON PLC
    TASK task0(INTERVAL := T#20ms,PRIORITY := 0);
    PROGRAM instance0 WITH task0 : QualityControl;
  END_RESOURCE
END_CONFIGURATION
