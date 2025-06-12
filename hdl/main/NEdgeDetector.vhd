--Negative Edge detector

library ieee;
use ieee.std_logic_1164.all;

entity NEdgeDetector is
  port(
    clk	        : in std_logic;
    dIn         : in std_logic;
    dOut	: out std_logic
    );
end NEdgeDetector;

architecture RTV of NEdgeDetector is
  signal q1, q2	: std_logic;

  attribute async_reg : string;
  attribute async_reg  of u_ff  : label is "true";

begin
  u_ff : process(clk)
  begin
    if(clk'event and clk = '1') then
      q1        <= dIn;
      q2        <= q1;
    end if;
  end process;

  dOut <= q1 NOR (NOT q2);

end RTV;
