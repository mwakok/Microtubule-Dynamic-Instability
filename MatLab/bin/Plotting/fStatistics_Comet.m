function fStatistics(Position_MT, Position_EB)

figure
%% Plot histogram of EB comet maximum values
subplot(2,2,1)
hold on
Intensity = [];
for n = 1 : length(Position_EB)
   Intensity = [Intensity; Position_EB{1,n}(:,4)];
end
histogram(Intensity);

hold off

%% Plot histogram growth fluctuations
subplot(2,2,2)
hold on



hold off

%% Plot mean MT end profile
subplot(2,2,3)
hold on


hold off

%% Plot mean EB comet profile
subplot(2,2,4)
hold on


hold off
end