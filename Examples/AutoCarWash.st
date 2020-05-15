PROGRAM AutoCarWash
  VAR_INPUT
    Master_Start : BOOL := false;
    Car_Detection : BOOL := false;
    Limit_Switch : BOOL := false;
    Master_Stop : BOOL := false;
  END_VAR
  VAR_OUTPUT
    Master_Coil : BOOL := false;
    Soap_Sprinkler : BOOL := false;
    Washer : BOOL := false;
    Conveyor : BOOL := false;
    Dryer : BOOL := false;
  END_VAR
  VAR
    SoapingTimeDN : BOOL := false;
    WashingTimeDN : BOOL := false;
    DryingTimeDN : BOOL := false;
    SoapingTime : TON;
    WashingTime : TON;
    DryingTime : TON;
  END_VAR

  Master_Coil := NOT(Master_Stop) AND (Master_Coil OR Master_Start);
  Soap_Sprinkler := NOT(SoapingTimeDN) AND Car_Detection AND Master_Coil;
  SoapingTime(IN := Car_Detection AND Master_Coil, PT := T#200ms);
  SoapingTimeDN := SoapingTime.Q;
  Washer := NOT(WashingTimeDN) AND SoapingTimeDN AND Master_Coil;
  WashingTime(IN := (Dryer OR SoapingTimeDN) AND Master_Coil, PT := T#250ms);
  WashingTimeDN := WashingTime.Q;
  Conveyor := NOT(Limit_Switch) AND WashingTimeDN AND Master_Coil;
  Dryer := NOT(DryingTimeDN) AND WashingTimeDN AND Master_Coil;
  DryingTime(IN := (Dryer OR WashingTimeDN) AND Master_Coil, PT := T#100ms);
  DryingTimeDN := DryingTime.Q;
END_PROGRAM


CONFIGURATION Config0

  RESOURCE Res0 ON PLC
    TASK task0(INTERVAL := T#20ms,PRIORITY := 0);
    PROGRAM instance0 WITH task0 : AutoCarWash;
  END_RESOURCE
END_CONFIGURATION
