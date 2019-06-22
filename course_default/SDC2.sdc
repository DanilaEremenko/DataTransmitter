create_clock -name main_clk -period 25.000 [get_ports {clk}]
derive_clock_uncertainty -add
