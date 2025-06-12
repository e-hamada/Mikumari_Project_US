library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity synchronizer is
  Port (
    clk   : in STD_LOGIC;
    dIn		: in STD_LOGIC;
    dOut	: out  STD_LOGIC
    );
end synchronizer;

architecture RTL of synchronizer is
  signal q1, q2, q3	: std_logic;

  attribute async_reg : string;
  attribute async_reg  of u_Sync  : label is "true";

begin
  dOut	<= q3;

  u_Sync : process(CLK)
  begin
    if(CLK'event and CLK = '1') then
      q1	<= dIn;
      q2	<= q1;
      q3	<= q2;
    end if;
  end process;

end RTL;

