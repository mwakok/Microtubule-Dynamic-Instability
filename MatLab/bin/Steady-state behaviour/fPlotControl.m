fPlotControl(YData, YData_NaN);

Figure_settings;
hold on

plot(YData);
plot(Ytemp);
scatter(YData_NaN,YData(YData_NaN));

hold off