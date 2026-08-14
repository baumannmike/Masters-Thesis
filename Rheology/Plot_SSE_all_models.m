% X-Achse als Kategorien
xLabels = categorical(T_results.Station + " | " + string(T_results.Date));

figure

% Gestapelte Balken
bar(xLabels, [T_results.SSE, T_results_Manchester.SSE], 'BarWidth', 1.5)

% Achsen
ylabel('SSE')
xlabel('Station | Date')
title('Friction Model Comparison: Manchester vs. Voellmy')

% Y-Achse begrenzen
ylim([0 170])

% Styling
grid on
xtickangle(90)

legend('Voellmy','Manchester','Location','northwest')

%%
diffSSE = T_results.SSE - T_results_Manchester.SSE;

figure
bar(xLabels, diffSSE)

ylabel('SSE Difference (Voellmy - Manchester)')
title('SSE Difference Between Rheological Models (Voellmy − Manchester)')
grid on
xtickangle(90)

ylim([-50 100])
yline(0,'k-')

% positiv = manchester gewinnt

%%

% X-Achse als Kategorien
xLabels = categorical(T_results.Station + " | " + string(T_results.Date));

figure

% Gestapelte Balken
bar(xLabels, [T_results.SSE, T_results_Manchester.SSE, T_results_powerlaw.SSE], 'BarWidth', 1.5)

% Achsen
ylabel('SSE')
xlabel('Station | Date')
title('Friction Model Comparison: Manchester, Voellmy, Powerlaw')

% Y-Achse begrenzen
ylim([0 170])

% Styling
grid on
xtickangle(90)

legend('Voellmy','Manchester','Power Law','Location','northwest')


%%

% X-Achse als Kategorien
xLabels = categorical(T_results_powerlaw.Station + " | " + string(T_results_powerlaw.Date));

figure

% Gestapelte Balken
bar(xLabels, [T_results_powerlaw.SSE], 'BarWidth', 0.6, 'FaceColor', [0.60 0.80 1.00])

% Achsen
ylabel('SSE')
xlabel('Station | Date')
title('Friction Model: Powerlaw')

% Y-Achse begrenzen
ylim([0 300])

% Styling
grid on
xtickangle(90)

hold on

n1 = sum(strcmp(T_results_powerlaw.Station,'CD27'));
n2 = sum(strcmp(T_results_powerlaw.Station,'CD29'));

xline(n1+0.5, '--k', 'LineWidth', 1.2)
xline(n1+n2+0.5, '--k', 'LineWidth', 1.2)


exportgraphics(gcf, 'SSE_Powerlaw.png', 'Resolution', 300)

%%

% X-Achse als Kategorien
xLabels = categorical(T_results.Station + " | " + string(T_results.Date));

figure
set(gcf,'Color','w')

% Bar Plot (2 Modelle)
b = bar(xLabels, [T_results.SSE, T_results_Manchester.SSE], 'BarWidth', 1.6);

% Farben (Nature-style, consistent blues)
b(1).FaceColor = [0.15 0.35 0.75];   % Voellmy (dunkelblau)
b(2).FaceColor = [0.35 0.65 0.95];   % Manchester (heller blau)

% Achsen
ylabel('SSE')
xlabel('Station | Date')
title('Friction Model Comparison: Voellmy vs Manchester')

ylim([0 170])

% Grid & Styling
grid on
xtickangle(90)

% Legend
legend({'Voellmy','Manchester'}, 'Location','northwest')

hold on

% -----------------------------
% Station boundaries (correct dataset!)
% -----------------------------
stations = string(T_results.Station);

n1 = sum(stations == "CD27");
n2 = sum(stations == "CD29");

xline(n1 + 0.5, '--k', 'LineWidth', 1.2, 'HandleVisibility','off')
xline(n1 + n2 + 0.5, '--k', 'LineWidth', 1.2, 'HandleVisibility','off')

exportgraphics(gcf, 'FCM.png', 'Resolution', 300)
