%% Set up the figure properties
fig = figure(1);
fig.PaperPositionMode = 'manual';
fig.PaperUnits = 'inches';
fig.Units = 'inches';
fig.PaperPosition = [0, 0, 8, 5];
fig.PaperSize = [8, 5];
fig.Position = [0.1, 0.1, 7.9, 4.9];
fig.Resize = 'off';
fig.InvertHardcopy = 'off';
fig.Color = [1,1,1];

% Set up the axes properties
ax = gca;
% ax.ColorOrder = colors;
ax.FontName = 'Tahoma';
ax.Title.Interpreter = 'TeX';
ax.XLabel.Interpreter = 'TeX';
ax.YLabel.Interpreter = 'TeX';
ax.TickLabelInterpreter = 'TeX';
ax.Box = 'off';
ax.LineWidth = 1.5;
ax.FontSize = 12;  

%% Add to analysis script:
% ax.XLim = [0, 150];
% ax.YLim = [500, 3500];
% ax.XTick = linspace(0, 150, 6); 
% ax.YTick = linspace(0, 150, 6);  
% ax.XLabel.String = 'Time (s)';
% ax.YLabel.String = 'Intensity (a.u.)';