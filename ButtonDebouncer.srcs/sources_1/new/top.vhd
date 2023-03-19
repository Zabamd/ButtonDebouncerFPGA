library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.ALL;

entity top is
    Port ( button : in STD_LOGIC;
           led : out STD_LOGIC;
           CLK : in STD_LOGIC;
           RESET : in STD_LOGIC
           );
end entity top;

architecture top_arch of top is
    --deklaracja stan?w
    type state is( stabilny, opoznienie, niestabilny);
    --stan pocz?tkowy przyjmujemy jako stabilny
    signal current_state : state := stabilny;
    signal next_state : state := stabilny;

    --rejestr licznika dla op?znienia
    signal counter_op : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
    signal counter_niestb : STD_LOGIC_VECTOR(10 downto 0 ) := (others => '0');


begin
    --proces przejscia stan?w
    state_change: process(CLK) is
    begin
        if(RESET  = '0') then
            current_state <= stabilny ;
        elsif(CLK'event and CLK = '1') then
            current_state <= next_state;
        end if;
    end process state_change;

    -- proces licznika opoznienia
    counter_op_prc: process(CLK, RESET,current_state, button) is
        begin
        if(RESET = '0') then
            counter_op <= (others => '0');
        elsif(CLK'event and CLK = '1') then
            if(current_state = opoznienie ) then
                   counter_op <= counter_op  + 1;
                   if(next_state  /= opoznienie ) then
                        counter_op  <= (others  => '0');
                   end if;
            else
                counter_op  <= (others => '0');
            end if;
        end if;
    end process counter_op_prc;

     -- proces licznika niestabilnego
    counter_prc: process(CLK, RESET, current_state ) is
        begin
         if(RESET = '0') then
            counter_niestb <= (others => '0');
             -- reset licznika do doliczeniu 1000 ms
         elsif(CLK'event and CLK = '1') then
                if(current_state = niestabilny) then
                    counter_niestb <= counter_niestb + 1;
                else
                    counter_niestb <=(others =>'0');
                end if;
         end if;
    end process counter_prc;



    --opis przej?? mi?dzy stanami
    state_conditions: process(button, counter_niestb, counter_op,next_state, current_state) is
    begin
    next_state <= current_state;
        case current_state is
            when stabilny =>
                if(button = '1') then
                    next_state <= opoznienie ;
                end if;
            when opoznienie =>
                if (counter_op = "1111") then
                    if(button = '1') then
                        next_state <= niestabilny;
                    else
                        next_state <=stabilny;
                    end if;
                end if;
           when niestabilny =>
                if(counter_niestb = "11111111111")then
                    next_state <= stabilny ;
                else
                    next_state <= niestabilny ;
                 end if;
        end case;
    end process state_conditions;
    --stan wyjscia
    led <= '1' when current_state  = niestabilny else '0';
end architecture top_arch;
