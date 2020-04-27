function CPU = ParPool
%%%------------------------------------------------------------------------
% Function to determine the presence of the "Parallel Computing Toolbox".
% If present, parallel processing in multip CPU cores is enabled. 
%
%
% Maurits Kok
% April 2019
%%%------------------------------------------------------------------------

% Detect all installed MATLAB toolboxes
toolbox = ver;

% Set default CPU value. Zero = no parallel processing.
CPU = 0;

% Loop over all installed toolboxes to find the "Parallel Computing
% Toolbox"
for n = 1 : length(toolbox)
    
    % If the toolbox is present, then set CPU=1
   if strcmp(toolbox(n).Name, 'Parallel Computing Toolbox')
       CPU = 1;
   end
end

% If no Parallel Computing Toolbox is present, then display warning and
% return.
if CPU == 0
    warning('Please install "Parallel Computing Toolbox" for faster analysis');
    return
    
% If the Parallel Computing Toolbox is present,    
elseif CPU == 1
    
    % Display message
    h = msgbox('Initializing parallel processing...');

    % Verify whether multiple cores are already enabled
    p = gcp('nocreate');
    
    % If not, then initialize multiple cores, based on the default profile
    if isempty(p)
        defaultProfile = parallel.defaultClusterProfile;
        myCluster = parcluster(defaultProfile);
        parpool(myCluster);
    end
    
    % Close message
    close(h);

end

end