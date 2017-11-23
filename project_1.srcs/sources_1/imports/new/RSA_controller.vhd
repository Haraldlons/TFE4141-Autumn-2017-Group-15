----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 14.11.2017 22:49:29
-- Design Name: 
-- Module Name: RSA_datapath - rtl
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity RSA_controller is
    Port (
        --Input 
        clk     : in STD_LOGIC;
        Resetn : in STD_LOGIC;
        InitRsa : in STD_LOGIC;
        
        --Output
        --e_receive   : out STD_LOGIC;
        n_receive   : out STD_LOGIC
        
        );
        
end RSA_controller;

architecture rtl of RSA_controller is
    --Constants
    constant LENGTH                     : natural := 130;
    constant CONF_COUNT_AT_MSG_START    : natural := 12;
    constant DELAY_C_TO_P               : natural := 1;
    constant PDELAY                     : natural := 1;
    constant PLENGTH                    : natural := LENGTH + PDELAY;
    constant KEY_LENGTH                 : natural := 4;
    constant MSG_LENGTH                 : natural := 4;
    constant CONFIG_LENGTH              : natural := 4*KEY_LENGTH; --Number of keys times number of 32 bit packets per key
    --Other signals
    signal start_config_counter         : STD_LOGIC;
    signal config_counter               : unsigned (7 downto 0); --Probably less than 7 downto 0 to save space
    
    --shared variable pTimesP_count       : unsigned (7 downto 0);
begin
    --------------------------------------Initialize signals
    
    --------------------------------------Configuration counter
    process (Resetn, clk, InitRsa) begin
      if(Resetn = '0' or InitRsa = '1') then 
        config_counter <= (others => '0');
      elsif (clk'event and clk='1') then
        if(start_config_counter = '1') and (config_counter < CONFIG_LENGTH*2) then
            config_counter <= config_counter + 1;
        end if;
      end if;
    end process;
    
    process (Resetn, clk, InitRsa) begin
      if(Resetn = '0') then 
        start_config_counter <= '0';
      elsif (clk'event and clk='1') then
        if(InitRsa = '1') then
            start_config_counter <= '1';
        elsif(config_counter = CONFIG_LENGTH*2) then
            start_config_counter <= '0';
        end if;
      end if;
    end process;
    --------------------------------------Configuration calculations       
    --e_receive
--    process (Resetn, clk, InitRsa) begin
--      if(Resetn = '0') then 
--        e_receive <= '0';
--      elsif(InitRsa'event and InitRsa = '1' and config_counter /= 0) then
--        e_receive <= '0';
--      elsif (clk'event and clk='1') then
--        if(config_counter >= 0*KEY_LENGTH) and (config_counter < 0*KEY_LENGTH + KEY_LENGTH-2) then --Possibly do -1 to account for signal propagation
--            e_receive <= '1';
--        else
--            e_receive <= '0';
--        end if;
--      end if;
--    end process; 
       
    --n_receive
    process (Resetn, clk, InitRsa) begin
      if(Resetn = '0' or InitRsa = '1') then 
        n_receive <= '0';
      elsif (clk'event and clk='1') then
        if(config_counter >= ((1*KEY_LENGTH)-2)) and (config_counter < ((1*KEY_LENGTH) + (KEY_LENGTH-2))) then --Possibly do -1 to account for signal propagation
            n_receive <= '1';
        else
            n_receive <= '0';
        end if;
      end if;
    end process;
    
end architecture;