function mancester_optim_individ = optim_mancester_individ(param_struct, u1, u2,u3,beta,beta_star,kappa,L, gamma,axes)

frict_mancester = get_mancester_frict_coef(param_struct, u1, u2,u3,beta,beta_star,kappa,L, gamma);



plot(param_struct.friction_inversion_smooth(:,param_struct.target_section),'-k'); 
hold on
plot(frict_mancester(:,param_struct.target_section),'LineWidth',1); 
drawnow()
hold off

residuals_friction = frict_mancester(:,param_struct.target_section) - param_struct.friction_inversion_smooth(:,param_struct.target_section);
% residuals_friction=residuals_friction';
residuals_friction(isnan(residuals_friction)) = [];
mancester_optim_individ = residuals_friction'*residuals_friction;
