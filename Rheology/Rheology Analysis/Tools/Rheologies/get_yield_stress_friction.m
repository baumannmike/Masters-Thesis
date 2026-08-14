function friction_coefficient = get_yield_stress_friction(param_struct, yield_stress,nu,n)


h= param_struct.depth;
vel = abs(param_struct.width_averaged_vel);
g = 9.81;
S0 = atand(param_struct.T1);
friction_coefficient = (yield_stress+nu.*(vel./h).^n)./(g.*h.*cosd(S0));


end