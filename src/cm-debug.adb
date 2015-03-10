package body CM.Debug is

   procedure Initialize (Output_Procedure : Callback) is
   begin
      Output := Output_Procedure;
   end Initialize;

   procedure Log (Message : String) is
   begin
      Output ("CMlib: " & Message);
   end Log;

end CM.Debug;
