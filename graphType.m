load DataCell.mat
%% discard which ones not to graph
% boolean array: 1 = include, 0 = don't include
includeCell = ones(numel(DataCell),1);
%Kynurenic
includeCell(2) = 0;
includeCell(9) = 0;
%Picrotoxin
includeCell(4) = 0;
includeCell(6) = 0;
includeCell(9) = 0;
%% graph together
figure;
hold on;
for cellIdx = 1:numel(DataCell)
    if (~includeCell(cellIdx))
        continue;
    elseif (DataCell{cellIdx}.startSample == -1)
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