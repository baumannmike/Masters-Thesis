function mancester_optim_all_stations = mancester_optim_all_stations(param_struct1,param_struct2,param_struct3, u1, u2,u3,beta,beta_star,kappa,L, gamma)

frict_mancester_1 = get_mancester_frict_coef(param_struct1, u1, u2,u3,beta,beta_star,kappa,L, gamma);
frict_mancester_2 = get_mancester_frict_coef(param_struct2, u1, u2,u3,beta,beta_star,kappa,L, gamma);
frict_mancester_3 = get_mancester_frict_coef(param_struct3, u1, u2,u3,beta,beta_star,kappa,L, gamma);

nexttile(1)
plot(param_struct1.friction_inversion(:,param_struct1.target_section),'-k'); 
hold on
plot(frict_mancester_1(:,param_struct1.target_section),'LineWidth',1); 
hold off
nexttile(2)
plot(param_struct2.friction_inversion(:,param_struct2.target_section),'-k'); 
hold on
plot(frict_mancester_2(:,param_struct2.target_section),'LineWidth',1); 
hold off
% nexttile(3)
% plot(param_struct3.friction_inversion(:,param_struct3.target_section),'-k'); 
% hold on
% plot(frict_mancester_3(:,param_struct3.target_section),'LineWidth',1); 
% hold off

drawnow()

residuals_friction1 = frict_mancester_1(:,param_struct1.target_section) - param_struct1.friction_inversion(:,param_struct1.target_section);
residuals_friction2 = frict_mancester_2(:,param_struct2.target_section) - param_struct2.friction_inversion(:,param_struct2.target_section);
residuals_friction3 = frict_mancester_3(:,param_struct3.target_section) - param_struct3.friction_inversion(:,param_struct3.target_section);

residuals_friction=[residuals_friction1;residuals_friction2;residuals_friction3];
% residuals_friction=[residuals_friction1;residuals_friction2];
% residuals_friction=residuals_friction';
residuals_friction(isnan(residuals_friction)) = [];
mancester_optim_all_stations = residuals_friction'*residuals_friction;