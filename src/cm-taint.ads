package CM.Taint is

   --  data of type Trusted_String can be passed as parameters to external programs
   type Trusted_String (<>) is private;

   function "&" (Left, Right : Trusted_String) return Trusted_String;

   --  Extract the string value from a trusted string
   function Value (S : Trusted_String) return String;

   --  convert untrusted user data to a trusted string by removing/replacing
   --  any offending characters
   function Sanitise (S : String) return Trusted_String;

   --  convert an implicitly trusted String to a Trusted_String;
   --  Never!! pass untrusted user data to this function.
   --  It is meant for program-internal data only.
   function Implicit_Trust (S : String) return Trusted_String;


private
   type Trusted_String is new String;
end CM.Taint;
