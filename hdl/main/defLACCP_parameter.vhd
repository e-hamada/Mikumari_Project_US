library ieee, mylib;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use mylib.defBCT.all;

package defLACCP_parameter is
  -- Local Address  -------------------------------------------------------
  constant kTxTap                   : LocalAddressType := x"000"; -- W/R, [3:0], 
  constant kRxTap                   : LocalAddressType := x"001"; -- W/R, [3:0], 
  constant kTxSerdes                : LocalAddressType := x"002"; -- W/R, [3:0], 
  constant kRxSerdes                : LocalAddressType := x"003"; -- W/R, [3:0], 
  constant kRound_trip_time         : LocalAddressType := x"004"; -- W/R, [3:0], 
  constant kRound_trip_timeUpper    : LocalAddressType := x"005"; -- W/R, [3:0], 

  constant kTXCNTVALUEOUTInitUpper  : LocalAddressType := x"006"; -- W/R, [3:0], 
  constant kTXCNTVALUEOUTInitLower  : LocalAddressType := x"007"; -- W/R, [3:0], 
  constant kRXCNTVALUEOUTInitUpper  : LocalAddressType := x"008"; -- W/R, [3:0], 
  constant kRXCNTVALUEOUTInitLower  : LocalAddressType := x"009"; -- W/R, [3:0], 
  constant kTXCNTVALUEOUT_SlaveInitUpper  : LocalAddressType := x"00A"; -- W/R, [3:0], 
  constant kTXCNTVALUEOUT_SlaveInitLower  : LocalAddressType := x"00B"; -- W/R, [3:0], 
  constant kRXCNTVALUEOUT_SlaveInitUpper  : LocalAddressType := x"00C"; -- W/R, [3:0], 
  constant kRXCNTVALUEOUT_SlaveInitLower  : LocalAddressType := x"00D"; -- W/R, [3:0], 
  
  constant kfineOffsetUpper                     : LocalAddressType := x"010";
  constant kfineOffsetLower                     : LocalAddressType := x"011"; 
  constant kfineOffsetLocalUpper                : LocalAddressType := x"012";
  constant kfineOffsetLocalLower                : LocalAddressType := x"013";   
  constant khbcOffsetUpper                      : LocalAddressType := x"014";
  constant khbcOffsetLower                      : LocalAddressType := x"015";
  constant kvalidOffset                         : LocalAddressType := x"016";

end package defLACCP_parameter;	

