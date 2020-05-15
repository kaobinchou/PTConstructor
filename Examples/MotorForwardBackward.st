PROGRAM MotorFB
  VAR_INPUT
    ForwardStart : BOOL := false;
    ReverseStart : BOOL := false;
    Stop : BOOL := false;
  END_VAR
  VAR_OUTPUT
    LatchedF : BOOL := false;
    ForwardContactor : BOOL := false;
    LatchedR : BOOL := false;
    ReverseContactor : BOOL := false;
  END_VAR
  VAR
    DelayFDN : BOOL := false;
    DelayRDN : BOOL := false;
    DelayF : TOF;
    DelayR : TOF;
  END_VAR

  LatchedF := ForwardStart AND ForwardStart AND NOT(Stop) OR NOT(LatchedR) AND (ForwardStart OR LatchedF) AND NOT(Stop);
  ForwardContactor := NOT(DelayFDN) AND LatchedF;
  DelayF(IN := LatchedF, PT := T#120ms);
  DelayFDN := DelayF.Q;
  LatchedR := NOT(LatchedF) AND (LatchedR OR ReverseStart) AND NOT(Stop) OR ReverseStart AND ReverseStart AND NOT(Stop);
  ReverseContactor := NOT(DelayRDN) AND LatchedR;
  DelayR(IN := LatchedR, PT := T#120ms);
  DelayRDN := DelayR.Q;
END_PROGRAM


CONFIGURATION Config0

  RESOURCE Res0 ON PLC
    TASK task0(INTERVAL := T#20ms,PRIORITY := 0);
    PROGRAM instance0 WITH task0 : MotorFB;
  END_RESOURCE
END_CONFIGURATION
