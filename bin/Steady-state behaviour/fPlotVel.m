function fPlotVel(Input)


% Figure_settings;

% Collect 
Data_all = [];
Data_E = [];
Data_O = [];
for n = 1 : size(Input,2)
   
    Data_all = [Data_all Input{1,n}];  
    Data_E = [Data_E Input{2,n}]; 
    Data_O = [Data_O Input{3,n}];
    
end



% Fit the distributions

% Set up fittype and options.
ft = fittype( 'gauss1' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.Lower = [-Inf -Inf 0];
opts.StartPoint = [1500 50 100];

% 4 Hz
[A, B] = hist(Data_all,500);
[xData, yData] = prepareCurveData( B, A );
fitresult{1} = fit( xData, yData, ft, opts );

% 2 Hz - Even
[A, B] = hist(Data_E,500);
[xData, yData] = prepareCurveData( B, A );
fitresult{2} = fit( xData, yData, ft, opts );

% 2 Hz - Odd
[A, B] = hist(Data_O,500);
[xData, yData] = prepareCurveData( B, A );
fitresult{3} = fit( xData, yData, ft, opts );


% Plot the distribution and the corresponding fit
f = @(I_a,mu,sigma,x) I_a.*exp(-((x-mu)./sigma).^2);

figure;
subplot(1,3,1);
hold on
histogram(Data_all,500,'FaceColor',[0.7 0.7 0.7]);
plot(-500:1:500,f(fitresult{1}.a1,fitresult{1}.b1,fitresult{1}.c1,-500:1:500),...
     'LineWidth',1.5,'Color','r');
xlim([-500 500]);
xticks(linspace(-500,500,5));
xlabel('Inst. velocity (nm/min)');
ylabel('Counts');
title('4Hz');
hold off

subplot(1,3,2);
hold on
histogram(Data_E,500,'FaceColor',[0.7 0.7 0.7]);
plot(-500:1:500,f(fitresult{2}.a1,fitresult{2}.b1,fitresult{2}.c1,-500:1:500),...
     'LineWidth',1.5,'Color','r');

xlim([-500 500]);
xticks(linspace(-500,500,5));
xlabel('Inst. velocity (nm/min)');
% ylabel('Counts');
title('2Hz - Even');
hold off

subplot(1,3,3);
hold on
histogram(Data_O,500,'FaceColor',[0.7 0.7 0.7]);
plot(-500:1:500,f(fitresult{3}.a1,fitresult{3}.b1,fitresult{3}.c1,-500:1:500),...
     'LineWidth',1.5,'Color','r');
xlim([-500 500]);
xticks(linspace(-500,500,5));
xlabel('Inst. velocity (nm/min)');
% ylabel('Counts');
title('2Hz - Odd');
hold off

%Display the results
mu = (fitresult{2}.b1 + fitresult{3}.b1) / 2;
sigma = (fitresult{2}.c1 + fitresult{3}.c1) / 2;

string = strcat({'The mean velocity at 2Hz is'}, {' '}, num2str(mu),{' '},{'± '},num2str(sigma), {' nm/sec'});
display(string{1})


end