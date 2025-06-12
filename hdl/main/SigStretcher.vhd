library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity SigStretcher is
  generic(
    kLength : integer
  );
  port (
    clk       : in std_logic;
    sigIn     : in std_logic;
    sigOut    : out std_logic
    );
end SigStretcher;

architecture RTL of SigStretcher is
  -- Internal signal declaration ---------------------------------------
  signal reg_sr  : std_logic_vector(kLength-1 downto 0);

begin
  --============================ body ==================================
  sigOut  <= reg_sr(kLength-1);

  process(clk)
  begin
    if(clk'event and clk = '1') then
      if(sigIn = '1') then
        reg_sr  <= (others => '1');
      else
        reg_sr  <= reg_sr(kLength-2 downto 0) & '0';
      end if;
    end if;
  end process;

end RTL;
