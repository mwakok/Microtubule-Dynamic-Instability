function range = fRange(XData, Ytemp,  remove, Options)


% Find the indices that are valid
ind = ~isnan(Ytemp);
if ~isempty(remove)
    % Collect the timepoints for all valid indices
    if ~isnan(Ytemp(1))
        ind = [0; find(abs(diff(ind))>0); length(XData)];
    else
        ind = [find(abs(diff(ind))>0); length(XData)];
    end


    range = [];
    for k = 1 : length(ind)/2          
        num = 2*k -1;

        range(k,1) = ind(num)+1;
        range(k,2) = ind(num+1);

    end

elseif length(XData)-Options.win_t-(Options.win_t +1) > Options.D_min                   
    range = [Options.win_t+1 length(XData)-Options.win_t];                 
else                   
    range = [0 0];
end

%%% Remove short growth events from fitting routine  
d = find(abs(range(:,2) - range(:,1)) < Options.D_min);
range(d,:) = [];

% Limit the range inside the timewindow
ind  = find(range(:,1) < Options.win_t);


if length(ind) == 1
    
    if range(1,1) < Options.win_t +1 && range(1,1) > 0 && range(1,2) > Options.win_t
        range(1,1) = Options.win_t + 1;       
    elseif range(1,1) < Options.win_t +1 && range(1,1) > 0
        range(1,:) = [];            
    end
    
    if ~isempty(range)
        if range(end,2) > length(XData)-Options.win_t && range(1,1) > 0
            range(1,1) = Options.win_t + 1;
        end
    end
end

%%% Remove short growth events from fitting routine  
d = find(abs(range(:,2) - range(:,1)) < Options.D_min);
range(d,:) = [];

end