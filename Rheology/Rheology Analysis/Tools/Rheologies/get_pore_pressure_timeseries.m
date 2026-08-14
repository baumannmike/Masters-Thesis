function [pore_pressure,Ru,normal_stress] = get_pore_pressure_timeseries(param_struct, frict, density)

g = 9.81;
normal_stress = density .* g .* param_struct.cross_sectional_area./param_struct.perimeter.*cosd(param_struct.S0);

pp_coef = param_struct.friction_inversion./tand(frict);
Ru = 1 - pp_coef;


pore_pressure = Ru.*normal_stress;
end