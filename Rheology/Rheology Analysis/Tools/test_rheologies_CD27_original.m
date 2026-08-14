clc
clear all
close all
load('X:\01_Projects\01_Ambizione\UncompressData\ILL\Events\2023\Friction\friction_data_2023.mat')
%%
 CD27_features = readtable(['\\tiliva\eg\01_Projects\01_Ambizione\UncompressData\ILL\Events\2023\2023_04_28\CD27\03_ProcessedData\hs_obj_det\velocity_2023_04_28_ILL_botsort.csv']);
%% test for Gazo
addpath(genpath('\\Mac\Home\Documents\MATLAB\ambizione-foundation-data-generation\Rheology Analysis\Tools\Rheologies'))

frict_angle = 5;
turb = 500;

u1=0.00015;
u2=0.14;
u3=0.02;
beta = 1;
beta_star = 0.2;
kappa=0.1;
L=0.9;
gamma = 1.1;

yield_stress =0.7;
nu = 0.2;
n = 1.25;


i =1; %
friction_data{i}.CD27_Friction.voellmy = get_voellmy_frict_coef(friction_data{i}.CD27_Friction,tand(frict_angle),turb,2000);
friction_data{i}.CD27_Friction.frictional = get_frictional_frict_coef(friction_data{i}.CD27_Friction,tand(frict_angle),2000);
friction_data{i}.CD27_Friction.friction_Mancester = get_mancester_frict_coef(friction_data{i}.CD27_Friction, u1, u2,u3,beta,beta_star,kappa,L, gamma);

friction_data{i}.CD27_Friction.yield_stress_law = get_yield_stress_friction(friction_data{i}.CD27_Friction, yield_stress,nu,n);

[friction_data{i}.CD27_Friction.pore_pressure,friction_data{i}.CD27_Friction.Ru,friction_data{i}.CD27_Friction.normal_stress] = get_pore_pressure_timeseries(friction_data{i}.CD27_Friction, 30, 2000);


%% plot results

font_size = 20;
legend_font_size=15;
line_width = 1;
xlimits = [minutes(-5) minutes(90)];
ylimits = [0.0 0.2];
figure
% % 
% yyaxis left
% % plot(plot_boulders.time,plot_boulders.average_velocity,'.b');
% % hold on
% % plot(plot_wood.time,plot_wood.average_velocity,'.g');
% % plot(plot_surge.time,plot_surge.average_velocity,'.m');
% % plot(plot_rolling_boulder.time,plot_rolling_boulder.average_velocity,'.c');
% plot(count_times,counts,'.-k');
% % ylim([0 30])
% yyaxis right
% friction_data{i}.CD27_Friction.friction_inversion_smooth = movmean(friction_data{i}.CD27_Friction.friction_inversion,1,'omitnan');
friction_data{i}.CD27_Friction.friction_inversion_smooth = sgolayfilt(friction_data{i}.CD27_Friction.friction_inversion,3,21);

plot(friction_data{i}.CD27_Friction.time,friction_data{i}.CD27_Friction.friction_inversion(:,friction_data{i}.CD27_Friction.target_section),'r','LineWidth',line_width);
hold on
plot(friction_data{i}.CD27_Friction.time,friction_data{i}.CD27_Friction.friction_Mancester(:,friction_data{i}.CD27_Friction.target_section),'-b','LineWidth',line_width);
plot(friction_data{i}.CD27_Friction.time,friction_data{i}.CD27_Friction.frictional(:,friction_data{i}.CD27_Friction.target_section),'-g','LineWidth',line_width);
plot(friction_data{i}.CD27_Friction.time,friction_data{i}.CD27_Friction.voellmy(:,friction_data{i}.CD27_Friction.target_section),'-m','LineWidth',line_width);

plot(friction_data{i}.CD27_Friction.time,friction_data{i}.CD27_Friction.yield_stress_law(:,friction_data{i}.CD27_Friction.target_section),'-k','LineWidth',line_width);

% legend_string = {'boulder detection', 'inversion','Mancester','Frictional','Voellmy'};
legend_string = { 'inversion','Mancester','Frictional','Voellmy','yield stress'};
legend(legend_string,'FontSize',legend_font_size);
ylabel('friction coefficient','FontSize',font_size)
title('CD27','FontSize',font_size)
% xlim(xlimits);    
ylim(ylimits)
% set(gca, 'SortMethod', 'depth');


% linkaxes([ax1 ax2 ax3])

%% investigate pore pressure

indices = friction_data{i}.CD27_Friction.width_averaged_vel(:,friction_data{i}.CD27_Friction.target_section)>0.1;
% indices = [18000:65000];
% indices2 = friction_data{i}.CD27_Friction.depth>0.3;
friction_data{i}.CD27_Friction.Ru(~indices) = NaN;
friction_data{i}.CD27_Friction.Ru(friction_data{i}.CD27_Friction.Ru>1) = NaN;
friction_data{i}.CD27_Friction.Ru(~indices) = NaN;

figure
plot(friction_data{i}.CD27_Friction.Ru(indices,friction_data{i}.CD27_Friction.target_section))
yyaxis right
plot(friction_data{i}.CD27_Friction.width_averaged_vel(indices,friction_data{i}.CD27_Friction.target_section))

figure
plot(friction_data{i}.CD27_Friction.Ru(indices,friction_data{i}.CD27_Friction.target_section))
yyaxis right
plot(friction_data{i}.CD27_Friction.depth(indices,friction_data{i}.CD27_Friction.target_section))

figure
plot(friction_data{i}.CD27_Friction.pore_pressure(indices,friction_data{i}.CD27_Friction.target_section))
hold on
plot(friction_data{i}.CD27_Friction.normal_stress(indices,friction_data{i}.CD27_Friction.target_section))
yyaxis right
plot(friction_data{i}.CD27_Friction.Ru(indices,friction_data{i}.CD27_Friction.target_section))

%% 
% indices = [18000:65000];
figure
tiledlayout(3,1)
nexttile
scatter(friction_data{i}.CD27_Friction.width_averaged_vel(indices,friction_data{i}.CD27_Friction.target_section),friction_data{i}.CD27_Friction.Ru(indices,friction_data{i}.CD27_Friction.target_section))
ylim([0.8 1])
% figure
title('velocity and pore pressure')
nexttile
title('depth and pore pressure')
scatter(friction_data{i}.CD27_Friction.depth(indices,friction_data{i}.CD27_Friction.target_section),friction_data{i}.CD27_Friction.Ru(indices,friction_data{i}.CD27_Friction.target_section))
ylim([0.8 1])
nexttile
title('froude and pore pressure')
scatter(friction_data{i}.CD27_Friction.froude(indices,friction_data{i}.CD27_Friction.target_section),friction_data{i}.CD27_Friction.Ru(indices,friction_data{i}.CD27_Friction.target_section))
ylim([0.8 1])