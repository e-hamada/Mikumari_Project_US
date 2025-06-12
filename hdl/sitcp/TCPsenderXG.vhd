library IEEE, mylib;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

use mylib.defSiTCP_XG.all;

entity TCPsenderXG is
  port(
    rst 					: in std_logic;
    clk 					: in std_logic;

    -- data from EVB --
    rdFromEVB		  : in std_logic_vector(kWidthDataXGMII-1 downto 0);
    rvFromEVB		  : in std_logic;
    emptyFromEVB  : in std_logic;
    reToEVB		    : out std_logic;

    -- data to SiTCP
    isActive		  : in std_logic;
    afullTx		    : in std_logic;
    tcpTxB	      : out std_logic_vector(kNumByteTCPXG'range);
    tcpTxD	      : out std_logic_vector(kWidthDataXGMII-1 downto 0)

    );
end TCPsenderXG;

architecture RTL of TCPsenderXG is
  -- signal declaration ---------------------------------------------------
  signal sync_reset       : std_logic;

  signal din_wdtx         : std_logic_vector(kWidthDataXGMII-1 downto 0);
  signal num_byte_txd     : std_logic_vector(kNumByteTCPXG'range);

-- ================================ body ==================================
begin
  -- signal connection ----------------------------------------------------
  -- Tx Num Byte --
  num_byte_txd  <= kNumByteTCPXG;

  -- FIFO read
  u_buffer_reader : process(CLK)
  begin
    if(CLK'event AND CLK = '1') then
      if(sync_reset = '1') then
        tcpTxB	<= (others => '0');
        tcpTxD	<= (others => '0');
      else
        if(isActive = '1') then
          if(rvFromEVB = '1') then
            tcpTxB  <= num_byte_txd;
          else
            tcpTxB  <= "0000";
          end if;

          tcpTxD	<= rdFromEVB;

          if(emptyFromEVB = '0' AND afullTx = '0') then
            reToEVB	<= '1';
          else
            reToEVB	<= '0';
          end if;
        else
          tcpTxB  <= "0000";

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

