library ieee;
use ieee.std_logic_1164.all;

package defSiTCP_XG is

  -- TCP bus definition --
  constant kWidthAddrRx     : positive:= 16;

  -- DAQ data definition
  constant kWidthDaqData    : positive:=64; -- Maximum (default): 64
  constant kNumByteTCPXG    : std_logic_vector(3 downto 0):= "1000";

  -- XGMII --
  constant kWidthDataXGMII  : positive:= 64;
  constant kWidthCtrlXGMII  : positive:= 8;

end package defSiTCP_XG;

