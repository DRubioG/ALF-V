……
-- Scratch Pad memory definition
TYPE MEMD IS ARRAY(0 TO 255) OF SLVD;
SIGNAL dram : MEMD;
BEGIN
mem_ena <= '1' WHEN op6 = store ELSE '0';
-- Active for store only
not_clk <= NOT clk;
scratch_pad_ram: PROCESS (reset, not_clk, y0)
VARIABLE idma : U8;
BEGIN
idma := CONV_INTEGER(y0); -- force unsigned
IF reset = '1' THEN
-- Asynchronous clear
dmd <= (OTHERS => '0');
ELSIF rising_edge(not_clk) THEN
IF mem_ena = '1' THEN
dram(idma) <= x; -- Write to RAM at falling clk edge
END IF;
dmd <= dram(idma); -- Read from RAM at falling clk edge
END IF;
END PROCESS;