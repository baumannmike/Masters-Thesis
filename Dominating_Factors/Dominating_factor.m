close all
clear all
clc
%% Zum Verständnis
g = 9.81;
g_factor = 1./(g.*cosd(S0));

T1 = tand(S0);
T2 = dz_dy;
T3 = g_factor.*dv_dt;
T4 = g_factor.*v.*dv_dy;

%%

Sf = T1 - T2(:,target_section) - T3(:,target_section) - T4(:,target_section)

% Welche Komponente erklärt die zeitliche Streuung von Sf am stärksten?

C2 = -T2(:,target_section);
C3 = -T3(:,target_section);
C4 = -T4(:,target_section);

C = [C2 C3 C4];

valid = ~isnan(C2) & ~isnan(C3) & ~isnan(C4);

C_common = C(valid,:);

dom = var(C_common,0,1);
dom = dom / sum(dom);

%%
station = "Gazoduc";  
eventDate = "2025-08-20";

%%
load('Sf_dominance.mat','T')

newRow = table();
newRow.Station   = station;
newRow.EventDate = eventDate;
newRow.T2 = dom(1);
newRow.T3 = dom(2);
newRow.T4 = dom(3);

T = [T; newRow];

save('Sf_dominance.mat','T')

%%

T = table();

T.Station = station;
T.EventDate = eventDate;

T.T2 = dom(1);
T.T3 = dom(2);
T.T4 = dom(3);

save('Sf_dominance.mat','T')

%%

figure('Color','w','Position',[100 100 1400 500])

X = [T.T2 T.T3 T.T4];

b = bar(X,'stacked','LineStyle','none');

% =========================
% 🎨 SCIENTIFIC COLOR SET
% =========================
b(1).FaceColor = [0.00 0.45 0.74];   % T2 = dz/dy (geometry / slope)
b(2).FaceColor = [0.85 0.33 0.10];   % T3 = dv/dt (unsteady)
b(3).FaceColor = [0.47 0.67 0.19];   % T4 = v dv/dy (advection)

ylabel('Relative contribution')
xlabel('Event')

ylim([0 1])

% =========================
% LEGEND (clean + physical)
% =========================
legend(b, { ...
    'T2 = dz/dy (slope)', ...
    'T3 = (1/g cosS0) dv/dt', ...
    'T4 = (1/g cosS0) v dv/dy' ...
}, 'Location','eastoutside')

% =========================
% AXES FORMATTING
% =========================
grid on
box on

xticks(1:height(T))
xticklabels(T.EventDate)
xtickangle(90)

% =========================
% STATION SEPARATION
% =========================
xline(9.5,'k-','LineWidth',2,'HandleVisibility','off')
xline(17.5,'k-','LineWidth',2,'HandleVisibility','off')

% =========================
% STATION LABELS
% =========================
text(5,1.05,'CD27','HorizontalAlignment','center', ...
    'FontWeight','bold','FontSize',12)

text(13.5,1.05,'CD29','HorizontalAlignment','center', ...
    'FontWeight','bold','FontSize',12)

text(22.5,1.05,'Gazoduc','HorizontalAlignment','center', ...
    'FontWeight','bold','FontSize',12)