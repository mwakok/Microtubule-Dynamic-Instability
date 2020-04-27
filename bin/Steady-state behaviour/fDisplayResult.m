function fDisplayResult(Input,num)

%Function that displays the result of a calculation in the command window

% Display the mean growth velocity
if num == 1
    temp = Input;
    temp(isnan(temp(:,1)),:) = [];
    V(1) = sum(temp(:,2).*temp(:,1)) ./ sum(temp(:,2)); % weighted mean
    V(2) = sqrt((size(temp,1)./(size(temp,1)-1)).*(sum((temp(:,1)-V(1)).^2.*temp(:,2)) ./ sum(temp(:,2))));

    string = strcat({'The mean growth speed is'}, {' '}, num2str(V(1)),{' '},{'± '},num2str(V(2)), {' nm/sec'});
    display(string{1})

% Display the mean and std of the Intensity fluctuations
elseif num == 2
    
    temp1 = [];
    temp2 = [];
    
    % Collect all intensity fluctuations
    for n = 1 : size(Input,2)
       if ~isempty(Input{1,n})
            temp1 = [temp1 Input{1,n}(1,:)];
            temp2 = [temp2 Input{2,n}(1,:)];
       end
    end
    
    % Calculate mean comet
    V(1) = nanmean(temp1);
    % Calcualte the std comet
    V(2) = nanstd(temp1);
    % Calcualte the std fluctuations
    V(3) = nanstd(temp2);
    

    
    string = strcat({'The mean comet intensity is'}, {' '}, num2str(V(1)),{' '},{'± '},num2str(V(2)), {' a.u.'});
    display(string{1})
    string = strcat({'The mean comet fluctuation is'}, {' '},{'± '},num2str(V(3)), {' a.u.'});
    display(string{1})
    
% Display the velocity fluctuation per time bin
elseif num ==3

    temp = [];

end

end