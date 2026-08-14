function friction_coefficient = get_frictional_frict_coef(param_struct, frict, density)

g = 9.81;
normal_stress = density .* g .* param_struct.cross_sectional_area./param_struct.perimeter.*cosd(param_struct.S0);

friction_coefficient = normal_stress.*frict;

friction_coefficient = friction_coefficient./normal_stress;
end