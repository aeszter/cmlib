package CM.Debug is
   type Callback is access procedure (Message : String);
   procedure Log (Message : String);
   procedure Initialize (Output_Procedure : Callback);
private
   Output : Callback;
end CM.Debug;
