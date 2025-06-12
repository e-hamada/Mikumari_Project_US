library IEEE, mylib;
use IEEE.STD_LOGIC_1164.ALL;
use mylib.defSiTCP.all;
--use mylib.defTCP_sender.all;

entity TCP_sender is
  port(
    rst 					: in std_logic;
    clk 					: in std_logic;

    -- data from EVB --
    rdFromEVB		  : in std_logic_vector(kWidthDataTCP-1 downto 0);
    rvFromEVB		  : in std_logic;
    emptyFromEVB  : in std_logic;
    reToEVB		    : out std_logic;

    -- data to SiTCP
    isActive		  : in std_logic;
    afullTx		    : in std_logic;
    weTx		      : out std_logic;
    wdTx		      : out std_logic_vector(kWidthDataTCP-1 downto 0)

    );
end TCP_sender;

architecture RTL of TCP_sender is
  -- signal declaration ---------------------------------------------------
  signal sync_reset   : std_logic;

-- ================================ body ==================================
begin
  -- signal connection ----------------------------------------------------

  -- FIFO read
  u_buffer_reader : process(CLK)
  begin
    if(CLK'event AND CLK = '1') then
      if(sync_reset = '1') then
        weTx	<= '0';
        wdTx	<= (others => '0');
      else
        if(isActive = '1') then
          -- Normal operation --
          weTx	<= rvFromEVB;
          wdTx	<= rdFromEVB;

          if(emptyFromEVB = '0' AND afullTx = '0') then
            reToEVB	<= '1';
          else
            reToEVB	<= '0';
          end if;
        else
          -- Discard remaining data --
          weTx	<= '0';

          if(emptyFromEVB = '0') then
            reToEVB	<= '1';
          else
            reToEVB	<= '0';
          end if;
        end if;
      end if;
    end if;
  end process u_buffer_reader;

  -- Reset sequence --
  u_reset_gen_sys   : entity mylib.ResetGen
    port map(rst, clk, sync_reset);

end RTL;

