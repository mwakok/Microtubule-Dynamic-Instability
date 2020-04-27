function Position_MT = fMT_Fit(Data, Config)
%%%------------------------------------------------------------------------
% Function to fit the microtubule signal in a kymograph at each timepoint
% with the complementary error function (erfc) to locate the MT end.
%
%
% Maurits Kok
% April 2019
%%%------------------------------------------------------------------------
%% EVALUATE INPUT
% Stop analysis if input is missing or through user input
if Config.Kymo_analysis == 0 || isempty(Data.Kymo)
   Position_MT = [];
   return
end

% Check if kymograph contains a microtubule lattice channel. If not, return
% empty output.
if isempty(find(Config.Channel == 2))
    warning('Microtubule signal is missing...')
    Position_MT = [];
    return
end

%% INITIALYZE ANALYSIS
% Extract required parameters from input structures
Kymo = Data.Kymo;
File_ID = Data.Files;
correction = Config.Correct_data;
Coordinates = Data.Coordinates;
T_skip = Config.Frame_Skip;

% Find out whether parallel processing toolbox is installed and, if so,
% initialize multiple cores based on the default profile.
CPU = ParPool;

% Initialize cell array as output container
Position_MT = cell(1,length(Coordinates));

% Define fitting function with error function
% See methods in Aher et al. [2017] CLASP suppresses Microtubule
% Catastrophe through a Single TOG Domain.

ft = fittype( 'I_bkg + (1/2)*I_A*erfc(-(x-mu)/(sqrt(2)*sigma))', 'independent', 'x', 'dependent', 'y' );

% Set threshold rsquared value for goodness-of-fit. The fit of the
% microtubule intensity signal is considered insufficient if the rsquared 
% value is lower than this set threshold.
Thresh_gof = 0.4; 

%% RUN ANALYSIS

% Loop over each MT growth event
for n = 1 : length(Coordinates)
    
    % Display current analyzed event
    Str = strcat('Locating MT ends of event:',{' '}, num2str(n), '/',num2str(length(Coordinates)));
    display(Str{:})
    
    % Lookup corresponding event and kymograph
    CH_index = find(Config.Channel == 2);
    K_index = File_ID{1,1}{n,5};        
       
    % Find first timepoint of selected event. 
    % Optional: skip first frames(based on user input). MT growth usually 
    % takes some time to reach a steady-state, so this step allowes to 
    % remove this effect.
    T1 = Coordinates{1,n}(1,1) + T_skip; % in frames
        % Ignore all frames below 1. This is caused by improper tracing of
        % the kymograph.
        if T1 < 1
           T1 = 1;
        end    
    % Find last timepoint of selected event   
    T2 = Coordinates{1,n}(end,1); % in frames
    % Find left spatial coordinates of the event, i.e. near the seed.
    Xmin = min(Coordinates{1,n}(:,2)); %in pixels   
    	% Ignore all positions smaller than 1. This is caused by improper tracing.
        if Xmin < 1
           Xmin = 1;
        end  
    % Obtain the pixel intensity values from the kymograph corresponding to
    % the selected event
    Intensity = double(Kymo{1,K_index}{1, CH_index(1)}(T1:T2,Xmin:end));        
        
    % Define locations of MT end based on the manual trace 
    Mu_start = Coordinates{n}(1 + T_skip:end,2) - (Xmin-1);    
    
    % Set limits to fitting values
    Parameters = struct();
    for i = 1 : size(Intensity,1)                 
       Parameters(i).Lower = [0 0 0 -Inf];    
       Parameters(i).Upper = [Inf Inf Inf 0]; 
       % The locations of the MT end for each timepoint as a starting
       % value.
       Parameters(i).StartPoint = [1000 500 Mu_start(i) -1];
    end
        
    % Initialize temporary variable
    Pos_temp = [];
    
    % If parallel processing is enabled
    if CPU == 1 
        
        % Loop over each timepoint to perform fit 
        parfor i = 1 : size(Intensity,1)   
            
           % Prepare fitting data
           [xData, yData] = prepareCurveData( [], Intensity(i,:));

           % Fitting options
           opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
           opts.Display = 'Off';
           opts.Lower = Parameters(i).Lower;
           opts.Upper = Parameters(i).Upper;
           opts.StartPoint = Parameters(i).StartPoint;
           
           % Perform fit
           [fitresult, gof] = fit( xData, yData, ft, opts);

           % Determine whether threshold is met. If not, then the fitting
           % result is deleted.
           if gof.rsquare > Thresh_gof % If goodness-of-fit threshold is met
               % datastructure: [Time Position Rsquare]  
               temp = [i+T1-1 fitresult.mu+Xmin gof.rsquare]         
           else % If goodness-of-fit threshold is not met
               % datastructure: [Time Position Rsquare]    
               temp = [i+T1-1 NaN gof.rsquare] 
           end 
           
           % Store the temporary output
           Pos_temp(i,:) = temp;
        end

    % If parallel processing is not enabled
    elseif CPU == 0 
        
        % Loop over each timepoint to perform fit 
        for i = 1 : size(Intensity,1)   
            
           % Prepare fitting data
           [xData, yData] = prepareCurveData( [], Intensity(i,:));

           % Fitting options
           opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
           opts.Display = 'Off';
           opts.Lower = Parameters(i).Lower;
           opts.Upper = Parameters(i).Upper;
           opts.StartPoint = Parameters(i).StartPoint;
           
           % Perform fit
           [fitresult, gof] = fit( xData, yData, ft, opts);

           % Determine whether threshol is met. If not, then the fitting
           % result is deleted.
           if gof.rsquare > Thresh_gof % If goodness-of-fit threshold is met
               % datastructure: [Time Position Rsquare]  
               temp = [i+T1-1 fitresult.mu+Xmin gof.rsquare];      
           else % If goodness-of-fit threshold is not met
               % datastructure: [Time Position Rsquare]    
               temp = [i+T1-1 NaN gof.rsquare]; 
           end 
           
           % Store the temporary output
           Pos_temp(i,:) = temp;
        end
    end
    
   % Optional (user input): Replace poorly fitted results with a linear 
   % interpolation. 
    if correction == 1
       Pos_temp(:,2) =  fillmissing(Pos_temp(:,2),'linear');
    end
    % Store the corrected output
    Position_MT{n} = Pos_temp;
end

end