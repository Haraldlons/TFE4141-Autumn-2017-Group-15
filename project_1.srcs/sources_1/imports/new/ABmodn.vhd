----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01.11.2017 09:30:02
-- Design Name: 
-- Module Name: ABmodn - Behavioral
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

entity ABmodn is
    Port ( 
            -- Clocks and resets
           clk : in STD_LOGIC;
           reset_n : in STD_LOGIC;
           
           -- Data in
           A : in STD_LOGIC_VECTOR (127 downto 0);
           B : in STD_LOGIC_VECTOR (127 downto 0);
           n : in STD_LOGIC_VECTOR (127 downto 0);
           Start_i : in STD_LOGIC;
           
           -- Data out
           P : out STD_LOGIC_VECTOR (127 downto 0);
           P_ready : out STD_LOGIC
           );
end ABmodn;

architecture rtl of ABmodn is
    signal a_r, b_r : STD_LOGIC_VECTOR (127 downto 0);
    signal p_r      : STD_LOGIC_VECTOR (127 downto 0);
    signal n_r      : STD_LOGIC_VECTOR (127 downto 0);
    
    -- Controll signals
    signal start_count  : STD_LOGIC;
    signal count        : unsigned(7 downto 0);
    signal p_ready_i    : STD_LOGIC;
    
    constant LENGTH     : natural := 128;
    
begin
    -- Controller functionality
    process (clk, reset_n) begin
     if(reset_n = '0') then
       a_r <= (others => '0');
       b_r <= (others => '0');
       n_r <= (others => '0');
       start_count <= '0';
     elsif(clk'event and clk='1') then
      if(Start_i = '1') and (start_count = '0') then
        a_r <= A;
        b_r <= B;
        n_r <= n;
        start_count <= '1';
      end if;
     end if;
    end process;

    process (reset_n, clk) begin
      if(reset_n = '0') then 
        count <= (others => '0');
      elsif (clk'event and clk='1') then
        if(start_count = '1') then
            if(count >= (LENGTH-1)) then
                count <= (others => '0');
            else
                count <= count + 1;
            end if;
        end if;
      end if;
    end process;

    process (reset_n, clk) begin
      if(reset_n = '0') then 
        p_ready_i <= '0';
      elsif (clk'event and clk='1') then
        if(count >= (LENGTH-1) and count < LENGTH) then
            p_ready_i <= '1';
        else
            p_ready_i <= '0';
        end if;
      end if;
    end process;

    --p_r calculation
    process (reset_n, clk)
    variable lsPlusA  : STD_LOGIC_VECTOR (129 downto 0);
    variable minusN   : STD_LOGIC_VECTOR (129 downto 0);
    variable minus2N  : STD_LOGIC_VECTOR (128 downto 0);
     begin
      if(reset_n = '0') then
        p_r <= (others => '0');
      elsif(clk'event and clk='1') then
        if(count < LENGTH*2) then
            --lsPlusA
            if(count < 1) then
                if(b_r(LENGTH - to_integer(count) - 1) = '1') then
                    lsPlusA := "00" & a_r;
                else
                    lsPlusA := (others => '0');
                end if;
            else
                if(b_r(LENGTH - to_integer(count) - 1) = '1') then
                    lsPlusA := STD_LOGIC_VECTOR((unsigned("00" & p_r(127 downto 0)) sll 1) + unsigned(a_r));
                else
                    lsPlusA := STD_LOGIC_VECTOR(unsigned("00" & p_r(127 downto 0)) sll 1);
                end if;
            end if;
            
            --For minusN and minus2N we could try lls'ing n to get 2n and compare that, then mux lsPlus - n or lsPlusA - 2n
            --minusN
            if(unsigned(lsPlusA) >= unsigned(n_r)) then
                minusN := STD_LOGIC_VECTOR(unsigned(lsPlusA) - unsigned("00" & n_r));
            else
                minusN := lsPlusA(129 downto 0);
            end if;
            
            --minus2N
            if(unsigned(minusN) >= unsigned(n_r)) then
                minus2N := STD_LOGIC_VECTOR(unsigned(minusN(128 downto 0)) - unsigned('0' & n_r));              
            else
                minus2N := STD_LOGIC_VECTOR(minusN(128 downto 0));
            end if;
            
            --p_r
            p_r <= minus2N(127 downto 0);       --Count < LENGTH
        else
            p_r <= minus2N(127 downto 0);--(others => '0');             --Done calculating
        end if;
         
     end if;
    end process;
    
    --Assign output signals
    P <= p_r;
    P_ready <= p_ready_i;
end rtl;
