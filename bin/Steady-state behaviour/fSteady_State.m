function Output = fSteady_State( Config, Data, Results)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Determine steady-state growth events from the position of the EB3 comet
%
% 
% 
% 
%
% Maurits Kok
% April 2019
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% EVALUATE INPUT

% Stop analysis if input is missing or through user input
if Config.Steady_State == 0 || isempty(Data.Kymo)
   Output = [];
   return
end

% Check if kymograph contains an EB channel. If not, return
% empty output.
if isempty(find(Config.Channel == 3)) || isempty(Position_Comet)
    warning('Comet data is missing...')
    Output = [];
    return
end


% Manually load the datafile "Analysis_Event_free" into the MATLAB
% workspace

% load('C:\Users\Maurits\SURFdrive\Thesis\Chapter 5\Statistics\EB3 50 nM\2017-07-17\Matlab Data\Data_Event_Analysis_Free.mat')


%% INITIALIZE ANALYSIS
% Extract required parameters from input structures
Position_Comet = Results.Position_Comet;
Catastrophe = Results.Catastrophe;
Time = Data.Time;
FrameTime = Config.FrameTime;
PixelSize = Config.PixelSize;

% Select events that contain an analyzed EB3 comet
select = ~cellfun(@isempty, Position_Comet);
select = find(select == 1);

%%% Define analysis parameters
% 1) Minimum duration of a steady-state growing event
Options.D_min = ceil(3 / (FrameTime/1000)); % in seconds

% 2) Linear fit of each timepoint in the window [t-win_t; t; t+win_t]
Options.win_t = ceil(4 / (FrameTime/1000)); % in seconds

% 3) Options for plotting and saving data
Options.Plot = 1; % Plot fitresults
Options.Save = 0; % Save plots

% 4) Threshold for pausing state
Options.threshold = 0.7;

% 5) Create output 
% V_free = cell(1,length(select));
G_free = zeros(length(select),2);
Range = cell(1,length(select));


% %%% Set folder to save graphs
% if Config.Save == 1
%         HomeFolder = 'C:\Users\Maurits\surfdrive\Thesis\Chapter 5\Statistics';
% %     HomeFolder = 'K:\bn\mdo\Shared\Maurits\Surfdrive\Thesis\Chapter 5\Statistics';
%     PathName = uigetdir(HomeFolder);
%     Config.SaveFolder = strcat(PathName,'\Growth figures');
%     
%     if exist(SaveFolder) ~= 7
%        mkdir(SaveFolder); 
%     end
% end

%% Collect and standardize data

% Initialize waitbar
h = waitbar(0, 'Please wait...');

% Loop over all events containing comet positions
for n = 1 : length(select)
    
    % Select for events with zero or one catastrophe
     if size(Catastrophe{n},1) < 2
         
        %%% Find timepoints of growth initiation and catastrophe if present
        if ~isempty(Catastrophe{n})

            timepoint2 = Catastrophe{select(n)}(1) - Time{select(n)}(1) + 1; %Frame number
            timepoint1 = Time{select(n)}(1) - Time{select(n)}(1) + 1; % Frame number
        
        else
             
            timepoint2 = Time{select(n)}(end) - Time{select(n)}(1) + 1; %Frame number
            timepoint1 = Time{select(n)}(1) - Time{select(n)}(1) + 1; % Frame number
            
        end        
             
        % Select for events with positive timepoint1 and longer duration
        % than "D_min"        
        dt = (timepoint2-timepoint1) * (FrameTime/1000); % in seconds
        
        % Proceed if the total duraration of the evetn is longer than twice
        % the time window 
        if timepoint1 > 0 && dt > 2*Options.win_t
            
            YData = Position_Comet{select(n)}(timepoint1:timepoint2,2) * PixelSize;
            XData = (1:1:length(YData)) * (FrameTime/1000); % in seconds
            YData = YData - min(YData);
            
            % Identify outliers from data     
            YData_Outliers = find(abs(diff(YData)) > 100);
            
            % Run function to remove the pausing-state timepoints
            remove = fRemove_Pause(XData, YData, Options);
                
            % Create new dataset in which removed timepoints are substituted
            % with NaN
            Ytemp = YData;
            Ytemp(remove) = NaN;
            Ytemp(YData_Outliers) = NaN;
            
            % Run function to find each steady-state growth event in the 
            % dataset
            Range{n} = fRange(XData, Ytemp, remove, Options);
            
        end
        
        %%% Calculate the velocity fluctuations for steady state 
        
%         if ~isempty(Range{n})
%              [FL_Vel{1,n}, FL_Vel{2,n}, FL_Vel{3,n}] = fVel_FL(Range{n}, YData, FrameTime/1000);
%         else
% %              FL_Vel{1:3,n} = [];
%         end
%         

        %%% Calculate intensity fluctuations during steady-state growth
%         if ~isempty(Range{n})
%             [FL_Int{1,n} FL_Int{2,n}] = fFluctuations(Range{n}, Int_pre_2{n}, Bkg_contact_lat_Int_C{n});            
%         else
%             FL_Int{1,n} = [];
%             FL_Int{2,n} = [];
%         end
        
        
        %%% Determine the weighted growth speed for each growth event
        if ~isempty(Range{n})
            G_free(n,:) = fVelocity(XData, YData, Range{n}, Options);
        else
            G_free(n,1:2) = NaN;
        end
                          
     end
    
    waitbar(n/length(select));
     
end

%% Display results
% fDisplayResult(G_free,1);  
% fDisplayResult(FL_Int,2);
% fPlotVel(FL_Vel);
% fPlotFluc(FL_Int);

close(h);

