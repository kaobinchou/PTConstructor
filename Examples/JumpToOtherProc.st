PROGRAM JumpToOtherProc
  VAR_INPUT
    JumpLabel : BOOL := false;
    A : BOOL := false;
    B : BOOL := false;
    C : BOOL := false;
    Sensor : BOOL := false;
  END_VAR
  VAR_OUTPUT
    O0 : BOOL := false;
    O1 : BOOL := false;
    O2 : BOOL := false;
    O3 : BOOL := false;
  END_VAR
  VAR_IN_OUT
    Jump : BOOL;
  END_VAR

  Jump := JumpLabel;
  O0 := A;
  O1 := B;
  O2 := C;
  O3 := Sensor AND Jump;
END_PROGRAM


CONFIGURATION Config0

  RESOURCE Res0 ON PLC
    TASK task0(INTERVAL := T#20ms,PRIORITY := 0);
    PROGRAM instance0 WITH task0 : JumpToOtherProc;
  END_RESOURCE
END_CONFIGURATION
