function fResults(Results)
%%%------------------------------------------------------------------------
% Function to calculate and display the microtubule dynamic 
% instability parameters
%
% 
% Maurits Kok
% April 2019
%%%------------------------------------------------------------------------

% Verify that results are present
if isempty(Results)
    return
end

% Clear the workspace
clc 

%%% CATASTROPHE FREQUENCY
% Calculate mean and SEM of the catastrophe frequency, during free growth
% and during MT-barrier contact.

% Check whether the dataset contains MT-contact events
if ~isempty(Results.Contact_Times)
    
    % Calculate total number of catastrophes in the dataset during free MT
    % growth
    C_num(1) = sum(Results.Catastrophe_free);
    % Calculate the mean frequency
    F_c(1,1) = C_num(1) / (sum(Results.Growth_Time)/60); % per minute
    % Calculate the standard deviation. The process is considered to be
    % follow Poisson statistics.
    F_c(1,2) = F_c(1,1) / sqrt(C_num(1));
    
    % Calculate total number of catastrophes in the dataset after
    % MT-barrier contact.
    C_num(2) = sum(cellfun(@length, Results.Catastrophe_Contact));
    % Calculate the mean frequency    
    F_c(2,1) = C_num(2) / (sum(cellfun(@sum, Results.Contact_Duration))/60); % per minute
    % Calculate the standard deviation. The process is considered to be
    % follow Poisson statistics.
    F_c(2,2) = F_c(2,1) / sqrt(C_num(2));  
    
% if no MT-barrier contact events are present in the dataset    
else
    % Calculate total number of catastrophes in the dataset during free MT
    % growth
    C_num = sum(Results.Catastrophe_free);
     % Calculate the mean frequency     
    F_c(1,1) = C_num / (sum(Results.Growth_Time)/60); % per minute
    % Calculate the standard deviation. The process is considered to be
    % follow Poisson statistics.s
    F_c(1,2) = F_c(1,1) / sqrt(C_num);   
end

%%% RESCUE FREQUENCY
% Calculate total number of rescues in the dataset.
R_num = sum(cellfun('size',Results.Rescue,1));
F_r(1) = R_num / (sum(Results.Shrinkage_Time/60)); % per minute
F_r(2) = F_r(1) / sqrt(R_num);

%%% GROWTH SPEED
% Calculate the median growth speed. We calculate the median to ignore
% outliers in the dataset. Note, that in a perfect data median = mean. 
G(1) = nanmedian(Results.Growth_Spd);
G(2) = nanstd(Results.Growth_Spd) / sqrt(length(Results.Growth_Spd));

%%% SHRINKAGE SPEED
% Calculate the median shrinkage speed. We calculate the median to ignore
% outliers in the dataset. Note, that in a perfect data median = mean. 
S(1) = nanmedian(Results.Shrinkage_Spd);
S(2) = nanstd(Results.Shrinkage_Spd) / sqrt(length(Results.Shrinkage_Spd));

% Create output strings to display results
if ~isempty(Results.Contact_Times)
    Str_c_num_free = strcat('Number of catastrophes [free]:', {' '}, num2str(C_num(1)));
    Str_c_num_contact = strcat('Number of catastrophes [contact]:', {' '}, num2str(C_num(2)));
    Str_c_free = strcat('Catastrophe frequency [free]:', {' '}, num2str(F_c(1,1)), {' '}, '±', {' '}, num2str(F_c(1,2)), {' '},'per min');
    Str_c_contact = strcat('Catastrophe frequency [contact]:', {' '}, num2str(F_c(2,1)), {' '}, '±', {' '}, num2str(F_c(2,2)), {' '},'per min');
else
    Str_c_num = strcat('Number of catastrophes:', {' '}, num2str(C_num));
    Str_c = strcat('Catastrophe frequency:', {' '}, num2str(F_c(1,1)), {' '}, '±', {' '}, num2str(F_c(1,2)), {' '},'per min');
end
Str_r_num = strcat('Number of rescues:', {' '}, num2str(R_num));
Str_r = strcat('Rescue frequency:', {' '}, num2str(F_r(1)), {' '},'±', {' '}, num2str(F_r(2)), {' '}, 'per min');
Str_g = strcat('The median growth speed:', {' '}, num2str(G(1)), {' '}, '±', {' '}, num2str(G(2)), {' '}, 'nm/sec');
Str_s = strcat('The median shrinkage speed:', {' '}, num2str(S(1)), {' '}, '±', {' '}, num2str(S(2)), {' '}, 'nm/sec');


% Display the results
display(Str_g{1});
display(Str_s{1});

if ~isempty(Results.Contact_Times)
    display(Str_c_num_free{1});
    display(Str_c_free{1});
    display(Str_c_num_contact{1});
    display(Str_c_contact{1});    
else
    display(Str_c_num{1});
    display(Str_c{1});
end
display(Str_r_num{1});
display(Str_r{1});
