function fDisplayKymo(Data, Results, Config)
%% EVALUATE INPUT

if Config.Display == 0
    return
end

% Exit if no kymographs are loaded
if isempty(Data.Kymo)
    return
end

%% INITIALIZE PLOTIING
% Extract required parameters from input
Coordinates = Data.Coordinates;
Kymo = Data.Kymo;
Position_MT = Results.Position_MT;
Position_EB = Results.Position_EB;
smoothness = Config.Smooth;
File_ID = Data.Files;
T_skip = Config.Frame_Skip;
Contact = Results.Contact_Times;

% Check input 
mode = 2; % Default: both MT and EB traces are present
if isempty(Position_EB) && ~isempty(Position_MT) % If no comet trace is present
    mode = 1;
elseif isempty(Position_MT) && isempty(Position_EB) % If no MT and comet trace is present
    mode = 0;    
end

% Minimum value of smoothness is 1 (i.e. no smoothing)
if smoothness < 1
    smoothness = 1;
end

% GUI to select the event to show
[ind, tf] = listdlg('ListString',{File_ID{1,1}{:,1}}, 'ListSize',[200 300]);

if tf == 0
   return
end
   
% Select corresponding kymograph
Lattice = find(Config.Channel == 2);
EB = find(Config.Channel == 3);

Kymo_num = File_ID{1,1}{ind,5};

if ~isempty(Kymo)
    if ~isempty(Lattice) && ~isempty(EB) 
        CH_num = 2;
    elseif ~isempty(Lattice)
        CH_num = 1;
    else
        CH_num = 0;
    end
else    
    CH_num = 0;
end

% Find MT channel corresponding to the event and select event
T1 = Coordinates{1,ind}(1,1) + T_skip;
    % Remove all incompatible timepoints
    if T1 < 1
       T1 = 1;
    end    
T2 = Coordinates{1,ind}(end,1);
Xmax = max(Coordinates{1,ind}(:,2));

figure
colormap(gray);


%% PLOT RESULTS
% Use fitted values to draw line
Offset = 7;
Image = [];
if CH_num > 0     
    subplot(1,CH_num,1);
    hold on
    if ~isempty(Kymo)
        Image{1} = double(Kymo{1,Kymo_num}{Lattice(1)}(T1:T2,:));  
    else
        Image{1} = ones(T2-T1, Xmax+2*Offset).*0.4; 
    end
    imagesc(Image{1});

    if mode > 0
        Shift = Position_MT{:,ind}(1,1)-1;
        plot(smooth(Position_MT{1,ind}(:,2), smoothness), Position_MT{1,ind}(:,1)-Shift,'r','LineWidth',2);
        % Indicate catastrophe events
        if ~isempty(Results.Catastrophe{ind,1})
            scatter(Results.Catastrophe{ind,1}(:,2) + Offset, Results.Catastrophe{ind,1}(:,1)-Shift,32,'<y','LineWidth',2);
        end
        % Indicate rescue events
        if ~isempty(Results.Rescue{ind,1})
            scatter(Results.Rescue{ind,1}(:,2) - Offset, Results.Rescue{ind,1}(:,1)-Shift,32,'>b','LineWidth',2);
        end
        % Indicate stalling events
        if Config.Barrier == 1
            if ~isempty(Contact{ind,1})
                for n = 1 : length(Contact{ind,1})
                    plot(Contact{ind,1}{n}(:,2), Contact{ind,1}{n}(:,1)-Shift, 'c','LineWidth',2);
                end              
            end
        end
        
    else
        Shift = Coordinates{1,ind}(1,1) -1;
        plot(Coordinates{1,ind}(:,2), Coordinates{1,ind}(:,1)-Shift,'r','LineWidth',2);
        % Indicate catastrophe events
        if ~isempty(Results.Catastrophe{ind,1})
            scatter(Results.Catastrophe{ind,1}(:,2) + Offset, Results.Catastrophe{ind,1}(:,1)-Shift,32,'<y','LineWidth',2);                
        end
        % Indicate rescue events
        if ~isempty(Results.Rescue{ind,1})
            scatter(Results.Rescue{ind,1}(:,2) -Offset, Results.Rescue{ind,1}(:,1)-Shift,32,'>b','LineWidth',2);
        end
        % Indicate stalling events
        if Config.Barrier == 1
            if ~isempty(Contact{ind,1})
                for n = 1 : length(Contact{ind,1})
                    plot(Contact{ind,1}{n}(:,2), Contact{ind,1}{n}(:,1)-Shift, 'c','LineWidth',2);
                end            
            end
        end
    end

    ax = gca;
    ax.YDir = 'reverse';
    ax.XLim = [0 size(Image{1},2)];
    ax.YLim = [0 size(Image{1},1)];
    hold off
else
    close all
end

if CH_num == 2 
    subplot(1,CH_num,2);
    hold on
    if ~isempty(Kymo)
        Image{2} = double(Kymo{1,Kymo_num}{1,EB(1)}(T1:T2,:)); 
    else
        Image{2} = ones(T2-T1,Xmax).*0.4;
    end        
    imagesc(Image{2});

    if mode == 2
        Shift = Position_EB{:,ind}(1,1)-1;
        plot(Position_EB{1,ind}(:,2),Position_EB{1,ind}(:,1)-Shift,'g','LineWidth',2);
    else
        Shift = Coordinates{1,ind}(1,1) -1;
        plot(Coordinates{1,ind}(:,2), Coordinates{1,ind}(:,1)-Shift,'g','LineWidth',2);
    end

    ax = gca;
    ax.YDir = 'reverse';
    ax.XLim = [0 size(Image{2},2)];
    ax.YLim = [0 size(Image{2},1)];      
    hold off
end

end