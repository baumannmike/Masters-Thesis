clc
clear all
close all

addpath(genpath('\\Mac\Home\Documents\MATLAB\ambizione-foundation-data-generation\Tools'));
addpath(genpath('\\Mac\Home\Documents\MATLAB\ambizione-foundation-data-generation\Utilites'));
%% load data
mountVar = 'X';
catchment = 'ILL'; 
year = '2024';
date = '2024_06_21a';
location = 'CD29'; 
sensor_1 = 'Bloom'; 
sensor_2 = 'Pip';
 
cross_section_folder = fullfile(sprintf('%s:',mountVar),...
    '01_Projects','01_Ambizione','UncompressData',...
    catchment,...
    'Events',...
    year,...
    date,...
    location,...
    '03_ProcessedData', ...
    'cross_section_results');

load(fullfile(cross_section_folder,'Cross_Section_Raw.mat')); 
load(fullfile(cross_section_folder,'Cross_Section_Basal_Friction.mat')); 
load(fullfile(cross_section_folder,'Cross_Section_Information.mat'));
load(fullfile(cross_section_folder,'Cross_Section_Aggregates.mat'));

beep;
%% define inputs
alpha=0.7;
S0_new = 5;%5.2;
vel_cutoff = 0.1; % m/s
depth_cutoff = 0.3; % m
dz_dy_new = dz_dy-tand(S0)+tand(S0_new);
surface_inclination = dz_dy-tand(S0);
vel_smooth_length = 23;
golayPolyOrder=3;

name = sprintf('%s_Width_average_alpha_correct_surface_incl_%0.2f_S0_%0.2f.mat',location,alpha,S0_new);
filename = fullfile(cross_section_folder,name);


%% display sections
figure
target_frame = 18088;
plot(width_flow_pre(target_frame,:))
ylabel('flow width (m)')
yyaxis right
plot(section_averaged_vel(target_frame,:))
ylabel('flow velocity (m/s)')
xlabel('distance along section (m)')
title('plot of flow width and velocity to choose good sections')

target_section = 25;
interesting_sections = [20:30];


%% plot overview figure
index = 300;
ptCldFilePart = fullfile(sprintf('%s:',mountVar),...
    '01_Projects','01_Ambizione','UncompressData',...
    catchment,...
    'Events',...
    year,...
    date,...
    location,...
    '02_PreProcessedData', ...
    'ptClouds_ply',...
    sprintf('%s_%s_merge',sensor_1,sensor_2));
currFrame = pcread(fullfile(ptCldFilePart,sprintf('%0.5d.ply',index)));
z_cutoff = -0.5;
indices = currFrame.Location(:,3)<z_cutoff;
currFrame = select(currFrame,indices);
azimuth = 0;
altitude = 135;
xLim = [-15 15];
yLim = [-20 40];
spacing=0.1;

[H,xRange,yRange, interpolatedPtCloud,F] = createScanHillshade_Azimuth_Elevation(currFrame,spacing,xLim,yLim,azimuth,altitude);
frame = mat2gray(H);
R = imref2d(size(frame),xLim,yLim);
spacing2 = 1;
[Xq,yQ] = meshgrid(min(xLim):spacing2:max(xLim),min(yLim):spacing2:max(yLim));

figure
imshow(frame,R)

hold on
% vel_frame = CD29.vel.vel_depth_TT(index,:);
% pos = squeeze(vel_frame.world_coords_xyz);
% vel = squeeze(vel_frame.world_velocity_xyz_smooth);
% quiver(pos(:,1),pos(:,2),vel(:,1),vel(:,2));
long_section_line=params.Cross_Section_settings.long_section;
plot(long_section_line(:,1),long_section_line(:,2),'-b','LineWidth',3)
for i=1:length(section_lines)

    curr_line = section_lines{i};
    plot(curr_line(:,1),curr_line(:,2),'-k','LineWidth',0.25);
    text(0,curr_line(end,2),sprintf('%d',i),'Color','k','FontSize',30);
end
%% estimate parameters
%% cross sectional area, width, depth
[cross_sectional_area,width,depth,depth_mean] = get_cross_section_area_width_rm_outliers(...
    params.Cross_Section_settings.horiz_spacing,...
    section_velocity_smooth,...
    base_topo,...
    surface_points_interp,...
    0.3,...
    0.3);

%% velocities
[section_averaged_vel,...
    section_averaged_vel_smooth,...
    width_average_vel,...
    width_average_vel_smooth,...
    max_vel] = ...
    get_section_averaged_vel_smooth_widthav(section_velocity_smooth,...
    base_topo,...
    surface_points_interp,...
    vel_smooth_length,...
    golayPolyOrder,....
    depth_cutoff);
%% Estimate spatial and temporal velocity derivatives
smoothing_length_vel = 5;
smoothing_length_vel_2 = 5;
[dv_dy_widthAv,...
    dv2_dy2_widthAv,...
    dv_dt_widthAv,...
    section_averaged_vel_alpha] = get_section_avg_derivs(distance_along_section,...
    width_average_vel_smooth,...
    alpha,...
    smoothing_length_vel,...
    smoothing_length_vel_2,...
    params.Cross_Section_settings.num_sections);
%% estimate spatial and temporal derivs linear fit
% smoothing_length_vel = 5;
% smoothing_length_vel_2 = 5;
% [dv_dy_widthAv,...
%     dv2_dy2_widthAv,...
%     dv_dt_widthAv,...
%     section_averaged_vel_alpha]= get_section_avg_derivs_vect(distance_along_section,...
%     width_average_vel_smooth,...
%     alpha,...
%     smoothing_length_vel,...
%     smoothing_length_vel_2,...
%     params.Cross_Section_settings.num_sections,...
%     interesting_sections);

%% estimate spatial and temporal derivs linear fit

[dz_dy_depth,...
    ~,...
    ~,...
    ~]= get_section_avg_derivs_vect(distance_along_section,...
    depth_mean,...
    1,...
    101,...
    smoothing_length_vel_2,...
    params.Cross_Section_settings.num_sections,...
    interesting_sections);

dz_dy=dz_dy_depth;
%% Estimate basal friction
good_ind_dz_dy=-0.015;
good_ind_dv2_dy_max=0.2;
good_ind_dv2_dy_min= -0.105;
good_ind_dv_dy_max=-0.5;%-0.07;
good_ind_dv_dy_min=0.85;
S0_new = 5;
[Sf, T1,T2,T3,T4] = get_basal_friction_second_deriv_filter_correct_incl(S0_new,...
     dz_dy,...
    S0,...
    width_average_vel_smooth.*alpha,...
    dv_dy_widthAv,...
    dv_dt_widthAv,...
    dv2_dy2_widthAv,...
    good_ind_dz_dy,...
    good_ind_dv2_dy_max,...
    good_ind_dv2_dy_min,...
    good_ind_dv_dy_max,...
    good_ind_dv_dy_min);

%% estimate Froude numbers
g=9.81;
froude = width_average_vel_smooth.*alpha./ ...
    sqrt(depth.*cosd(S0_new).*g);
froude(froude<0) = NaN;


%% Filtering

Sf_orig = Sf;  

% Filter Surface Inclination
dz_dy_test = plot_dz_dy(:,target_section);
dz_dy_smooth = movmean(dz_dy_test, 100);
diff_dz = dz_dy_test - dz_dy_smooth;

dz_thresh = 0.005;
peak_dz = abs(diff_dz) > dz_thresh;

Sf_filtered_dz = Sf_orig;
Sf_filtered_dz(peak_dz,:) = NaN;

% Plot Surface Inclination Filter
figure('Color','w','Position',[100 100 900 300])
plot(time, Sf_filtered_dz(:,target_section), 'b', 'LineWidth',1.5)
xlabel('Time')
ylabel('Friction Coefficient')
title('Sf filtered by Surface Inclination')
ylim([0 0.2])

% Filter dv/dt
dv_dt_test = dv_dt_widthAv(:,target_section);
dv_dt_smooth = movmean(dv_dt_test, 100);
diff_dvdt = dv_dt_test - dv_dt_smooth;

dvdt_thresh = 3;   % <- musst du evtl. anpassen!
peak_dvdt = abs(diff_dvdt) > dvdt_thresh;

Sf_filtered_dvdt = Sf_orig;
Sf_filtered_dvdt(peak_dvdt,:) = NaN;

figure('Color','w','Position',[100 100 900 300])
plot(time, Sf_filtered_dvdt(:,target_section), 'm', 'LineWidth',1.5)
xlabel('Time')
ylabel('Friction Coefficient')
title('Sf filtered by dv/dt')
ylim([0 0.2])

% Filter dv/dy
dv_dy_test = dv_dy_widthAv(:,target_section);
dv_dy_smooth = movmean(dv_dy_test, 100);
diff_dv = dv_dy_test - dv_dy_smooth;

dv_thresh = 0.015;
peak_dv = abs(diff_dv) > dv_thresh;

Sf_filtered_dv = Sf_orig;
Sf_filtered_dv(peak_dv,:) = NaN;

% Plot dv/dy Filter
figure('Color','w','Position',[100 100 900 300])
plot(time, Sf_filtered_dv(:,target_section), 'g', 'LineWidth',1.5)
xlabel('Time')
ylabel('Friction Coefficient')
title('Sf filtered by dv/dy')
ylim([0 0.2])

% Combined Filter
combined_peaks = peak_dz | peak_dv | peak_dvdt;
Sf_filtered_combined = Sf_orig;
Sf_filtered_combined(combined_peaks,:) = NaN;

% Plot Combined Filter
figure('Color','w','Position',[100 100 900 300])
plot(time, Sf_filtered_combined(:,target_section), 'r', 'LineWidth',1.5)
xlabel('Time')
ylabel('Friction Coefficient')
title('Sf filtered by Surface Inclination + dv/dy')
ylim([0 0.2])


%% do some plotting
% interesting_sections = [35:45];
% target_section = 22;
index = 4;
% figure
t0 = [datetime(2023,04,28,23,27,49,352) datetime(2023,06,02,19,49,10,150) datetime(2023,07,12,05,31,17,1273) datetime(2023,07,13,01,57,13,39) datetime(2023,11,14,17,29,39)];
time = seconds((1:length(depth(:,target_section)))./10)-seconds(1)+t0(index);
plot_dz_dy = dz_dy-tand(S0);
%%plot all SF terms
figure
tiledlayout(7,1)
ax1 = nexttile;
plot(time,Sf_filtered_combined(:,target_section))
ylim([0.0 0.2]);

title('Sf')
ax2 = nexttile;
plot(time,T2(:,target_section))
hold on
yline(good_ind_dz_dy)
title('dz_dy')

ax3 = nexttile; 
plot(time,plot_dz_dy(:,target_section)) 
hold on 
yline(-tand(S0_new))
title('surface inclination')

ax4 = nexttile;
plot(time,dv_dy_widthAv(:,target_section))
hold on
yline(good_ind_dv_dy_max)
yline(good_ind_dv_dy_min)
title('dv_dy')

ax5 = nexttile;
plot(time,dv2_dy2_widthAv(:,target_section))
hold on
yline(good_ind_dv2_dy_max)
yline(good_ind_dv2_dy_min)
title('dv2_dy2')

ax6 = nexttile;
plot(time,width_average_vel(:,target_section))
hold on
plot(time,width_average_vel_smooth(:,target_section))
hold on
title('vel')

ax7 = nexttile;
plot(time,dv_dt_widthAv(:,target_section))
title('dv_dt')

linkaxes([ax1 ax2 ax3 ax4 ax5 ax6 ax7],'x')
movegui(gca, [0 0])
%% plot terms
% interesting_sections = [35:45];
% target_section = 23;
index = 1;
% figure
t0 = [datetime(2023,04,28,23,27,49,352) datetime(2023,06,02,19,49,10,150) datetime(2023,07,12,05,31,17,1273) datetime(2023,07,13,01,31,35,18) datetime(2023,11,14,17,29,39)];
time = seconds((1:length(depth(:,target_section)))./10)-seconds(1)+t0(index);
%%plot all SF terms
figure
tiledlayout(5,1)
ax1 = nexttile;
plot(time,T1(:,target_section))
yline(tand(S0_new))
% ylim([0.05 0.3]);

title('T1')
ax2 = nexttile;
plot(time,T2(:,target_section))
hold on
% yline(good_ind_dz_dy)
title('T2')

ax3 = nexttile;
plot(time,T3(:,target_section))
hold on

title('T3')

ax4 = nexttile;
plot(time,T4(:,target_section))
hold on
yline(good_ind_dv_dy_max)
yline(good_ind_dv_dy_min)
title('T4')

ax5 = nexttile;
plot(time,Sf(:,target_section))
ylim([0.05 0.3]);

title('Sf')
linkaxes([ax1 ax2 ax3 ax4 ax5],'x')

%% plot terms 2
target_section = 23;
index = 1;
% figure
t0 = [datetime(2023,04,28,23,27,49,352) datetime(2023,06,02,19,49,10,150) datetime(2023,07,12,05,31,17,1273) datetime(2023,07,13,01,31,35,18) datetime(2023,11,14,17,29,39)];
time = seconds((1:length(depth(:,target_section)))./10)-seconds(1)+t0(index);
%%plot all SF terms
figure
plot(time,T2(:,target_section))
hold on
plot(time,T3(:,target_section))
plot(time,T4(:,target_section))

yyaxis right
plot(time,Sf(:,target_section))
ylim([0.05 0.3]);

legend({'T2','T3','T4','Sf'})
%% save
save(filename,...
    'target_section','long_section_line','section_lines','interesting_sections',...
    'S0_new','alpha','surface_inclination',...
    'section_averaged_vel','section_averaged_vel_smooth','width_average_vel_smooth',...
    'dz_dy_new','dv_dy_widthAv','dv2_dy2_widthAv','dv_dt_widthAv','section_averaged_vel_alpha',...
    'Sf','T1','T2','T3','T4',...
    'cross_sectional_area','width_flow_pre','depth','perimeter',...
    'froude', ...
    '-v7.3');

%% discharge
figure
plot(time,discharge(:,interesting_sections));
xlim([datetime(2023,04,29,00,05,00,00) datetime(2023,04,29,1,30,0,0)])
%% Sf
% framelen=5;
% plot_sf = movmean(Sf(:,interesting_sections),framelen,'omitnan');

figure
plot(time,mean(Sf(:,interesting_sections),2,'omitnan'));
% plot(CD27_time,Sf(:,interesting_sections));
ylim([0.05 0.15]);

%  legendCell = cellstr(num2str(interesting_sections', 'N=%-d'));
%  legend(legendCell)

% xlim([datetime(2023,04,29,00,05,00,00) datetime(2023,04,29,1,30,0,0)])


%% SF_Froude hyd rad
target_section = 33;
figure
font_size=20;
upper_lim = 0.2;
lower_lim = 0.05;

CD27_colors = Sf(:,target_section);
CD27_colors(CD27_colors < lower_lim) = nan;
CD27_colors(CD27_colors>upper_lim) = nan;

scatter(froude(:,target_section),depth(:,target_section),[],CD27_colors,'filled','square');
xlabel('Froude Number','FontSize',font_size)
ylabel('Hydraulic Depth (m)','FontSize',font_size)
cb = colorbar();
ylabel(cb,'Friction Coefficient','FontSize',font_size)


%% SF Vel
target_section = 31;
figure
font_size=20;
upper_lim = 0.2;
lower_lim = 0.05;

CD27_colors = Sf(:,target_section);
CD27_colors(CD27_colors < lower_lim) = nan;
CD27_colors(CD27_colors>upper_lim) = nan;

scatter(width_average_vel_smooth(:,target_section),Sf(:,target_section));
ylabel('Friction Coefficient','FontSize',font_size)
xlabel('Velocity','FontSize',font_size)

%% SF Froude
target_section = 33;
figure
font_size=20;
upper_lim = 0.2;
lower_lim = 0.05;

CD27_colors = Sf(:,target_section);
CD27_colors(CD27_colors < lower_lim) = nan;
CD27_colors(CD27_colors>upper_lim) = nan;

scatter(froude(:,target_section),Sf(:,target_section));
ylabel('Friction Coefficient','FontSize',font_size)
xlabel('froude','FontSize',font_size)

