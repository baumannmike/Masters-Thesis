clc
clear all
close all
%% test for Gazo
addpath(genpath('\\Mac\Home\Documents\MATLAB\ambizione-foundation-data-generation\Rheology Analysis\Tools\Rheologies'))

%% Parameters (as suggested by Prof)
tau_y = 500; % N/m^2 500 - 1500
eta = 400; % 400
n = 0.7; % 0.5 - 1

% Build parameter structure
param_struct.width_averaged_vel = width_average_vel_smooth * 0.7;
param_struct.depth = depth;
param_struct.S0 = S0;

% Model call
mu_powerlaw = get_powerlaw_frict_coef(param_struct, tau_y, eta, n);

%% plot results

Sf_smooth = movmean(Sf_filtered_combined(:,target_section), 50, 'omitnan');

figure

plot(T.time, Sf_smooth, 'r', 'LineWidth',1.5)
hold on
plot(T.time, mu_powerlaw(:,target_section), 'b', 'LineWidth',1.5)

legend( ...
    'Measured Data (filtered and smoothed)', ...
    sprintf('Power-law ($n = %.2f$, $\\tau_y = %.0f$, $\\eta = %.0f$)', ...
            n, tau_y, eta), ...
    'Interpreter','latex', ...
    'Location','northwest')

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

exportgraphics(gcf, fullfile(saveFolder, baseName + "_smoothed.png"), ...
    'Resolution', 300)

%%
load('SSE_powerlaw_results.mat', 'T_results_powerlaw');

difference = Sf_smooth - mu_powerlaw(:,target_section);

SSE = nansum(difference.^2);

dateStr = string(dateStr);
dateStr = replace(dateStr, "_", "-");

row = table( ...
    string(site), ...
    string(dateStr), ...
    SSE, ...
    'VariableNames', {'Station','Date','SSE'} );

T_results_powerlaw = [T_results_powerlaw; row];

save('SSE_powerlaw_results.mat', 'T_results_powerlaw')

