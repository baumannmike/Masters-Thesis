function friction_coefficient = get_mancester_frict_coef(param_struct, u1, u2,u3,beta,beta_star,kappa,L, gamma)

dz_dy = param_struct.T2;
S0 = param_struct.T1;

Fr = param_struct.froude;
h= param_struct.depth;
friction_coefficient = Fr;
g = 9.81;
u_start = u3+(u2-u1)./(1+h./L);

%for low froude
low_fr_2 = abs(S0 - dz_dy);
low_frict = min(u_start,low_fr_2);
friction_coefficient(Fr < 0.01) = low_frict(Fr < 0.01);

%for intermediate froude
T1 = (Fr./beta_star).^kappa;

denom_mid = 1 + h.*beta./(L.*(beta_star+gamma));
T2_mid = (u2-u1)./denom_mid;
T2 = u1+T2_mid-u_start;

mid_frict = T1.*T2+u_start;

friction_coefficient(Fr > 0.01& Fr <beta_star) = mid_frict(Fr > 0.01& Fr <beta_star);

%for high froude
denom = 1+(h.*beta./(L.*(Fr+gamma)));
high_frict = u1+(u2-u1)./denom;
friction_coefficient(Fr >beta_star) = high_frict(Fr >beta_star);

end