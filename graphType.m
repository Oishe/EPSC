load DataCell.mat
%% graph together
figure;
hold on;
for cellIdx = 1:numel(DataCell)
    if (DataCell{cellIdx}.startSample == -1)
        continue;
    else
        if(DataCell{cellIdx}.Type == 'W')
            colour = sprintf('b');
        elseif(DataCell{cellIdx}.Type == 'K')
            colour = sprintf('r');
        else
            colour = sprintf('k');
        end
        plot(DataCell{cellIdx}.averageEvent, colour);
        text(find(DataCell{cellIdx}.averageEvent==min(DataCell{cellIdx}.averageEvent)), min(DataCell{cellIdx}.averageEvent), num2str(cellIdx));
    end
end
hold off