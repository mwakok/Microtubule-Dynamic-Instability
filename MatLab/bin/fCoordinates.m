function Coordinates = fCoordinates(Data)
%%%------------------------------------------------------------------------
% Function to obtain the MT position at each timepoint based to manually
% traced events.
%
% Maurits Kok
% April 2019
%%%------------------------------------------------------------------------

% Check whether the Mapping Toolbox is installed

% Detect all installed MATLAB toolboxes
toolbox = ver;

% Loop over all installed toolboxes to find the "Mapping Toolbox"
detect_toolbox = 0;
for n = 1 : length(toolbox)    
    % If the toolbox is not present, then give warning and return
   if strcmp(toolbox(n).Name, 'Mapping Toolbox')
       detect_toolbox = 1;       
   end
end

if detect_toolbox == 0
    warning('"Mapping Toolbox" is not installed. Please install the toolbox via Apps - Get More Apps.')
    Coordinates = [];
    return
end

% Collect the X- and Y-coordinates
X = Data.Position;
Time = Data.Time;

% Verify that the coordinates are not empty
if isempty(X) || isempty(Time)
    Coordinates = [];
   return 
end

% Initialize output variable 
Coordinates = cell(1, length(X));

% Loop over the number of traced MT growth events
for n = 1 : length(X)
    
    % Collect all timepoints from a single events
    Coordinates{n}(:,1) = Time{n}(1):1:Time{n}(end);
    count = 2;
    
    % Loop over line segments of the traced event
    for i = 1: length(Time{n})-1
        
        % Find line segment
        x = [X{n}(i) X{n}(i+1)];
        t = [Time{n}(i) Time{n}(i+1)];
               
        count = count-1;
        if t(2) - t(1) > 0
            % Find all timepoints along the linesegment using the funciton
            % polyxpoly. This function requires the MATLAB module "Mapping Toolbox"
            for j = t(1): t(2)
                [Coordinates{n}(count,2), ~] = polyxpoly(x, t, [0 1000], [j j]);
                count = count +1;
            end
        else
            Coordinates{n}(count,:) = [t(1) x(1)]; 
            count = count + 1;
            Coordinates{n}(count,:) = [t(2) x(2)];
            count = count + 1;
        end
      
    end    

    % Correct Coordinates if it contains timepoints outside of size kymograph
    if Coordinates{n}(1,1) < 1
        ind = find(Coordinates{n}(:,1) < 1);
        Coordinates{n}(ind,:) = [];
    end
end
end