%% -----------------------------------------------------------------------
% Extract dynamic instability parameters from microtubule growth traces
% obtained with ImageJ scripts: "Kymo_Save.ij" and "Event_Save.ij"
%
%
%
% 
%
%
% Maurits Kok
% April 2019
% -----------------------------------------------------------------------
%% USER INPUT
clear
addpath(genpath('bin'))

% Set experimental parameters
Config.PixelSize = 160;  % in nm
Config.FrameTime = 1000;  % in ms

% Identify the fluorescence channels in the kymograph 
%   0 = channel not present
%   1 = seed
%   2 = microtubule lattice
%   3 = EB (or other +TIP)
Config.Channel = [2 3 0];  % [Channel_1 Channel_2 Channel_3]

% Settings
Config.Kymo = 1;                 % Load kymographs: true or false (1 or 0)
Config.Kymo_analysis = 1;        % Analyse kymograph: true or false (1 or 0)
                                 % This analysis performs a fit to locate
                                 % the MT tip and, if present, the EB comet
                           
Config.Barrier = 0;              % Indicate presence of stalling events: true or false (1 or 0)
Config.Barrier_Width = 3;        % Margin of error for considering width of barrier region

Config.SteadyState = 0;          % Find phases of steady-state MT growth (UNDER DEVELOPMENT)

Config.Frame_Skip = 0;           % Number of frames at the start of an event to be ignored during analysis
Config.Correct_data = 0;         % Correct fitting errors of MT tip based on goodness-of-fit, replacement with linear interpolation: true or false (1 or 0)
Config.Smooth = 1;               % Amount of smoothing of MT end trace, only for display purposes (higher is more, 1 is none): 

Config.Display = 1;              % Display a selected event: true or false (1 or 0)
Config.Save = 1;                 % Save output: true or false (1 or 0)

% Default data folder
HomeFolder = strcat(pwd, '\Sample');

%% IMPORT DATA
% 1) Import events obtained with the ImageJ script "Event_Save.ij"
% 2) Import kymographs obtained with the ImageJ script "Kymo_Save.ij" 
Data = fImport(HomeFolder, Config);

%% ANALYZE DATA
addpath(genpath('bin'))
% Determine the positions of the traced events at each time step
Data.Coordinates = fCoordinates(Data);

% Calculate the Dynamic Instability parameters of the microtubule growth events
Results = fParameters(Data, Config);

% Display Dynamic Instability parameters
fResults(Results);

%% ANALYZE KYMOGRAPHS

% Locate microtubule end by fitting with error function
Results.Position_MT = fMT_Fit(Data, Config);

% Locate peak of EB comet by fitting with Gaussian function
Results.Position_Comet = fComet_Fit(Data, Config);  

% Identify steady-state growth (UNDER DEVELOPMENT)
% This could rely on the selection criteria based on the method presented 
% in Rickman et al. [2017].

% Results.SteadyState = fSteady_State(Config, Data, Results);

%% INTENSITY PROFILES
% Create and plot intensity profiles of the microtubule and the comet,
% aligned on the fitted position of the microtubule tip.
addpath(genpath('bin'))
[Results.Profile_MT, Results.Profile_Comet] = fProfile(Data, Results, Config);

%% DISPLAY STATISTICS
% Display histograms of 
% 1) Growth speed
% 2) Shrinkage speed
% 3) Microtubule lifetime / Contact lifetime

addpath(genpath('bin'))
fStatistics(Results, Config);

%% OPTIONAL: inspect individual traces
% Display selected kymograph
addpath(genpath('bin'))
fDisplayKymo(Data, Results, Config);
    
%% Save all results
addpath(genpath('bin'))
fSave(Config, Data, Results, HomeFolder);

%% Clear variables

clearvars -EXCEPT Results Config Data HomeFolder