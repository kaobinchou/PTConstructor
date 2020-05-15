PROGRAM CountPackParts
  VAR_INPUT
    Start : BOOL := false;
    Stop : BOOL := false;
    PartDetection : BOOL := false;
    BoxDetection : BOOL := false;
  END_VAR
  VAR_OUTPUT
    LatchingBit : BOOL := false;
    LatchingMotor : BOOL := false;
    ConveyorBelt1 : BOOL := false;
    ConveyorBelt2 : BOOL := false;
  END_VAR
  VAR
    StopConveyorTimeDN : BOOL := false;
    PartCounterDN : BOOL := false;
    PartCounter : CTU;
    StopConveyorTime : TON;
    R_TRIG1 : R_TRIG;
  END_VAR

  LatchingBit := NOT(Stop) AND (LatchingBit OR Start);
  ConveyorBelt1 := NOT(StopConveyorTimeDN) AND (BoxDetection OR ConveyorBelt1) AND LatchingBit;
  R_TRIG1(CLK := PartDetection AND LatchingBit);
  PartCounter(CU := R_TRIG1.Q, R := PartCounterDN, PV := 5);
  PartCounterDN := PartCounter.Q;
  StopConveyorTime(IN := LatchingMotor AND LatchingBit, PT := T#2000ms);
  StopConveyorTimeDN := StopConveyorTime.Q;
  LatchingMotor := NOT(StopConveyorTimeDN) AND (LatchingMotor OR PartCounterDN) AND LatchingBit;
  ConveyorBelt2 := NOT(BoxDetection) AND (ConveyorBelt2 OR PartCounterDN) AND LatchingBit;
END_PROGRAM


CONFIGURATION Config0

  RESOURCE Res0 ON PLC
    TASK task0(INTERVAL := T#20ms,PRIORITY := 0);
    PROGRAM instance0 WITH task0 : CountPackParts;
  END_RESOURCE
END_CONFIGURATION
