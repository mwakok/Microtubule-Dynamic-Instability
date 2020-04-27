function Position_Comet = fComet_Fit(Data, Config)
%%%------------------------------------------------------------------------
% Function to fit the comet signal in a kymograph at each timepoint
% with a Gaussian function to find its exact location.
%
%
% Maurits Kok
% April 2019
%%%------------------------------------------------------------------------

% Check if kymograph is loaded, return if otherwise.
if isempty(Data.Kymo)
   Position_Comet = [];
   return 
end

% Check if analysis is required
if Config.Kymo_analysis == 0 || length(Data.Kymo{1,1}) == 1 
   Position_Comet = [];
   return
end

% Check if kymograph contains a channel with a +TIP such as EB
if isempty(find(Config.Channel == 3,1))
    Position_Comet = [];
    return
end

%% INITIALYZE ANALYSIS
% Extract required parameters form input structures
Kymo = Data.Kymo;
File_ID = Data.Files;
Coordinates = Data.Coordinates;
T_skip = Config.Frame_Skip;

% Find out whether parallel processing toolbox is installed and, if so,
% initialize multiple cores based on the default profile.
CPU = ParPool;

% Initialize cell array as output container
Position_Comet = cell(1,length(Coordinates));

% Define fitting routine with a (simple) Gaussian function. For more
% complex fitting functions, see methods in Aher et al. [2017] CLASP 
% suppresses Microtubule Catastrophe through a Single TOG Domain.
ft = fittype( 'I_bkg + I_A*exp(-((x-mu)/sigma)^2)', 'independent', 'x', 'dependent', 'y' );

% Set threshold rsquared value for goodness-of-fit. The fit of the
% +TIP intensity signal is considered insufficient if the rsquared 
% value is lower than this set threshold.
Thresh_gof = 0.85;

%% RUN ANALYSIS

% Loop over each MT growth event
for n = 1 : length(Coordinates)
    
    % Display current analyzed event
    Str = strcat('Locating EB comet of event:',{' '}, num2str(n), '/',num2str(length(Coordinates)));
    display(Str{:})
    
    % Lookup corresponding event and kymograph
    CH_index = find(Config.Channel == 3);
    K_index = File_ID{1,1}{n,5};        
    
  % Find first timepoint of selected event. 
    % Optional: skip first frames(based on user input). MT growth usually 
    % takes some time to reach a steady-state, so this step allowes to 
    % remove this effect.
    T1 = Coordinates{1,n}(1,1) + T_skip; % in frames
        % Ignore all frames with time below 1. This is caused by improper tracing of
        % the kymograph.
        if T1 < 1
           T1 = 1;
        end    
    % Find last timepoint of selected event
    T2 = Coordinates{1,n}(end,1); % in frames
    % Find left spatial coordinates of the event, i.e. near the seed.
    Xmin = min(Coordinates{1,n}(:,2)); % in pixels
        % Ignore all positions smaller than 1. This is caused by improper tracing.
            if Xmin < 1
               Xmin = 1;
            end  
    % Obtain the pixel intensity values from the kymograph corresponding to 
    % the selected event
    Data = double(Kymo{1,K_index}{1,CH_index(1)}(T1:T2,Xmin:end)); % convert to double       
    
    % Define locations of the MT end based on the manual trace
    Mu_start = Coordinates{n}(1+T_skip:end,2) - (Xmin-1);   
    
    % Set limits to fitting values
    Parameters = struct();
    for i = 1 : size(Data,1)                 
       Parameters(i).Lower = [0 0 0 0];    
       Parameters(i).Upper = [Inf Inf Inf Inf];  
       % The locations of the MT end for each timepoint as a starting
       % value.
       Parameters(i).StartPoint = [max(Data(i,:)) min(Data(i,:)) Mu_start(i) 2];
    end
    
    % If parallel processing is enabled
    if CPU == 1
        
        % Initialize temporary output vector
        Pos_temp = [];
        
        % Loop over each timepoint to perform fit 
        parfor i = 1 : size(Data,1)

            % Prepare fitting data
           [xData, yData] = prepareCurveData( [], Data(i,:));   

           % Fitting options
           opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
           opts.Display = 'Off';
           opts.Lower = Parameters(i).Lower;    
           opts.Upper = Parameters(i).Upper;       
           opts.StartPoint = Parameters(i).StartPoint;
           
           % Perform fit
           [fitresult, gof] = fit( xData, yData, ft, opts );       

           % Determine whether threshold is met. If not, then the fitting
           % result is deleted.                      
           if gof.rsquare > Thresh_gof
               
               % Define window surrounding the MT end in which to look for 
               % the maximum comet intensity
               x_window = 3;
               x_lower = floor(fitresult.mu-x_window);
               x_upper = ceil(fitresult.mu+x_window);
               
               % Correct window limits if they exceed the size of the
               % kymograph
               if x_lower < 1
                   x_lower = 1;
               end
               if x_upper > length(yData)
                   x_upper = length(yData);               
               end
               
               % Obtain maximum value comet within window
               temp_max = max(yData(x_lower:x_upper));        
               % datastructure: [Time Position Rsquare Intensity] 
               temp = [i+T1-1 fitresult.mu+Xmin gof.rsquare temp_max]; 
           
           % If goodness-of-fit threshold is not met
           else 
               % datastructure: [Time Position Rsquare Intensity] 
               temp = [i+T1-1 NaN gof.rsquare NaN];
           end
           
           % Store the temporary output
           Pos_temp(i,:) = temp;
        end
    
    % If parallel processing is not enabled
    elseif CPU == 0 
        
        % Initialize temporary output
        Pos_temp = [];
        
        % Loop over each timepoint to perform fit 
        for i = 1 : size(Data,1)
            
           % Prepare fitting data
           [xData, yData] = prepareCurveData( [], Data(i,:));   

           % Fitting options
           opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
           opts.Display = 'Off';
           opts.Lower = Parameters(i).Lower;    
           opts.Upper = Parameters(i).Upper;       
           opts.StartPoint = Parameters(i).StartPoint;
           
           % Perform fit
           [fitresult, gof] = fit( xData, yData, ft, opts );       

           % Determine whether threshold is met. If not, then the fitting
           % result is deleted.   
           if gof.rsquare > Thresh_gof 
               
               % Define window surrounding the MT end in which to find the
               % maximum comet intensity
               x_window = 3;
               x_lower = floor(fitresult.mu-x_window);
               x_upper = ceil(fitresult.mu+x_window);
               % Correct window limits if they exceed the size of the
               % kymograph
               if x_lower < 1
                   x_lower = 1;
               end
               if x_upper > length(yData)
                   x_upper = length(yData);               
               end
               
               % Obtain maximum value EB within window
               temp_max = max(yData(x_lower:x_upper));        
               % datastructure: [Time Position Rsquare Intensity] 
               temp = [i+T1-1 fitresult.mu+Xmin gof.rsquare temp_max]; 
           
           % If goodness-of-fit threshold is not met
           else 
               % datastructure: [Time Position Rsquare Intensity] 
               temp = [i+T1-1 NaN gof.rsquare NaN];
           end
           % Store the temporary output
           Pos_temp(i,:) = temp;

        end        
    end
                
    % Store the output
    Position_Comet{n} = Pos_temp;
end


end