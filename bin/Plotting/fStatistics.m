function fStatistics(Results, Config)
warning off
% Check input parameters
if isfield(Results, 'Growth_Spd') == 0 
    return
end
% Plot growth speed distribution
subplot(1,3,1);
hold on
bins = histx(Results.Growth_Spd, 'fd');
hist(Results.Growth_Spd, length(bins));

xlabel('Growth speed (nm/s)');
ylabel('Counts');
title('Growth speed')
Figure_settings2
hold off

% Plot shrinkage speed distribution
subplot(1,3,2);
hold on
bins = histx(Results.Shrinkage_Spd, 'fd');
hist(Results.Shrinkage_Spd, length(bins));

xlabel('Shrinkage speed (nm/s)');
ylabel('Counts');
title('Shrinkage speed')
Figure_settings2
hold off

% Plot microtubule lifetime OR contact duration distribution
subplot(1,3,3);
hold on
if Config.Barrier == 0
    bins = histx(Results.Lifetimes, 'fd');
    hist(Results.Lifetimes, length(bins));
    title('MT lifetime');
elseif  Config.Barrier == 1
    bins = histx([Results.Contact_Duration{:}], 'fd');
    hist([Results.Contact_Duration{:}], length(bins));
    title('Contact lifetime');
end

xlabel('Lifetime (s)');
ylabel('Counts');

Figure_settings2
hold off

set(gcf,'units','inch');
% pos = get(gcf,'position');
set(gcf,'position',[0 0 12 5]);
warning on
end