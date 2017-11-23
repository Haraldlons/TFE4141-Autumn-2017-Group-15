----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 14.11.2017 22:40:54
-- Design Name: 
-- Module Name: RSA - rtl
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity RSA_Core is
    Port ( clk : in STD_LOGIC;
           Resetn : in STD_LOGIC;
           InitRsa : in STD_LOGIC;
           StartRsa : in STD_LOGIC;
           DataIn : in STD_LOGIC_VECTOR (31 downto 0);
           DataOut : out STD_LOGIC_VECTOR (31 downto 0);
           CoreFinished : out STD_LOGIC);
end RSA_Core;

architecture rtl of RSA_Core is
    signal pTimesC_d    : STD_LOGIC;
    signal pTimesP_s    : STD_LOGIC;
    signal pTimesOne_s  : STD_LOGIC;
    signal e_receive    : STD_LOGIC;
    signal n_receive    : STD_LOGIC;
    signal m_receive    : STD_LOGIC;
begin
    rsa_controller : entity work.RSA_controller port map(
    -- Clocks and resets
    clk             => clk,
    Resetn          => Resetn,
    
    --Inputs
    InitRsa         => InitRsa,
    
    -- Output
   -- e_receive       => e_receive,
    n_receive       => n_receive
    

    );    


    rsa_datapath : entity work.RSA_datapath port map(
    -- Clocks and resets
    clk             => clk,
    reset_n         => Resetn,
    
    --Inputs
    DataIn          => DataIn,
    e_receive       => InitRsa,
    n_receive       => n_receive,
    m_receive       => StartRsa,


    -- Output
    DataOut         => DataOut,  
    CoreFinished    => CoreFinished


    );
end rtl;
