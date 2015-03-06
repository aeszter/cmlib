package CM is
   procedure Poweron (What : String; PDU : Boolean := False);
   procedure Poweroff (What : String; PDU : Boolean := False);
   procedure Powercycle (What : String; PDU : Boolean := False);

   CM_Error : exception;
end CM;
