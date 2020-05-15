PROGRAM CleaningRinsingBottles
  VAR_INPUT
    Start : BOOL := false;
    Stop : BOOL := false;
    BottleEnter : BOOL := false;
    BottleLeave : BOOL := false;
    UpsideDown : BOOL := false;
  END_VAR
  VAR_OUTPUT
    MasterCoil : BOOL := false;
    ClipHold : BOOL := false;
    TurnBottleForward : BOOL := false;
    TurnBottleReverse : BOOL := false;
    WaterSupply : BOOL := false;
    ClipRelease : BOOL := false;
  END_VAR
  VAR
    TurnBottleTimeDN : BOOL := false;
    SprinkleWaterTimeDN : BOOL := false;
    LeaveBottleTimeDN : BOOL := false;
    TurnBottleTime : TON;
    SprinkleWaterTime : TON;
    LeaveBottleTime : TON;
  END_VAR

  MasterCoil := NOT(Stop) AND (MasterCoil OR Start);
  ClipHold := NOT(BottleLeave) AND (BottleEnter OR ClipHold) AND MasterCoil;
  TurnBottleTime(IN := ClipHold AND MasterCoil, PT := T#2000ms);
  TurnBottleTimeDN := TurnBottleTime.Q;
  TurnBottleForward := TurnBottleTimeDN AND MasterCoil;
  WaterSupply := NOT(SprinkleWaterTimeDN) AND (UpsideDown OR WaterSupply) AND TurnBottleForward AND MasterCoil;
  SprinkleWaterTime(IN := WaterSupply AND MasterCoil, PT := T#2000ms);
  SprinkleWaterTimeDN := SprinkleWaterTime.Q;
  TurnBottleReverse := NOT(BottleEnter) AND (BottleLeave OR TurnBottleReverse) AND MasterCoil;
  LeaveBottleTime(IN := TurnBottleReverse AND MasterCoil, PT := T#3000ms);
  LeaveBottleTimeDN := LeaveBottleTime.Q;
  ClipRelease := NOT(BottleEnter) AND LeaveBottleTimeDN AND MasterCoil;
END_PROGRAM


CONFIGURATION Config0

  RESOURCE Res0 ON PLC
    TASK task0(INTERVAL := T#20ms,PRIORITY := 0);
    PROGRAM instance0 WITH task0 : CleaningRinsingBottles;
  END_RESOURCE
END_CONFIGURATION
