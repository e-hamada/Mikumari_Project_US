library IEEE, mylib;
use IEEE.STD_LOGIC_1164.ALL;

use mylib.defBCT.all;
use mylib.defLED.all;

entity LEDModule is
  generic(
    kNumLED             : integer
  );
  port(
    rst	                : in std_logic;
    clk	                : in std_logic;
    -- Module output --
    outLED              : out std_logic_vector(kNumLED downto 1);
    -- Local bus --
    addrLocalBus        : in LocalAddressType;
    dataLocalBusIn      : in LocalBusInType;
    dataLocalBusOut	    : out LocalBusOutType;
    reLocalBus          : in std_logic;
    weLocalBus          : in std_logic;
    readyLocalBus	      : out std_logic
    );
end LEDModule;

architecture RTL of LEDModule is
  -- internal signal declaration ----------------------------------------
  signal sync_reset : std_logic;

  signal reg_LED	  : std_logic_vector(outLED'range);
  signal state_lbus	: BusProcessType;

-- =============================== body ===============================
begin
  outLED	<= reg_LED;

  u_BusProcess : process(clk)
  begin
    if(clk'event and clk = '1') then
      if(sync_reset = '1') then
        state_lbus	<= Init;
      else
        case state_lbus is
          when Init =>
            dataLocalBusOut       <= x"00";
            readyLocalBus		<= '0';
            reg_LED		<= (others => '0');
            state_lbus		<= Idle;

          when Idle =>
            readyLocalBus	<= '0';
            if(weLocalBus = '1' or reLocalBus = '1') then
              state_lbus	<= Connect;
            end if;

          when Connect =>
            if(weLocalBus = '1') then
              state_lbus	<= Write;
            else
              state_lbus	<= Read;
            end if;

          when Write =>
            case addrLocalBus is
              when kSelLED =>
                reg_LED	<= dataLocalBusIn(kNumLED-1 downto 0);
              when others => null;
            end case;
            state_lbus	<= Done;

          when Read =>
            case addrLocalBus is
              when kSelLED =>
                dataLocalBusOut <= "0000" & reg_LED;
              when others =>
                dataLocalBusOut <= x"ff";
            end case;
            state_lbus	<= Done;

          when Done =>
            readyLocalBus	<= '1';
            if(weLocalBus = '0' and reLocalBus = '0') then
              state_lbus	<= Idle;
            end if;

          -- probably this is error --
          when others =>
            state_lbus	<= Init;
        end case;
      end if;
    end if;
  end process u_BusProcess;

  -- Reset sequence --
  u_reset_gen_sys   : entity mylib.ResetGen
    port map(rst, clk, sync_reset);

end RTL;

