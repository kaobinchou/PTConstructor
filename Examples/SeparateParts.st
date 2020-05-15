PROGRAM SeparateParts
  VAR_INPUT
    Start : BOOL := False;
    Stop : BOOL := False;
  END_VAR
  VAR_OUTPUT
    MasterCoil : BOOL := False;
  END_VAR
  VAR_INPUT
    DetectBigParts : BOOL := False;
  END_VAR
  VAR_OUTPUT
    GateSolenoidCoil : BOOL := False;
    TimerGateDN : BOOL := False;
  END_VAR
  VAR
    TimerGate : TON;
  END_VAR

  MasterCoil := NOT(Stop) AND (MasterCoil OR Start);
  GateSolenoidCoil := NOT(TimerGateDN) AND (DetectBigParts OR GateSolenoidCoil) AND MasterCoil;
  TimerGate(IN := GateSolenoidCoil AND MasterCoil, PT := T#20ms);
  TimerGateDN := TimerGate.Q;
END_PROGRAM


CONFIGURATION Config0

  RESOURCE Res0 ON PLC
    TASK task0(INTERVAL := T#20ms,PRIORITY := 0);
    PROGRAM instance0 WITH task0 : SeparateParts;
  END_RESOURCE
END_CONFIGURATION
