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

entity RSA_datapath is
    Port (
        --Input 
        clk     : in STD_LOGIC;
        DataIn  : in STD_LOGIC_VECTOR (31 downto 0);
        
        --Output
        DataOut : out STD_LOGIC_VECTOR (31 downto 0);
        CoreFinished: out STD_LOGIC;
        
        --Controll signals
        reset_n     : in STD_LOGIC;


        e_receive   : in STD_LOGIC;
        n_receive   : in STD_LOGIC;
        m_receive   : in STD_LOGIC
        
        );
        
end RSA_datapath;

architecture rtl of RSA_datapath is
    constant ONE    : natural := 1;
    signal core_finished_i              : STD_LOGIC;

    --Signals corresponding to the pTimesP unit
    signal p_out    : STD_LOGIC_VECTOR (127 downto 0);
    signal p_a, p_b : STD_LOGIC_VECTOR (127 downto 0);
    signal p_start          : STD_LOGIC;
    signal p_ready_out      : STD_LOGIC;
    signal reset_n_p        : STD_LOGIC;
    signal pTimesOne_s_i    : STD_LOGIC;
    signal pTimesP_s        : STD_LOGIC;
    signal pTimesP_s_i      : STD_LOGIC;
    signal pWait   : boolean;
    signal pTimesOne_s      : STD_LOGIC;
    
    --Signals corresponding to the pTimesC unit
    signal c_out    : STD_LOGIC_VECTOR (127 downto 0);
    signal c_out_r  : STD_LOGIC_VECTOR (127 downto 0);
    signal c_a, c_b      : STD_LOGIC_VECTOR (127 downto 0);
    signal c_r      : STD_LOGIC_VECTOR (127 downto 0);
    signal c_reset_n: STD_LOGIC;
    signal pTimesC_s: STD_LOGIC;
    --signal pTimesOne_s_i : STD_LOGIC;
    signal c_start: STD_LOGIC;
    signal c_ready_out : STD_LOGIC;
    signal tmp_r    : STD_LOGIC_VECTOR (128 downto 0);
    signal e_counter: unsigned (7 downto 0);
    signal pTimesC_d_i : STD_LOGIC;
    signal cWait   : boolean;
    
    --Data storing registers
    signal n_r, e_r, m_r    : STD_LOGIC_VECTOR (127 downto 0);
    signal showEBit : STD_LOGIC;
    signal m_receive_i : STD_LOGIC;
    signal e_receive_i : STD_LOGIC;
begin
    --pTimesP entity
    pTimesP  : entity work.ABmodn port map(
    --Clocks and resets
    clk         => clk,
    reset_n     => reset_n_p,
    
    --Data in interface
    A           => p_a,
    B           => p_b,
    
    n           => n_r,
    Start_i     => p_start,
    
    --Data out interface
    P           => p_out,
    P_ready     => p_ready_out
    
    );
    --pTimesC entity
    pTimesC  : entity work.ABmodn port map(
    --Clocks and resets
    clk         => clk,
    reset_n     => c_reset_n,
    
    --Data in interface
    A           => c_a,
    B           => c_b,
    
    n           => n_r,
    Start_i     => c_start,
    
    --Data out interface
    P           => c_out,
    P_ready     => c_ready_out
    
    );
    -------------------------------/\Entities done
    -------------------------------\/Internal controll
    --Data in controll
    process (clk, reset_n) begin
        if(reset_n = '0') then
            e_r <= (others => '0');
            n_r <= (others => '0');
            m_r <= (others => '0');
        elsif(clk'event and clk='1') then
            if(e_receive = '1') or (e_receive_i = '1') then
                e_r <= DataIn & e_r(127 downto 32);
            end if;
            if(n_receive = '1') then
                n_r <= DataIn & n_r(127 downto 32);
            end if;
            if(m_receive_i = '1') or (m_receive = '1') then
                m_r <= DataIn & m_r(127 downto 32);
            end if;
        end if;
    end process;
    
    process(clk, reset_n, m_receive, e_counter) 
    variable count : integer;
    begin
        if(reset_n = '0' or e_counter = 128)then
            pTimesOne_s <= '0';
            m_receive_i <= '0';
            pTimesOne_s_i <= '0';
            count := 0;
        elsif(clk'event and clk = '1') then
            if(m_receive = '1') then
                pTimesOne_s <= '1';
                m_receive_i <= '1';
                count := 1;
            elsif(pTimesOne_s = '1' and count < 3) then
                count := count + 1;
            elsif(count = 3) then
                m_receive_i <= '0';
                pTimesOne_s_i <= '1';
                count := 0;
            end if;
        end if;
    end process;
    
    process(clk, reset_n, e_receive, e_counter) 
    variable count2 : integer;
    begin
        if(reset_n = '0')then
            e_receive_i <= '0';
            count2 := 0;
        elsif(clk'event and clk = '1') then
            if(e_receive = '1') then
                e_receive_i <= '1';
                count2 := 1;
            elsif(count2 < 3) then
                count2 := count2 + 1;
            elsif(count2 = 3) then
                e_receive_i <= '0';
                count2 := 0;
            end if;
        end if;
    end process;

    process (clk, reset_n) begin
        if(reset_n = '0') then
        pWait <= false;
        elsif(clk'event and clk='1') then   
            if(reset_n_p = '0') and (pTimesOne_s = '1') then
                pWait <= true;
            elsif(pWait = true) or (pTimesOne_s = '1') then
                pWait <= false;
            end if;
        end if;
    end process;
    
    process(clk, reset_n, pTimesOne_s_i) begin
        if(reset_n = '0') then
            p_start <= '0';
        elsif(clk'event and clk = '1') then
            if(pWait = true) and (pTimesOne_s_i = '1') then
                p_start <= '1';
            elsif (p_ready_out = '1') then
                p_start <= '0';
            end if;
            if(pTimesOne_s_i = '1') then
                p_start <= '1';
            end if;
        end if;

    end process;
    
        
    process (clk, pTimesP_s, pTimesOne_s, p_out, m_r, p_ready_out, reset_n) begin
        if(reset_n = '0') then
        p_a <= (others => '0');
        p_b <= (others => '0');
        elsif(pTimesP_s = '1') then
            p_a <= tmp_r(127 downto 0);
            p_b <= tmp_r(127 downto 0);
        elsif(pTimesOne_s = '1') then
            p_a <= (127 downto 1 => '0') & '1';
            p_b <= m_r;
        end if;
    end process;
   
   
   process(clk, reset_n, p_ready_out) begin
        if(reset_n = '0') then
            reset_n_p <= '0';
        elsif(clk'event and clk='1') then
            if(p_ready_out = '1') then
                reset_n_p <= '0';
            else
                reset_n_p <= '1';
            end if;
        end if;
   end process;
   
   process (clk, reset_n, m_receive, e_counter) begin
       if(reset_n = '0' or m_receive = '1' or e_counter = 128) then
       tmp_r <= (128 downto 1 => '0') & '1';
       pTimesP_s <= '0';
       elsif(clk'event and clk='1') then
           if(p_ready_out = '1' and e_counter < 127) then
               tmp_r <= '0' & p_out;
               pTimesP_s <= '1';
           else
               tmp_r <= '1' & tmp_r(127 downto 0);
           end if;
           
           
       end if;
   end process;

    --pTimesC controller
   process(clk, reset_n, p_ready_out) begin
         if(reset_n = '0') then
             c_reset_n <= '0';
         elsif(clk'event and clk='1') then
             if(p_ready_out = '1') then
                 c_reset_n <= '0';
             else
                 c_reset_n <= '1';
             end if;
         end if;
    end process;
    
    process (clk, pTimesP_s, pTimesOne_s, p_out, m_r, p_ready_out, reset_n, m_receive) begin
        if(reset_n = '0' or m_receive = '1') then
        c_a <= (others => '0');
        c_b <= (others => '0');
        elsif(clk'event and clk = '1') then
            if(pTimesC_s = '1') then
                c_a <= c_out_r;
                c_b <= tmp_r(127 downto 0);
            end if;
        end if;
    end process;
    
    process (clk, reset_n) begin
        if(reset_n = '0') then
        cWait <= false;
        elsif(clk'event and clk='1') then   
            if(tmp_r(128) = '0') and (pTimesP_s = '1') then
                cWait <= true;
            elsif(cWait = true) then
                cWait <= false;
            end if;
        end if;
    end process;
    
    process(clk, reset_n, pTimesOne_s) begin
        if(reset_n = '0') then
            c_Start <= '0';
        elsif(clk'event and clk = '1') then
            if(cWait = true) then
                c_Start <= '1';
            elsif (p_ready_out = '1') then
                c_Start <= '0';
            end if;
        end if;
    end process;
    
    process (clk, reset_n, m_receive) begin
        if(reset_n = '0' or m_receive = '1') then
        pTimesC_s <= '0';
        elsif(clk'event and clk='1') then
            if(pTimesP_s = '1') then
                pTimesC_s <= '1';
            else
                pTimesC_s <= '0';
            end if;
        end if;
    end process;
    
    process (clk, reset_n, m_receive) begin
        if(reset_n = '0' or m_receive = '1') then
        e_counter <= (others => '0');
        elsif(clk'event and clk='1') then
            if(c_ready_out = '1' and pTimesC_s = '1') then
                e_counter <= e_counter + 1;
            end if;
        end if;
    end process;
    
    process (clk, reset_n, m_receive) begin
        if(reset_n = '0' or m_receive = '1') then
        DataOut <= (others => '0');
        c_out_r <= (127 downto 1 => '0') & '1';
        pTimesC_d_i <= '0';
        elsif(clk'event and clk = '1') then
            if(e_counter >= 127 and c_ready_out = '1') then
                pTimesC_d_i <= '1';
                c_out_r <= (127 downto 96 => '0') & c_out(127 downto 32);
                DataOut <= c_out(31 downto 0);
            elsif(pTimesC_d_i = '1') then
                c_out_r <= (127 downto 96 => '0') & c_out_r(127 downto 32);
                DataOut <= c_out_r(31 downto 0);
            elsif(c_ready_out = '1') then
                if(e_counter <= 127) then
                    if(e_r(to_integer(e_counter)) = '1') then
                        c_out_r <= c_out;
                    else
                        c_out_r <= c_out_r;
                    end if;
                end if;
            end if;
        end if;
    end process;
    
    --Showing when e_r(current bit) = 1
    process(clk, reset_n) begin
        if(reset_n = '0') then
            showEBit <= '0';
        elsif(clk'event and clk = '1') then
            if(e_counter <= 127) then
                showEBit <= e_r(to_integer(e_counter));
            end if;
        end if;
    end process;

    process(reset_n, n_receive, m_receive, e_counter, e_receive, pTimesOne_s) 
    variable isE : STD_LOGIC;
    variable isN : STD_LOGIC;
    variable isM : STD_LOGIC;
    begin
        isE := '0';
        isN := '0';
        isM := '0';
        if(reset_n = '0') then 
            core_finished_i <= '0';
        end if;
        if(n_receive = '1') then
            isN := '1';
        end if;
        if(n_receive = '0' and isN = '1') then
            core_finished_i <= '1';
            isN := '0';
        end if;
        if(m_receive = '0' and isM = '1') then
            core_finished_i <= '0';
            isM := '0';
        end if;
        if(m_receive = '1') then
            isM := '1';
        end if;
        if(e_receive = '1') then
            isE := '1';
        end if;
        if(e_receive = '0' and isE = '1') then
                core_finished_i <= '0';
        end if;
        if(pTimesC_d_i = '1') then
            core_finished_i <= '1';         
        end if;

        if(pTimesOne_s = '1') or (pTimesP_s = '1') then
            core_finished_i <= '0';
        end if;
    end process;    
    CoreFinished <= core_finished_i;--pTimesC_d_i;
end rtl;
