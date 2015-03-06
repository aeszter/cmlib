with CM.Taint;

package CM.Power is
   procedure Poweron (What : CM.Taint.Trusted_String; PDU : Boolean := False);
   procedure Poweroff (What : CM.Taint.Trusted_String; PDU : Boolean := False);
   procedure Powercycle (What : CM.Taint.Trusted_String; PDU : Boolean := False);

   CM_Error : exception;
end CM.Power;
