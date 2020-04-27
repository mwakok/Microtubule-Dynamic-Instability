function [Output_4Hz, Output_2Hz_O, Output_2Hz_E] = fVel_FL(Range, YData, FrameTime)

    Output_4Hz = [];
    Output_2Hz_E = [];
    Output_2Hz_O = [];
    
        Data = [];
        Data_E = [];
        Data_O = [];
        
        for k = 1 : size(Range,1)
          
            Data = [Data; YData(Range(k,1):Range(k,2))];            
            Even = find(rem(Range(k,1):1:Range(k,2),2) == 0);
            Odd = find(rem(Range(k,1):1:Range(k,2),2) == 1);
            Data_E = [Data_E; YData(Even + Range(k,1) -1)];
            Data_O = [Data_O; YData(Odd + Range(k,1) -1)];
            
        end
      
        Output_4Hz = [Output_4Hz diff(Data)./FrameTime];
        Output_2Hz_E = [Output_2Hz_E diff(Data_E)./(FrameTime*2)];
        Output_2Hz_O = [Output_2Hz_O diff(Data_E)./(FrameTime*2)];
        
end