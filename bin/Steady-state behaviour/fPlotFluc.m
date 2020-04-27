function fPlotFluc(Input)

I1 = [];
I2 = [];

for n = 1 : size(Input,2)
    
    I1 = [I1 Input{1,n}];
    I2 = [I2 Input{2,n}];

end
  


% Fit and plot the result 
figure;
subplot(1,2,1);
hold on
histogram(I1, 100, 'FaceColor', [0.7 0.7 0.7]);
xlabel('Intensity (a.u.)');
ylabel('Counts');
title('Comet intensity');
hold off

% Fit results
ft = fittype( 'gauss1' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.Lower = [-Inf -Inf 0];
opts.StartPoint = [1500 0 100];

bins = 100;

[A, B] = hist(I2,bins);
[xData, yData] = prepareCurveData( B, A );
fitresult = fit( xData, yData, ft, opts );

f = @(I_a,mu,sigma,x) I_a.*exp(-((x-mu)./sigma).^2);

subplot(1,2,2);
hold on
histogram(I2, bins, 'FaceColor',[0.7 0.7 0.7]);
plot(-2000:1:2000,f(fitresult.a1,fitresult.b1,fitresult.c1,-2000:1:2000),...
     'LineWidth',1.5,'Color','r');
xlim([-2000 2000]);
% xticks(linspace(-500,500,5));
xlabel('Intensity fluctuation (a.u.)');
ylabel('Counts');
title('Comet fluctuations');
hold off



end