
%% 
close all
clear all
clc
%% test for Gazo

addpath(genpath('\\Mac\Home\Documents\MATLAB\ambizione-foundation-data-generation\Rheology Analysis\Tools\Rheologies'))

frict_angle = 3;
turb = 300;

param_struct.cross_sectional_area = cross_sectional_area_post;
param_struct.perimeter = perimeter_rm_outlier_post;
param_struct.S0 = S0;
param_struct.width_averaged_vel = width_average_vel_smooth*0.7;

voellmy = get_voellmy_frict_coef( ...
    param_struct, ...
    tand(frict_angle), ...
    turb, ...
    2000);



%%

Sf_smooth = movmean(Sf_filtered_combined(:,target_section), 50, 'omitnan');

figure

plot(T.time, Sf_smooth, 'r', 'LineWidth',1.5)
hold on
plot(T.time, voellmy(:,target_section), 'b', 'LineWidth',1.5)

legend(sprintf('Measured Data (filtered and smoothed)'), ...
       sprintf('Voellmy ($\\varphi = %.1f^\\circ$, $\\xi = %g$)', frict_angle, turb), ...
       'Interpreter','latex')

xlabel('time')
ylabel('friction coefficient')
title('Gazoduc')

ylim([0 0.2])
grid on


%%
saveFolder = pwd;

[~, name, ~] = fileparts(filename);

parts = split(name, '_');
site = parts{1};   % CD27

pathParts = split(filename, filesep);
dateStr = "";
for i = 1:length(pathParts)
    if contains(pathParts{i}, '_') && strlength(pathParts{i}) == 10
        dateStr = pathParts{i};
    end
end

baseName = site + "_" + dateStr;

%% Calculate error metric


difference = Sf_smooth - voellmy(:,target_section);

SSE = nansum(difference.^2);


% Optional: safer date handling
dateStr = string(dateStr);
dateStr = replace(dateStr, "_", "-");   % optional cleanup

row = table( ...
    string(site), ...
    string(dateStr), ...
    SSE, ...
    'VariableNames', {'Station','Date','SSE'} );

% Append to results table

T_results = [T_results; row];

save('SSE_results.mat', 'T_results')

%%
exportgraphics(gcf, fullfile(saveFolder, baseName + "_smoothed.png"), ...
    'Resolution', 300)

%%
close all

%% plot results (reduced)
figure

plot(T.time, Sf_filtered_combined(:,target_section), 'r', 'LineWidth',1.5)
hold on
plot(T.time, voellmy(:,target_section), 'b', 'LineWidth',1.5)

legend(sprintf('Measured Data (filtered)'), ...
       sprintf('Voellmy ($\\varphi = %.1f^\\circ$, $\\xi = %g$)', frict_angle, turb), ...
       'Interpreter','latex')

xlabel('time')
ylabel('friction coefficient')
title('Gazoduc')

ylim([0 0.2])
grid on


%%
saveFolder = pwd;

[~, name, ~] = fileparts(filename);

parts = split(name, '_');
site = parts{1};   % CD27

pathParts = split(filename, filesep);
dateStr = "";
for i = 1:length(pathParts)
    if contains(pathParts{i}, '_') && strlength(pathParts{i}) == 10
        dateStr = pathParts{i};
    end
end

baseName = site + "_" + dateStr;

exportgraphics(gcf, fullfile(saveFolder, baseName + "_noisy.png"), ...
    'Resolution', 300)
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