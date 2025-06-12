library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

library mylib;

entity global_sitcp_manager is
    Port ( RST 			: in  STD_LOGIC;
           CLK			 	: in  STD_LOGIC;
           ACTIVE 		: in  STD_LOGIC;
           REQ 			: in  STD_LOGIC;
           ACT 			: out  STD_LOGIC;
           rstFromTCP : out  STD_LOGIC);
end global_sitcp_manager;

architecture RTL of global_sitcp_manager is
	-- signal declarations -----------------------------------------------------
  signal sync_reset : std_logic;
	signal reg_shift	: std_logic_vector(2 downto 0);

	type TcpResetType is (Init, Idle, isActive);
	signal state	: TcpResetType;

-- ================================= Body ===================================
begin
	-- generate reset signal from TCP active ------------------------------------
	u_TCP_RESET_Process : process(CLK)
	begin
		if(CLK'event and CLK = '1') then
      if(sync_reset = '1') then
        state	<= Init;
      else
        case state is
        when Init =>
          rstFromTCP 		<= '0';
          state				<= Idle;
        when Idle =>
          rstFromTCP <= '0';
          if(ACTIVE = '1') then
            state			<= isActive;
            rstFromTCP	<= '1';
          end if;
        when isActive =>
          rstFromTCP <= '0';
          if(ACTIVE = '0') then
            state			<= Idle;
            rstFromTCP	<= '1';
          end if;
        end case;
      end if;
		end if;
	end process u_TCP_RESET_Process;

	-- close act signal ------------------------------------------------------
	ACT	<= reg_shift(2);

	u_delay_req : process(CLK)
	begin
		if(CLK'event and CLK = '1') then
			reg_shift	<= reg_shift(1 downto 0) & REQ;
		end if;
	end process u_delay_req;

  -- Reset sequence --
  u_reset_gen_sys   : entity mylib.ResetGen
    port map(rst, clk, sync_reset);

end RTL;