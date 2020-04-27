function Data = fImport(HomeFolder, Config)
%%%------------------------------------------------------------------------
% Function to import event and kymographs
%
% Input: HomeFolder is 
%
%
% Maurits Kok 
% April 2019
%%%------------------------------------------------------------------------

% Collect parameters
mode = Config.Kymo;     % Check whether kymohraphs need to be loaded
                        % mode = 0, skip kymograph
                        % mode = 1, load kymograph
%% IMPORT EVENT DATA

% GUI to select one or multiple text files containing X- and Y-coordinates 
% from traced event in kymographs. These files were created with the ImageJ 
% Macro "Event_Save.ij"
[FileName, PathName] = uigetfile('*.txt', 'Please select the events...', 'MultiSelect', 'on', HomeFolder);

% Set the variable FileName to be a cell array
if ~iscell(FileName)
    FileName = {FileName};
end

if FileName{1} ~= 0 % verify that GUI has not been cancelled
    
    % Define the input structure
    delimiter = '/t';
    formatSpec = '%f%f%[^\n\r]';

    for n = 1 : length(FileName)  

    fileID = fopen([PathName FileName{n}],'r'); % open file
    dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'ReturnOnError', false); % collect data
    fclose(fileID); % close file

    % Store x-coordinates in the cell array "Position"
    Position{n} = dataArray{:, 1};
    % Store y-coordinates in the cell array "Time"
    Time{n} = dataArray{:, 2};

    % Store the name of the event
    Name_Event{n,1} = FileName{n};
    Name_Event{n,2} = Name_Event{n,1}(1:6);
    Name_Event{n,3} = str2num(Name_Event{n,1}(11:13));
    Name_Event{n,4} = n;

    end
    
    % Store the event name in the cell array "File_ID"
    File_ID{1} = Name_Event;
else
    % Return warning and empty output variables if no events were selected
    warning('No events selected...') 
    Position = [];
    Time = [];
    File_ID = [];
end

%% Import the corresponding kymographs

if mode == 1 % only proceed if kymographs need to be loaded
    
    % GUI to select one or multiple .tif files
    [FileName, PathName] = uigetfile('*.tif', 'Please select the kymographs...', 'MultiSelect', 'on', HomeFolder);
    
    % Set the variable FileName to be a cell array
    if ~iscell(FileName)
        FileName = {FileName};
    end
    
    if FileName{1} ~= 0 % verify that GUI has not been cancelled

        % Load kymographs with function "fStackRead2.m"
        if ~isempty(FileName)
            for n = 1 : length(FileName)
                Kymo{n} = fStackRead2([PathName FileName{n}]);
            end
        else
           Kymo = [];
        end

        % Store filename
        Name_Kymo = FileName;
        File_ID{2} = Name_Kymo;

        % Kymo_num = File_ID{1,1}{ind,3};
        
        % Couple each event to a kymograph based on the name. The names are
        % set by the ImageJ macro's 
        for i = 1 : size(File_ID{1},1)
            str_ind = strfind(File_ID{1,1}{i,1}, '_Event')-1;
            match = File_ID{1,1}{i,1}(1:str_ind);
            for n = 1 : length(File_ID{1,2})    
                if find(contains(File_ID{1,2}{1,n}, match)) == 1
                    File_ID{1}{i,5} = n;
                end
            end
        end
    else
        % Return warning and empty output variables if no files were selected
        warning('No kymographs selected...') ;
        Kymo = [];
    end
else
    % Return empty output if mode == 0
    Kymo = [];
end

%% Prepare Output structure
Data = struct;
Data.Position = Position;
Data.Time = Time;
Data.Files = File_ID;
Data.Kymo = Kymo;