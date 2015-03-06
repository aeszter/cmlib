with POSIX; use POSIX;
with POSIX.Process_Primitives; use POSIX.Process_Primitives;
with POSIX.Process_Identification; use POSIX.Process_Identification;
with POSIX.IO;
with Ada.Exceptions; use Ada.Exceptions;

with CM.Debug;


package body CM is
   procedure Activate_Power_Switch (The_Node : String;
                                    Command  : String;
                                    PDU      : Boolean);


   ---------------------------
   -- Activate_Power_Switch --
   ---------------------------

   procedure Activate_Power_Switch (The_Node : String;
                                    Command  : String;
                                    PDU      : Boolean) is
      Args         : POSIX.POSIX_String_List;
      cmsh_Command : constant String := "device power "
                                      & (if PDU then "-p" else "-n") & " "
                                      & The_Node & " " & Command;
      Template     : Process_Template;
      PID          : Process_ID;
      Return_Value : Termination_Status;

   begin
      begin
         Debug.Log (cmsh_Command);
         Append (Args, "cmsh");
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
         Start_Process_Search (Child    => PID,
                               Template => Template,
                               Filename => "cmsh",
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

   procedure Poweron (What : String; PDU : Boolean := False) is
   begin
      Activate_Power_Switch (What, "on", PDU);
   end Poweron;

   procedure Poweroff (What : String; PDU : Boolean := False) is
   begin
      Activate_Power_Switch (What, "off", PDU);
   end Poweroff;

   procedure Powercycle (What : String; PDU : Boolean := False) is
   begin
      Activate_Power_Switch (What, "reset", PDU);
   end Powercycle;

end CM;
