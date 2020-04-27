function Output = fParameters(Data, Config)
%%%------------------------------------------------------------------------
% Function to calculate the following microtubule dynamic instability
% parameters:
%
% 1) Microtubule length
% 2) Microtubule age
% 3) Catastrophes
% 4) Rescues
% 5) Contact duration (optional) 
% 6) Growth Speed 
% 7) Shrinkage Speed
% 8) Nucleation duration (not yet implemented)
%
% Maurits Kok
% April 2019

%%%------------------------------------------------------------------------

% Collect individual parameters
X = Data.Position;
Time = Data.Time;
PixelSize = Config.PixelSize;
FrameTime = Config.FrameTime;
Barrier = Config.Barrier;
Barrier_window = Config.Barrier_Width;
Coordinates = Data.Coordinates;

% Verify that input is not empty, otherwise return empty output
if isempty(X) || isempty(Time) || isempty(Coordinates)
   Output = [];
   return
end

% Initialize output variables
Catastrophe_num = zeros(length(X),2); 
Contact = cell(length(X),1);
Contact_duration = cell(length(X),1); 

% Loop through each MT growth event
for n = 1 : length(X)
    
    %%%--------------------------------------------------------------------
    % 1) MICROTUBULE LENGTH
    % Difference between minimum and maximum microtubule position,
    % regardless of number of catastrophes/rescues
    MT_length(n,1) = abs(diff([max(X{n}) min(X{n})])) * (PixelSize / 1000); % in um
    
    % Length of each line segment of the event 
    refDistance{n,1} = diff(X{n}(:,1)); % in pixels
    
    %%%--------------------------------------------------------------------
    % 2) TOTAL EVENT DURATION
    % Duration of each MT growth event, regardless of number of catastrophes/rescues
    Event_Time(n,1) = abs(diff([max(Time{n}) min(Time{n})])) * (FrameTime / 1000); % in seconds  
    
    % Duration of each line segment of the event
    refTime{n,1} = diff(Time{n}(:,1)); % in pixels   
        
    %%%--------------------------------------------------------------------
    % 3) IDENTIFY CATASTROPHES
    % A catastrophe is defined as the transition between MT growth and
    % shrinkage, regardless of the shrinkage speed. 
    % TODO: set threshold on shrinkage speed before considering the
    % transition to be a catastrophe.
    
    % Calculate the relative growth between each line segment
    D1 = diff(X{n});   
    
    % Change sign if the first growth event is negative. It is assumed that
    % growth is towards the right and shrinkage towards the left in the
    % kymograph, i.e. no event can start with shrinkage.
    if D1(1) < 0
        D1 = D1.*-1;
    end
    
    % Find all negative growth events, i.e. MT shortening
    D2 = find(D1 < 0);
    
    % If a single MT shortening event is present
    if isempty(find(diff(D2) > 1)) && ~isempty(D2) % In the case of only one catastrophe event
        Catastrophe{n,1}(1,1) = Time{n}(min(D2));    % in pixels
        Catastrophe{n,1}(1,2) = X{n}(min(D2));       % in pixels
        
    % If more than 1 catastrophe is present in the event trace
    elseif length(find(diff(D2) > 1)) >= 1 && ~isempty(D2)         
       
        % Find all non-consecutive shortening events, e.g. multiple
        % sequential shortening events are conseridered to be initiated by
        % a single catastrophe.
        num = (find(diff(D2) > 1))+1;
        num = [1; num];
        
        % Loop over all indentified catastrophes
        for i = 1 : length(num)
            % Store location of catastrophes
            Catastrophe{n,1}(i,1) = Time{n}(D2(num(i)));
            Catastrophe{n,1}(i,2) = X{n}(D2(num(i)));         
        end

    % If no MT shortening events are present, return an emtpy output
    % variable
    elseif isempty(D2)
        Catastrophe{n,1} = [];

    end
    
    % Store the number of catastrophes in the event
    Catastrophe_num(n,1) = size(Catastrophe{n,1},1);

    %%%--------------------------------------------------------------------     
    % 4) IDENTIFY RESCUES
    % A rescue is defined as the transition between MT shortening and growth, 
    % regardless of the growth speed. 
    % TODO: set threshold on growth speed before considering the
    % transition to be a rescue.
    
    % Proceed if MT shortening is present in the event trace
    if ~isempty(D2)          
        
        % Loop over all shortening events
        for i = 1 : length(D2)    
            
            % If shrinkage is last and only line segment, then no rescue
            if length(D2) == 1 && D2(i) == length(D1)  
                Rescue{n,1} = [];
            % If shrinkage is last line segment, then no rescue    
            elseif length(D2) > 1 && D2(i) == length(D1)
            % If shrinkage is followed by growth, then identify as a rescue   
            elseif D1(D2(i)+1) > 0 && D2(i) ~= length(D1) 
                % Store location of rescues
                Rescue{n,1}(i,1) = Time{n}(D2(i)+1);
                Rescue{n,1}(i,2) = X{n}(D2(i)+1);            
            else
                Rescue{n,1} = [];        
            end
            
        end
        
    % If no MT shortening is present in the event trace, return an empty
    % output
    else
        Rescue{n,1} = [];
    end
    
    % Store the number of rescues in the event
    Rescue_num(n,1) = size(Rescue{n,1},1);
    
    %%%--------------------------------------------------------------------
    % 5) FREE GROWTH TIME
    % Free growth time is defined as all line segments that show positive
    % MT growth, i.e. not shrinking, pausing, or stalling. This parameter
    % is required to calculate the the catastrophe frequency.
    
    % Find all line segments with positive MT growth
    ind = find(D1 > 0); 
    % Store the free growth time
    Growth_Time(n,1) = sum(refTime{n,1}(ind)) * (FrameTime / 1000); % in seconds
    
    
    % If you want to calculate the distribution of MT lifetimes, you can
    % only use complete events, i.e. events that start growing from the
    % seed and shrink back to the seed. In order to check whether the
    % traced event is in fact complete, it is required that the first and
    % last position of the trace is within a certain margin. This margin
    % reflects the error in properly locating the seed.
     
    % Set margin, i.e. number of pixels within which event has to start and
    % end, i.e. error in locating the seed    
    margin = 5;
    
    % !! Events with multiple catastrophes are currently excluded from the 
    % lifetime distribution. Also, lifetime distributions are meaningless if
    % barrier-contact events are present, as these induce a catastrophe.
    
    % Verify the presence of a catastrophe and the absence of a barrier
    if ~isempty(Catastrophe{n,1}) && Barrier == 0
        
        % If the event fulfills the requirement of starting and finishing
        % with a set number of pixels defined by the margin, then save as
        % lifetime
        if size(Catastrophe{n,1},1) == 1 && abs(Coordinates{1,n}(1,2) - Coordinates{1,n}(end,2)) <= margin
            Lifetime(n,1) = Growth_Time(n,1);
            
        % If the event does not fulfill the requirement    
        elseif  size(Catastrophe{n,1},1) > 1 && abs(Coordinates{1,n}(1,2) - Coordinates{1,n}(end,2)) <= margin
            Lifetime(n,1) = NaN;
        else
            Lifetime(n,1) = NaN;
        end
    else
        Lifetime(n,1) = NaN;
    end
    
    %%%--------------------------------------------------------------------
    % 6) SHRINKAGE TIME
    % Total duration of MT shortening. This is required to calculate the
    % rescue frequency.
    
    % Find all negative MT growth 
    ind = find(D1 < 0); 
    % Store the duration of all negative growth.
    Shrinkage_Time(n,1) = sum(refTime{n,1}(ind)) * (FrameTime / 1000); % in seconds
    
    %%%--------------------------------------------------------------------
    % 7) CONTACT DURATION
    % Calculate the duration of MT-barrier contact. For now, this only finds 
    % all events that have a growth speed equal to zero and are within xx 
    % pixels (defined by Barrier_window) of the maximum MT length of that event. 
        
    % Proceed if barriers are present (user input)
    if Barrier == 1
        
        % Find all line segments with zero growth, i.e. pausing events
        ind = find(D1 == 0);
        % Check whether these pauses are with the margin surrounding the max
        % length of the MT. 
        ind2 = abs(max(X{n}) - X{n}(ind)) < Barrier_window;
%         Contact(n,1) = sum(refTime{n,1}(ind(ind2)).*(FrameTime / 1000));
        
        % Empty temporary variable
        temp = [];
        
        % Loop over all pauses in MT growth
        for i = 1 : length(ind2)
            
            % Proceed if the pause occured at the barrier and thus
            % considered to be in contact
            if ind2(i) == 1
                
                % Store the location of the MT pausing
                Contact{n,1}{end+1} = [Time{1,n}(ind(i)) X{1,n}(ind(i));...
                                        Time{1,n}(ind(i)+1) X{1,n}(ind(i)+1)]; 
                
                % Store the duration of contact
                Contact_duration{n,1}(end+1) = diff(Contact{n,1}{end}(:,1)) * (FrameTime / 1000);
            end
        end
        
        % Loop over all MT shortening events to identify whether a
        % catastrophe is caused by barrier contact.
        for i = 1 : length(D2) 
            
            % Proceed if the contact event is followed by a rescue
            if D1(D2(i)-1) == 0          
                
                % Add index of catastrophe to temporary variable
                temp = [temp i];
            end            
        end
        
        % Store the index of the catastrophes that were preceeded by
        % MT-barrier contact
        Catastrophe_contact{n,1} = temp;
        
        % Store the number of catastrophes that were preceeded by
        % MT-barrier contact
        Catastrophe_num(n,2) = length(temp);
    
    % Skip, if no barriers are present (user input)
    else 
        Contact = [];
    end
    
    %%%--------------------------------------------------------------------
    % 8) NUCLEATION TIME
    % Not yet implemented.
    % This could simply be the total kymograph duration minus the growth,
    % shrinkage, and stalling duration. 
    
    %%%--------------------------------------------------------------------
    % 9)MEAN GROWTH SPEED (WEIGHTED)
    
    % Calculate the speed of all MT displacements.
    temp = (refDistance{n,1}(:,1) * PixelSize) ./ (refTime{n,1}(:,1) *(FrameTime / 1000) ); % nm/sec
    % Select all positive MT displacements
    ind = find(temp > 0);  
    
    % Calculate weighted growth speed. The mean is weighted with the
    % duration of each line segment.
    Growth_Spd(n,1) = sum(temp(ind) .* refTime{n,1}(ind)) ./ sum(refTime{n,1}(ind));    

    %%%--------------------------------------------------------------------
    % 10) MEAN SHRINKAGE SPEED (WEIGHTED)
    
    % Calculate the speed of all MT displacements.
    temp = (refDistance{n,1}(:,1) * PixelSize) ./ (refTime{n,1}(:,1) *(FrameTime / 1000) ); % nm/sec
    % Select all negative MT displacements
    ind = find(temp < 0);  
    
    % Calculate weighted shrinkage speed. The mean is weighted with the
    % duration of each line segment.
    Shrinkage_Spd(n,1) = -1*(sum(temp(ind) .* refTime{n,1}(ind)) ./ sum(refTime{n,1}(ind)));
    
end

%% Collect all parameters and store in Output

Output.Length = MT_length;
Output.Catastrophe = Catastrophe;
Output.Catastrophe_free = Catastrophe_num(:,1) - Catastrophe_num(:,2);
Output.Rescue = Rescue;
Output.Growth_Time = Growth_Time;
Output.Lifetimes = Lifetime;
Output.Growth_Spd = Growth_Spd;
Output.Shrinkage_Time = Shrinkage_Time;
Output.Shrinkage_Spd = Shrinkage_Spd;
Output.Contact_Times = Contact;
Output.Contact_Duration = Contact_duration;
if Barrier == 1
    Output.Catastrophe_Contact = Catastrophe_contact;
else
    Output.Catastrophe_Contact = [];
end
end
