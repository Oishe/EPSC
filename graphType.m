load DataCell.mat
numOfCells = numel(DataCell);
%% Plot trace of each cell
figure;
meanDecays(numOfCells) = 0;
meanAmplitudes(numOfCells) = 0;
meanColors(numOfCells) = 0;
meanTexts(numOfCells) = 0;
hold on;
for cellIdx = 1:numOfCells
    if (DataCell{cellIdx}.startSample == -1)
        meanDecays(cellIdx) = NaN;
        meanAmplitudes(cellIdx) = NaN;
        meanColors(cellIdx) = 'k';
        meanTexts(cellIdx) = cellIdx;
        continue;
    else
        if(DataCell{cellIdx}.Type == 'W')
            meanColors(cellIdx) ='b';
            colour = sprintf('b');
        elseif(DataCell{cellIdx}.Type == 'K')
            meanColors(cellIdx) = 'r';
            colour = sprintf('r');
        else
            meanColors(cellIdx) = 'k';
            colour = sprintf('k');
        end
        meanDecays(cellIdx) = mean(DataCell{cellIdx}.decays);
        meanAmplitudes(cellIdx) = mean(DataCell{cellIdx}.amplitudes);
        meanTexts(cellIdx) = cellIdx;
        %single trace
        plot(DataCell{cellIdx}.averageEvent, colour);
        text(find(DataCell{cellIdx}.averageEvent==min(DataCell{cellIdx}.averageEvent)), min(DataCell{cellIdx}.averageEvent), num2str(cellIdx));
    end
end
hold off
%% Plot median points
meanTexts(isnan(meanDecays)) = [];
meanColors(isnan(meanDecays)) = [];
meanAmplitudes(isnan(meanDecays)) = [];
meanDecays(isnan(meanDecays)) = [];
figure;
hold on
scatter(meanDecays, meanAmplitudes, 30, meanColors);
for textIdx = 1:numel(meanTexts)
    text(meanDecays(textIdx), meanAmplitudes(textIdx),num2str(meanTexts(textIdx)));
end
xlabel('decay');
ylabel('amplitude');