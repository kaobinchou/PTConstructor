PROGRAM DrillingParts
  VAR_INPUT
    Start : BOOL := false;
    Stop : BOOL := false;
  END_VAR
  VAR_OUTPUT
    MasterCoil : BOOL := false;
    ClampingDevice : BOOL := false;
    DrillingMotor : BOOL := false;
    MotorDown : BOOL := false;
    MotorUp : BOOL := false;
  END_VAR
  VAR_INPUT
    ObjectDetector : BOOL := false;
    LowerLimit : BOOL := false;
    UpperLimit : BOOL := false;
  END_VAR

  MasterCoil := NOT(Stop) AND (MasterCoil OR Start);
  ClampingDevice := NOT(LowerLimit) AND (NOT(UpperLimit) OR ObjectDetector) AND (DrillingMotor OR ObjectDetector) AND MasterCoil;
  DrillingMotor := (NOT(UpperLimit) OR ObjectDetector) AND (DrillingMotor OR ObjectDetector) AND MasterCoil;
  MotorDown := NOT(LowerLimit) AND (NOT(UpperLimit) OR ObjectDetector) AND (DrillingMotor OR ObjectDetector) AND MasterCoil;
  MotorUp := NOT(UpperLimit) AND (LowerLimit OR MotorUp) AND MasterCoil;
END_PROGRAM


CONFIGURATION Config0

  RESOURCE Res0 ON PLC
    TASK task0(INTERVAL := T#20ms,PRIORITY := 0);
    PROGRAM instance0 WITH task0 : DrillingParts;
  END_RESOURCE
END_CONFIGURATION
