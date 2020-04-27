function remove = fRemove_Pause(XData, YData, Config)
warning off
ft = fittype( 'poly1' );
                
num = 1;

for i = Config.win_t+1 : length(XData) - Config.win_t

    % Fitting interval                  
    t1 = i-Config.win_t;
    t2 = Config.win_t + i;

    % Fit each comet position in time window to find the
    % velocity
    [FXData, FYData] = prepareCurveData( XData(t1:t2), YData(t1:t2) );
    fitresult = fit( FXData, FYData, ft );

    % Store result
    V_free(num)= fitresult.p1; % in nm/sec  
    num = num+1;
end

% Velocity tresholding: remove datapoints that fall
% below threshols of the mean of V_free
remove = find(V_free < Config.threshold * nanmean(V_free)); 
remove = remove + Config.win_t;

end