PROGRAM ControlSprayPainting
  VAR_INPUT
    Start : BOOL := false;
    Stop : BOOL := false;
    Hanger : BOOL := false;
    PartDetection : BOOL := false;
  END_VAR
  VAR_OUTPUT
    MasterCoil : BOOL := false;
    Oven : BOOL := false;
    Spray : BOOL := false;
  END_VAR
  VAR
    BitShift : BYTE := 0;
    AND17_ENO : BOOL;
    AND17_OUT : BYTE;
    SHL13_ENO : BOOL;
    SHL13_OUT : BYTE;
    AND26_OUT : BYTE;
    GT28_OUT : BOOL;
  END_VAR

  MasterCoil := NOT(Stop) AND (MasterCoil OR Start);
  Oven := MasterCoil;
  AND17_OUT := AND(EN := PartDetection, IN1 := BitShift, IN2 := 1, ENO => AND17_ENO);
  IF AND17_ENO THEN
      BitShift := AND17_OUT;
  END_IF;
  SHL13_OUT := SHL(EN := Hanger, IN := BitShift, N := 1, ENO => SHL13_ENO);
  IF SHL13_ENO THEN
      BitShift := SHL13_OUT;
  END_IF;
  AND26_OUT := AND(BitShift, 4);
  GT28_OUT := GT(AND26_OUT, 0);
  Spray := GT28_OUT;
END_PROGRAM


CONFIGURATION Config0

  RESOURCE Res0 ON PLC
    TASK task0(INTERVAL := T#20ms,PRIORITY := 0);
    PROGRAM instance0 WITH task0 : ControlSprayPainting;
  END_RESOURCE
END_CONFIGURATION
