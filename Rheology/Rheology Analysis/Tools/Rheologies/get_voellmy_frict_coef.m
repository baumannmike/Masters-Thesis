function friction_coefficient = get_voellmy_frict_coef(param_struct, frict, turb, density)

g = 9.81;
normal_stress = density .* g .* param_struct.cross_sectional_area./param_struct.perimeter.*cosd(param_struct.S0);
velocity = param_struct.width_averaged_vel;

friction_coefficient = normal_stress.*frict + density.*g.*velocity.^2./turb;

friction_coefficient = friction_coefficient./normal_stress;
end