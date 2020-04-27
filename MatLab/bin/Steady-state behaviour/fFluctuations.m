function [Output1, Output2] = fFluctuations(Range, Int, Bkg)

Output1 = [];
Output2 = [];


    if ~isempty(Bkg)
        Data = [];
        for k = 1 : size(Range)
          
            Data = [Data Int(Range(k,1):Range(k,2)) - nanmean(Bkg)];
            
        end
      
        Output1 = [Output1 Data];
        Output2 = [Output2 diff(Data)];
        
    end
    
    
end