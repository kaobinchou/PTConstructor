PROGRAM BottleFillingSystem
  VAR_INPUT
    Start : BOOL;
    Stop : BOOL;
  END_VAR
  VAR_OUTPUT
    MasterCoil : BOOL;
  END_VAR
  VAR_INPUT
    Input : UDINT;
  END_VAR
  VAR
    DivResult : UDINT;
    MulResult : UDINT;
  END_VAR
  VAR_OUTPUT
    IPConverter : UDINT;
  END_VAR
  VAR
    DIV9_ENO : BOOL;
    DIV9_OUT : UDINT;
    MUL15_ENO : BOOL;
    MUL15_OUT : UDINT;
    MOVE21_ENO : BOOL;
    MOVE21_OUT : UDINT;
  END_VAR

  MasterCoil := NOT(Stop) AND (MasterCoil OR Start);
  DIV9_OUT := DIV(EN := MasterCoil, IN1 := Input, IN2 := 1000, ENO => DIV9_ENO);
  IF DIV9_ENO THEN
      DivResult := DIV9_OUT;
  END_IF;
  MUL15_OUT := MUL(EN := MasterCoil, IN1 := DivResult, IN2 := 902, ENO => MUL15_ENO);
  IF MUL15_ENO THEN
      MulResult := MUL15_OUT;
  END_IF;
  MOVE21_OUT := MOVE(EN := MasterCoil, IN := MulResult, ENO => MOVE21_ENO);
  IF MOVE21_ENO THEN
      IPConverter := MOVE21_OUT;
  END_IF;
END_PROGRAM


CONFIGURATION Config0

  RESOURCE Res0 ON PLC
    TASK task0(INTERVAL := T#20ms,PRIORITY := 0);
    PROGRAM instance0 WITH task0 : BottleFillingSystem;
  END_RESOURCE
END_CONFIGURATION
