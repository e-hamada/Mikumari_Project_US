library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;

library mylib;
use mylib.defMiiRstTimer.all;

entity MiiRstTimer is
  port (
    rst         : in std_logic;
    clk         : in std_logic;
    rstMiiOut   : out std_logic
    );
end MiiRstTimer;

architecture RTL of MiiRstTimer is
  attribute keep : string;

  -- System --
  signal sync_reset           : std_logic;
  constant kWidthResetSync    : integer:= 16;
  signal reset_shiftreg       : std_logic_vector(kWidthResetSync-1 downto 0);

  -- signal decralation -----------------------------------------------------
  signal reg_reset    : std_logic:= '1';
  signal reg_counter  : std_logic_vector(kWidthCounter-1 downto 0):= (others => '1');

begin
  -- ====================== body ============================= --
  rstMiiOut <= reg_reset;

  process(clk, sync_reset)
  begin
    if(sync_reset = '1') then
      reg_reset     <= '1';
      reg_counter   <= (others=> '1');
    elsif(clk'event and clk = '1') then
      if(unsigned(reg_counter) = 0) then
        reg_reset   <= '0';
      else
        reg_counter   <= std_logic_vector(unsigned(reg_counter) -1);
      end if;
    end if;
  end process;

  -- Reset sequence --
  sync_reset  <= reset_shiftreg(kWidthResetSync-1);
  u_sync_reset : process(clk, rst)
  begin
    if(rst = '1') then
      reset_shiftreg  <= (others => '1');
    elsif(clk'event and clk = '1') then
      reset_shiftreg  <= reset_shiftreg(kWidthResetSync-2 downto 0) & '0';
    end if;
  end process;

end RTL;
