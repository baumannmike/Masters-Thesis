clc
clear all
close all

%%
 %CD27_features = readtable(['\\tiliva\eg\01_Projects\01_Ambizione\UncompressData\ILL\Events\2023\2023_04_28\CD27\03_ProcessedData\hs_obj_det\velocity_2023_04_28_ILL_botsort.csv']);
%% test for Gazo
addpath(genpath('\\Mac\Home\Documents\MATLAB\ambizione-foundation-data-generation\Rheology Analysis\Tools\Rheologies'))

u1 = 0.00015;
u2 = 0.14;
u3 = 0.001;

%u1 = 0.00015;
%u2 = 0.14;
%u3 = 0.001;

beta = 0.5;
beta_star = 0.1;
kappa = 1;
L = 0.9;
gamma = 1.1;

params.T2 = dz_dy;
params.T1 = S0;
params.froude = froude;
params.depth = depth;

friction_Mancester = get_mancester_frict_coef( ...
    params, ...
    u1, u2, u3, ...
    beta, beta_star, ...
    kappa, L, gamma);

%% plot results

figure

% smoothing (Messdaten)
Sf_smooth = movmean(Sf_filtered_combined(:,target_section), 50, 'omitnan');

plot(T.time, Sf_smooth, 'r', 'LineWidth', 1.5)
hold on

% Manchester Modell
plot(T.time, friction_Mancester(:,target_section), 'b', 'LineWidth', 1.5)

legend( ...
    'Measured Data (filtered and smoothed)', ...
    sprintf('Manchester', u1, u2, u3), ...
    'Location', 'northwest' ...
)

xlabel('time')
ylabel('friction coefficient')
title('Gazoduc')

ylim([0 0.2])
grid on

% Parameter-Box rechts unter der Legende
text( ...
    0.80, 0.96, ...   % <-- Position rechts oben, unter Legend anpassen
    sprintf(['$u_1 = %.5f$\n' ...
             '$u_2 = %.2f$\n' ...
             '$u_3 = %.3f$\n' ...
             '$\\beta = %.1f$\n' ...
             '$\\beta^* = %.1f$\n' ...
             '$\\kappa = %.2f$\n' ...
             '$L = %.1f$\n' ...
             '$\\gamma = %.1f$'], ...
    u1, u2, u3, beta, beta_star, kappa, L, gamma), ...
    'Units','normalized', ...
    'VerticalAlignment','top', ...
    'BackgroundColor','white', ...
    'EdgeColor','black', ...
    'Interpreter','latex', ...
    'FontSize', 10 ...
)

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

%%
exportgraphics(gcf, fullfile(saveFolder, baseName + "_smoothed.png"), ...
    'Resolution', 300)

%%
difference = Sf_smooth - friction_Mancester(:,target_section);
diffi = Sf_filtered_combined(:,target_section)- - friction_Mancester(:,target_section);

SSE1 = nansum(difference.^2);
SSE2 = nansum(diffi.^2);

% Optional: safer date handling
dateStr = string(dateStr);
dateStr = replace(dateStr, "_", "-");   % optional cleanup

row = table( ...
    string(site), ...
    string(dateStr), ...
    SSE, ...
    'VariableNames', {'Station','Date','SSE'} );

% Append to results table
T_results_Manchester = [T_results_Manchester; row];

save('SSE_Manchester_results.mat', 'T_results_Manchester')

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