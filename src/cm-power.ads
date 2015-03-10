with CM.Taint;

package CM.Power is
   procedure Poweron (What : CM.Taint.Trusted_String;
                      PDU       : Boolean := False;
                      Sudo_User : CM.Taint.Trusted_String := CM.Taint.Implicit_Trust (""));
   procedure Poweroff (What : CM.Taint.Trusted_String;
                       PDU       : Boolean := False;
                       Sudo_User : CM.Taint.Trusted_String := CM.Taint.Implicit_Trust (""));
   procedure Powercycle (What : CM.Taint.Trusted_String;
                         PDU       : Boolean := False;
                         Sudo_User : CM.Taint.Trusted_String := CM.Taint.Implicit_Trust (""));

   CM_Error : exception;
end CM.Power;
