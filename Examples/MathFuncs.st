PROGRAM MathFuncs
  VAR_INPUT
    InputToAdd : BOOL;
    InputToSub : BOOL;
    InputToMul : BOOL;
    InputToDiv : BOOL;
    InputToSqrt : BOOL;
    InputToNeg : BOOL;
    InputNum0 : DINT;
    InputNum1 : DINT;
    InputNum2 : DINT;
    InputNum3 : DINT;
    InputNum4 : DINT;
    InputNum5 : DINT;
    InputNum6 : DINT;
    InputNum7 : DINT;
    InputNum8 : REAL;
  END_VAR
  VAR_OUTPUT
    Output0 : DINT;
    Output1 : REAL;
  END_VAR
  VAR
    ADD3_ENO : BOOL;
    ADD3_OUT : DINT;
    SUB10_ENO : BOOL;
    SUB10_OUT : DINT;
    MUL17_ENO : BOOL;
    MUL17_OUT : DINT;
    DIV24_ENO : BOOL;
    DIV24_OUT : DINT;
    SQRT31_ENO : BOOL;
    SQRT31_OUT : REAL;
  END_VAR

  ADD3_OUT := ADD(EN := InputToAdd, IN1 := InputNum0, IN2 := InputNum1, ENO => ADD3_ENO);
  IF ADD3_ENO THEN
      Output0 := ADD3_OUT;
  END_IF;
  SUB10_OUT := SUB(EN := InputToSub, IN1 := InputNum2, IN2 := InputNum3, ENO => SUB10_ENO);
  IF SUB10_ENO THEN
      Output0 := SUB10_OUT;
  END_IF;
  MUL17_OUT := MUL(EN := InputToMul, IN1 := InputNum4, IN2 := InputNum5, ENO => MUL17_ENO);
  IF MUL17_ENO THEN
      Output0 := MUL17_OUT;
  END_IF;
  DIV24_OUT := DIV(EN := InputToDiv, IN1 := InputNum6, IN2 := InputNum7, ENO => DIV24_ENO);
  IF DIV24_ENO THEN
      Output0 := DIV24_OUT;
  END_IF;
  SQRT31_OUT := SQRT(EN := InputToSqrt, IN := InputNum8, ENO => SQRT31_ENO);
  IF SQRT31_ENO THEN
      Output1 := SQRT31_OUT;
  END_IF;
END_PROGRAM


CONFIGURATION Config0

  RESOURCE Res0 ON PLC
    TASK task0(INTERVAL := T#20ms,PRIORITY := 0);
    PROGRAM instance0 WITH task0 : MathFuncs;
  END_RESOURCE
END_CONFIGURATION
