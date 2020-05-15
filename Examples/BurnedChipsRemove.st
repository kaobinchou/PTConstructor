PROGRAM BurnedChipsRemove
  VAR_INPUT
    Start : BOOL := false;
    Stop : BOOL := false;
  END_VAR
  VAR_OUTPUT
    MasterCoil : BOOL := false;
    Conveyor : BOOL := false;
    LightSource : BOOL := false;
  END_VAR
  VAR_INPUT
    LightDependentResistors1 : BOOL;
    LightDependentResistors2 : BOOL;
  END_VAR
  VAR
    BitLatching1 : BOOL;
    BitLatching2 : BOOL;
  END_VAR
  VAR_OUTPUT
    Blowers1 : BOOL;
    Blowers2 : BOOL;
  END_VAR
  VAR
    TimerToActivateBlowerDN : BOOL := false;
    TimerToActivateBlower : TON;
  END_VAR

  MasterCoil := NOT(Stop) AND (MasterCoil OR Start);
  Conveyor := MasterCoil;
  LightSource := MasterCoil;
  BitLatching1 := NOT(TimerToActivateBlowerDN) AND (BitLatching1 OR LightDependentResistors1);
  BitLatching2 := NOT(TimerToActivateBlowerDN) AND (BitLatching2 OR LightDependentResistors2);
  TimerToActivateBlower(IN := (BitLatching1 OR BitLatching2) AND MasterCoil, PT := T#10ms);
  TimerToActivateBlowerDN := TimerToActivateBlower.Q;
  Blowers1 := TimerToActivateBlowerDN AND BitLatching1 AND MasterCoil;
  Blowers2 := TimerToActivateBlowerDN AND BitLatching2 AND MasterCoil;
END_PROGRAM


CONFIGURATION Config0

  RESOURCE Res0 ON PLC
    TASK task0(INTERVAL := T#20ms,PRIORITY := 0);
    PROGRAM instance0 WITH task0 : BurnedChipsRemove;
  END_RESOURCE
END_CONFIGURATION
