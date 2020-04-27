function fSave(Config, Data, Results, HomeFolder)

if Config.Save == true    
    
    SaveFolder = uigetdir(HomeFolder,'Please select the save directory');
    if SaveFolder == 0
        warning('No Savefolder selected');
        return
    end
    
    t = datetime;
    
    SaveName = strcat('DI','_',datestr(t),'.mat');
    
    SaveFile = strcat(SaveFolder, '\', SaveName);
   
    % Check if file already exists
        
    
    
    save(SaveFile, 'Config', 'Data', 'Results');
else
    return
end


end