library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ResetGen is
    port (
      rst       : in std_logic;
      clk       : in std_logic;
      resetOut  : out std_logic
      );
end ResetGen;

architecture RTL of ResetGen is
  -- Internal signal declaration ---------------------------------------
  constant kWidthResetSync  : integer:= 5;
  signal reg_reset          : std_logic_vector(kWidthResetSync-1 downto 0);

  attribute async_reg : string;
  attribute async_reg of u_sync_reset : label is "true";

begin
  --============================ body ==================================
  resetOut  <= reg_reset(kWidthResetSync-1);

  u_sync_reset : process(clk)
  begin
    if(clk'event and clk = '1') then
      reg_reset  <= reg_reset(kWidthResetSync-2 downto 0) & rst;
    end if;
  end process;

end RTL;
