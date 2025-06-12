library IEEE, mylib;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
library ieee, mylib;


use mylib.defBCT.all;
use mylib.defLACCP_parameter.all;
use mylib.defMikumari.all;
use mylib.defLaccp.all;
use mylib.defCDCM.all;
use mylib.defHeartBeatUnit.all;


entity LACCP_parameter is
  port(
    rst	                : in std_logic;
    clk	                : in std_logic;
    -- LACCP parameter input --
    TxTap               : in std_logic_vector(kWidthTap-1 downto 0); 
    RxTap               : in std_logic_vector(kWidthTap-1 downto 0); 
    TxSerdes            : in signed(kWidthSerdesOffset-1 downto 0);
    RxSerdes            : in signed(kWidthSerdesOffset-1 downto 0);
    Round_trip_time     : in std_logic_vector(kWidthHbCount-1 downto 0);
    TXCNTVALUEOUTInit   : in std_logic_vector(kCNTVALUEbit-1 downto 0);
    RXCNTVALUEOUTInit   : in unsigned(kCNTVALUEbit-1 downto 0);
    TXCNTVALUEOUT_SlaveInit : in std_logic_vector(kCNTVALUEbit-1 downto 0);
    RXCNTVALUEOUT_SlaveInit : in unsigned(kCNTVALUEbit-1 downto 0);
    
    fineOffset              : in signed(kWidthLaccpFineOffset-1 downto 0);
    fineOffsetLocal         : in signed(kWidthLaccpFineOffset-1 downto 0);
    hbcOffset               : in std_logic_vector(kWidthHbCount-1 downto 0);
    validOffset             : std_logic;
    
    -- Local bus --
    addrLocalBus        : in LocalAddressType;
    dataLocalBusIn      : in LocalBusInType;
    dataLocalBusOut	    : out LocalBusOutType;
    reLocalBus          : in std_logic;
    weLocalBus          : in std_logic;
    readyLocalBus	      : out std_logic
    );
end LACCP_parameter;

architecture RTL of LACCP_parameter is
  -- internal signal declaration ----------------------------------------
  signal state_lbus	: BusProcessType;

-- =============================== body ===============================
begin

  u_BusProcess : process(clk, rst)
  begin
    if(rst = '1') then
      state_lbus	<= Init;
    elsif(clk'event and clk = '1') then
      case state_lbus is
        when Init =>
          dataLocalBusOut       <= x"00";
          readyLocalBus		<= '0';
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
          --case addrLocalBus is
          --  when kSelLED =>
          --    reg_LED	<= dataLocalBusIn(kNumLED-1 downto 0);
          --  when others => null;
          --end case;
          state_lbus	<= Done;

        when Read =>
          case addrLocalBus is
            when kTxTap =>                      
              dataLocalBusOut <= "000" & TxTap;
            when kRxTap =>
              dataLocalBusOut <= "000" & RxTap;
            when kTxSerdes =>
              dataLocalBusOut <= "0000" & std_logic_vector(TxSerdes);       
            when kRxSerdes =>
              dataLocalBusOut <= "0000" & std_logic_vector(RxSerdes);
            when kRound_trip_time =>
              dataLocalBusOut <= Round_trip_time(15 downto 8);     
            when kRound_trip_timeUpper =>
              dataLocalBusOut <= Round_trip_time(7 downto 0);       
            when kTXCNTVALUEOUTInitUpper =>
              dataLocalBusOut <= "0000000" & TXCNTVALUEOUTInit(8);
            when kTXCNTVALUEOUTInitLower =>
              dataLocalBusOut <= TXCNTVALUEOUTInit(7 downto 0);                                
            when kRXCNTVALUEOUTInitUpper =>
              dataLocalBusOut <= "0000000" & RXCNTVALUEOUTInit(8);
            when kRXCNTVALUEOUTInitLower =>
              dataLocalBusOut <= std_logic_vector(RXCNTVALUEOUTInit(7 downto 0));                 
            when kTXCNTVALUEOUT_SlaveInitUpper =>
              dataLocalBusOut <= "0000000" & TXCNTVALUEOUT_SlaveInit(8);
            when kTXCNTVALUEOUT_SlaveInitLower =>
              dataLocalBusOut <= TXCNTVALUEOUT_SlaveInit(7 downto 0);                                
            when kRXCNTVALUEOUT_SlaveInitUpper =>
              dataLocalBusOut <= "0000000" & RXCNTVALUEOUT_SlaveInit(8);
            when kRXCNTVALUEOUT_SlaveInitLower =>
              dataLocalBusOut <= std_logic_vector(RXCNTVALUEOUT_SlaveInit(7 downto 0));                 
            when kfineOffsetUpper => 
              dataLocalBusOut <= std_logic_vector(fineOffset(15 downto 8));                             
            when kfineOffsetLower => 
              dataLocalBusOut <= std_logic_vector(fineOffset(7 downto 0));                                    
            when kfineOffsetLocalUpper =>
              dataLocalBusOut <= std_logic_vector(fineOffsetLocal(15 downto 8));
            when kfineOffsetLocalLower =>
              dataLocalBusOut <= std_logic_vector(fineOffsetLocal(7 downto 0));
            when khbcOffsetUpper =>
              dataLocalBusOut <= std_logic_vector(hbcOffset(15 downto 8));
            when khbcOffsetLower =>
              dataLocalBusOut <= std_logic_vector(hbcOffset(7 downto 0));            
            when kvalidOffset =>
              dataLocalBusOut <= "0000000" & validOffset;
                                                                        
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
  end process u_BusProcess;

end RTL;

