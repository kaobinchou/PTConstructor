PROGRAM MixingDevice
  VAR_INPUT
    Start : BOOL := false;
    Stop : BOOL := false;
  END_VAR
  VAR_OUTPUT
    MasterCoil : BOOL := false;
  END_VAR
  VAR_INPUT
    MaterialA : BOOL := false;
    MaterialB : BOOL := false;
    LowLevel : BOOL := false;
  END_VAR
  VAR_OUTPUT
    InletValveA : BOOL := false;
    InletValveB : BOOL := false;
    AgitatorMotor : BOOL := false;
    OutletValve : BOOL := false;
  END_VAR
  VAR
    TimerMixDN : BOOL := false;
    TimerMix : TON;
  END_VAR

  MasterCoil := NOT(Stop) AND (MasterCoil OR Start);
  InletValveA := NOT(MaterialA) AND (InletValveA OR LowLevel OR Start) AND MasterCoil;
  InletValveB := NOT(MaterialB) AND (InletValveB OR MaterialA) AND MasterCoil;
  AgitatorMotor := NOT(TimerMixDN) AND (AgitatorMotor OR MaterialB) AND MasterCoil;
  TimerMix(IN := AgitatorMotor AND MasterCoil, PT := T#200ms);
  TimerMixDN := TimerMix.Q;
  OutletValve := NOT(LowLevel) AND TimerMixDN AND MasterCoil;
END_PROGRAM


CONFIGURATION Config0

  RESOURCE Res0 ON PLC
    TASK task0(INTERVAL := T#20ms,PRIORITY := 0);
    PROGRAM instance0 WITH task0 : MixingDevice;
  END_RESOURCE
END_CONFIGURATION
