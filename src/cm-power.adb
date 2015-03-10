with POSIX; use POSIX;
with POSIX.Process_Primitives; use POSIX.Process_Primitives;
with POSIX.Process_Identification; use POSIX.Process_Identification;
with POSIX.IO;
with Ada.Exceptions; use Ada.Exceptions;

with CM.Debug;
with CM.Taint;
with Ada.Strings;
with Ada.Strings.Fixed;


package body CM.Power is
   procedure Activate_Power_Switch (The_Node : CM.Taint.Trusted_String;
                                    Command  : CM.Taint.Trusted_String;
                                    PDU      : Boolean;
                                    Sudo_User : CM.Taint.Trusted_String);

   function Strip_FQD (FQDN : String) return String;


   ---------------------------
   -- Activate_Power_Switch --
   ---------------------------

   procedure Activate_Power_Switch (The_Node : CM.Taint.Trusted_String;
                                    Command  : CM.Taint.Trusted_String;
                                    PDU      : Boolean;
                                    Sudo_User : CM.Taint.Trusted_String) is
      Args         : POSIX.POSIX_String_List;
      cmsh_Command : constant String := "device power "
                                      & (if PDU then "-p" else "-n") & " "
                                      & Strip_FQD (CM.Taint.Value (The_Node)) & " "
                                      & CM.Taint.Value (Command);
      Template     : Process_Template;
      PID          : Process_ID;
      Return_Value : Termination_Status;
      Trusted_User : constant String := CM.Taint.Value (Sudo_User);

   begin
      begin
         Debug.Log (cmsh_Command);
         if Trusted_User /= "" then
            Append (Args, "sudo");
            Append (Args, "-u");
            Append (Args, To_POSIX_String (Trusted_User));
         end if;
         Append (Args, "/cm/local/apps/cmd/bin/cmsh");
         Append (Args, "-c");
         Append (Args, To_POSIX_String (cmsh_Command));
         Open_Template (Template);
         Set_File_Action_To_Close (Template => Template,
                                   File     => POSIX.IO.Standard_Output);
         exception
         when others =>
            Debug.Log ("in cmsh setup:");
            raise;
      end;
      begin
         Start_Process (Child    => PID,
                        Template => Template,
                        Pathname => (if Trusted_User = "" then "/cm/local/apps/cmd/bin/cmsh"
                                     else "/usr/bin/sudo"),
                        Arg_List => Args);
      exception
         when others =>
            Debug.Log ("in cmsh start:");
            raise;
      end;
      begin
         Wait_For_Child_Process (Status => Return_Value, Child => PID);
      exception
         when others =>
            Debug.Log ("in cmsh wait:");
            raise;
      end;
      case Termination_Cause_Of (Return_Value) is
         when Exited =>
            case Exit_Status_Of (Return_Value) is
               when Normal_Exit => return;
               when Failed_Creation_Exit => raise CM_Error with "Failed to create cmsh process";
               when Unhandled_Exception_Exit => raise CM_Error with "Unhandled exception in cmsh";
               when others => raise CM_Error with "cmsh exited with status" & Exit_Status_Of (Return_Value)'Img;
            end case;
         when Terminated_By_Signal =>
            Debug.Log ("cmsh terminated by signal " & Termination_Signal_Of (Return_Value)'Img);
         when Stopped_By_Signal =>
            Debug.Log ("cmsh stopped");
      end case;
   exception
      when E : POSIX_Error =>
         raise CM_Error with "cmsh raised error when called with """
           & cmsh_Command & """:" & Exception_Information (E);
   end Activate_Power_Switch;

   procedure Poweron (What : CM.Taint.Trusted_String; PDU : Boolean := False; Sudo_User : CM.Taint.Trusted_String := CM.Taint.Implicit_Trust ("")) is
   begin
      Activate_Power_Switch (What, CM.Taint.Implicit_Trust ("on"), PDU, Sudo_User);
   end Poweron;

   procedure Poweroff (What : CM.Taint.Trusted_String; PDU : Boolean := False; Sudo_User : CM.Taint.Trusted_String := CM.Taint.Implicit_Trust ("")) is
   begin
      Activate_Power_Switch (What, CM.Taint.Implicit_Trust ("off"), PDU, Sudo_User);
   end Poweroff;

   procedure Powercycle (What : CM.Taint.Trusted_String; PDU : Boolean := False; Sudo_User : CM.Taint.Trusted_String := CM.Taint.Implicit_Trust ("")) is
   begin
      Activate_Power_Switch (What, CM.Taint.Implicit_Trust ("reset"), PDU, Sudo_User);
   end Powercycle;

   function Strip_FQD (FQDN : String) return String is
      Dot : Natural := Ada.Strings.Fixed.Index (FQDN, ".");
   begin
      if Dot /= 0 then
         return FQDN (FQDN'First .. Dot - 1);
      else
         return FQDN;
      end if;
   end Strip_FQD;

end CM.Power;
