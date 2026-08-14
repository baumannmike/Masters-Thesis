function mu_b = get_powerlaw_frict_coef(param_struct, tau_y, eta, n)

g = 9.81;

% Inputs from struct (wie in deinen anderen Modellen)
u_bar = param_struct.width_averaged_vel;
h     = param_struct.depth;
theta = param_struct.S0;   % in Grad
rho = 2000;  % falls vorhanden, sonst ergänzen

% avoid division issues
h_prime = h;  % falls du später eine korrigierte Wassertiefe hast

% shear rate approximation
shear_rate = max(u_bar ./ max(h, eps), 0);

% Power-law + yield stress model
tau_b = tau_y + eta .* (shear_rate .^ n);

% friction coefficient
mu_b = tau_b ./ (rho .* g .* cosd(theta) .* h_prime);
mu_b = real(mu_b);

end