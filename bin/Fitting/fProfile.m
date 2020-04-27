function [Profile_MT, Profile_Comet] = fProfile(Data, Results, Config)
%%%------------------------------------------------------------------------
% Calculate the mean microtubule intensity profile.
%
%
% Maurits Kok
% April 2019
%%%------------------------------------------------------------------------

%% EVALUATE INPUT
% Stop analysis if input is missing 
if Config.Kymo_analysis == 0 || isempty(Data.Kymo) || isempty(Results.Position_MT) || isempty(Data.Coordinates)
   Profile_MT = [];
   Profile_Comet = [];
   return
end

% Check if kymograph contains a microtubule lattice channel
if isempty(find(Config.Channel == 2))   
    Profile_MT = [];
    Profile_Comet = [];
    return
elseif ~isempty(find(Config.Channel == 2))
    MT = find(Config.Channel == 2);
end

% Check if channel of MAP is present
if ~isempty(find(Config.Channel > 2))
    MAP = find(Config.Channel > 2);
else
    MAP = [];
end

%% INITIALIZE ANALYSIS
% Extract required parameters form input structures
Kymo = Data.Kymo;
File_ID = Data.Files;
Coordinates = Data.Coordinates;
T_skip = Config.Frame_Skip;
Position_MT = Results.Position_MT;
PixelSize = Config.PixelSize;

%% RUN ANALYSIS
% The analysis consists of binning all measured intensity values into their
% respective position. Using the fitted position of the MT tip, all
% datapoints will be aligned on that. 
Profile_MT = [];
Profile_Comet = [];

for n = 1 : length(Position_MT)
% for n = 1 : 10
    
    % Find corresponding event and kymograph
    K_index = File_ID{1,1}{n,5};
        
    % Select timepoints from the start of the growth event and, if present,
    % the catastrophe. 
    T1 = Coordinates{1,n}(1,1) + T_skip;
    T2 = Coordinates{1,n}(end,1);
    
    % Check whether catastrophe is present
    if size(Results.Catastrophe{n,1} == 1)
        T2 = Results.Catastrophe{n,1}(1,1);       
    end
    
    % Get selected intensity values from the corresponding kymograph
    Intensity = double(Kymo{1,K_index}{1,MT(1)}(T1:T2,:));  
    Position = (0:1:size(Intensity,2)-1).*ones(size(Intensity,1),1);
    
    % Align positions on fitted value of the MT tip
    Position = Position - Position_MT{1,n}(1:size(Intensity,1),2);
    
    % Find and remove positions containing NaN 
    ind_NaN = isnan(Position(:,1));
    Position(ind_NaN,:) = [];
    Intensity(ind_NaN,:) = [];
          
    edges = -20:0.5:20;        
    Profile_MT = [Profile_MT; [Position(:) Intensity(:)]];
   
    if ~isempty(MAP)
        Intensity = double(Kymo{1,K_index}{1,MAP(1)}(T1:T2,:));
        
        % Remove NaN
        Intensity(ind_NaN,:) = [];
        Profile_Comet = [Profile_Comet; [Position(:) Intensity(:)]];                
    end
    
    
end

% Sort positional data into bins
[N, edges, bin] = histcounts(Profile_MT(:,1), edges);
Mean_MT = [];
for i = 1 : length(edges)-1
    ind = find(bin == i);
    
    % Calculate mean MT profile
    Mean_MT(i,:) = [i N(i) mean(Profile_MT(ind,1)) mean(Profile_MT(ind,2)) std(Profile_MT(ind,2)) std(Profile_MT(ind,2))/sqrt(N(i))];
    
    if ~isempty(Profile_Comet)
        % Calculate mean Comet profile
        Mean_Comet(i,:) = [i N(i) mean(Profile_Comet(ind,1)) mean(Profile_Comet(ind,2)) std(Profile_Comet(ind,2)) std(Profile_Comet(ind,2))/sqrt(N(i))];
    end
end


%% PLOT DATA
Figure_settings
hold on

% MT profile data
xData = Mean_MT(:,3).*PixelSize;
yData = Mean_MT(:,4) - min(Mean_MT(:,4));
yData = yData./max(yData);
errData = Mean_MT(:,6)./max(Mean_MT(:,4));

errorbar(xData, yData, errData,'.k', 'MarkerSize', 12, 'LineWidth',1.5);

if ~isempty(Profile_Comet)
    % Comet profile data
    xData = Mean_Comet(:,3).*PixelSize;
    yData = Mean_Comet(:,4) - min(Mean_Comet(:,4));
    yData = yData./max(yData);
    errData = Mean_Comet(:,6)./max(Mean_Comet(:,4));

    errorbar(xData, yData, errData,'.g', 'MarkerSize', 12, 'LineWidth', 1.5);
end
   
% xlim([edges(1)*PixelSize edges(end)*PixelSize]);
xlim([-1000 1000]);
ylim([-0.03 1.1])

xlabel('Distance (nm)')
ylabel('Norm. Intensity (a.u.)');
hold off


end