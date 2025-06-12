library IEEE, mylib;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity SystemReset is
  generic(
    kWidthResetSync : integer
  );
  port(
    -- Seed of the master reset --
    asyncReset    : in std_logic;
    mmcmLocked    : in std_logic;
    -- Async reset to 10GbE_PCSPMA --
    masterReset   : out std_logic;
    qpllLocked    : in std_logic; -- from core

    -- System reset --
    clkXgmii        : in std_logic; -- 156 MHz from core
    clkSys          : in std_logic; -- 156 MHz from core
    syncXgmiiReset  : out std_logic;
    syncSysReset    : out std_logic
    );
end SystemReset;

architecture RTL of SystemReset is
  -- signal declaration ---------------------------------------------------
  signal reset_shiftreg_xgmii  : std_logic_vector(kWidthResetSync-1 downto 0);
  signal reset_shiftreg_sys    : std_logic_vector(kWidthResetSync-1 downto 0);
  signal async_sys_reset  : std_logic;

-- ================================ body ==================================
begin
  -- signal connection ----------------------------------------------------
  masterReset     <= asyncReset or (not mmcmLocked);
  syncXgmiiReset  <= reset_shiftreg_xgmii(kWidthResetSync-1);
  syncSysReset    <= reset_shiftreg_sys(kWidthResetSync-1);

  async_sys_reset   <= asyncReset or (not qpllLocked);

  u_sync_xgmii_reset : process(async_sys_reset, clkXgmii)
  begin
    if(async_sys_reset = '1') then
      reset_shiftreg_xgmii  <= (others => '1');
    elsif(clkXgmii'event and clkXgmii = '1') then
      reset_shiftreg_xgmii  <= reset_shiftreg_xgmii(kWidthResetSync-2 downto 0) & '0';
    end if;
  end process;

  u_sync_sys_reset : process(async_sys_reset, clkSys)
  begin
    if(async_sys_reset = '1') then
      reset_shiftreg_sys  <= (others => '1');
    elsif(clkSys'event and clkSys = '1') then
      reset_shiftreg_sys  <= reset_shiftreg_sys(kWidthResetSync-2 downto 0) & '0';
    end if;
  end process;


end RTL;

