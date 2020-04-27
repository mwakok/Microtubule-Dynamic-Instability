function G_free = fVelocity(XData, YData, range, Config)

    % Set fittype to linear
    ft = fittype( 'poly1' );
    
    
    for k = 1 : size(range,1)
        
        % Fit each certified range of timepoints
        [FXData, FYData] = prepareCurveData( XData(range(k,1):range(k,2)), YData(range(k,1):range(k,2)) );
        fitresult = fit( FXData, FYData, ft );

        % Store duration of each steady-state event
        Output(k,1) = XData(range(k,2)) - XData(range(k,1));
        % Store the velocity of each steady-state event
        Output(k,2) = fitresult.p1;    
    end
    
    % Optional plotting of the fitting result
    if Config.Plot == 1
        
        Figure_settings;
        hold on
        % plot the fitting result    
        plot(fitresult, XData(range(k,1):range(k,2)), YData(range(k,1):range(k,2)),'k.');

        ax.XLabel.String = 'Time (sec)';
        ax.YLabel.String = 'Length (nm)';
%         title(strrep(Name_Event{select(n)},'.txt',''),'Interpreter','none');

        ylim([0 Inf]);
        legend('off');
        
        hold off
        
        if Config.Save == 1
             Str = strrep(Name_Event{select(n)},'.txt','.png');
             file = strcat(SaveFolder,'\',Str);

             print(file,'-dpng');           
        end        
%         close(fig) ;
        
    end
    
    % Calculate the mean growth speed
    if ~isempty(Output)       
        G_free(1) = sum(Output(:,1).*Output(:,2)) / sum(Output(:,1));  
        G_free(2) = sum(Output(:,1));
    else 
        G_free(1) = NaN;
        G_free(2) = NaN;
    end    

    

end