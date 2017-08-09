load DataCell.mat
numOfCells = numel(DataCell);
%% Plot trace of each cell
% figures
traceFig = figure;
scatterFig = figure;
fftFig = figure;
% storing some values Pre-allocation
meanDecays(numOfCells) = 0;
meanAmplitudes(numOfCells) = 0;
% Loop through each cell
for cellIdx = 1:numOfCells
    % cells to discard
    if (DataCell{cellIdx}.startSample == -1)
        meanDecays(cellIdx) = NaN;
        meanAmplitudes(cellIdx) = NaN;
        continue;
    else
        % decide colour
        if(DataCell{cellIdx}.Type == 'W')
            colour = sprintf('b');
        elseif(DataCell{cellIdx}.Type == 'K')
            colour = sprintf('r');
        else
            colour = sprintf('k');
        end
        % plot the graphs
        meanDecays(cellIdx) = mean(DataCell{cellIdx}.decays);
        meanAmplitudes(cellIdx) = mean(DataCell{cellIdx}.amplitudes);
        % single trace
        figure(traceFig);
        hold on;
        plot(DataCell{cellIdx}.averageEvent, colour);
        text(find(DataCell{cellIdx}.averageEvent==min(DataCell{cellIdx}.averageEvent)), min(DataCell{cellIdx}.averageEvent), num2str(cellIdx));
        hold off;
        % scatter plot
        figure(scatterFig);
        hold on;
        scatter(meanDecays(cellIdx), meanAmplitudes(cellIdx), 30, colour);
        text(meanDecays(cellIdx), meanAmplitudes(cellIdx), num2str(cellIdx));
        hold off;
        % frequency plot
        figure(fftFig)
        hold on;
        plot(DataCell{cellIdx}.fLabel, DataCell{cellIdx}.averageFFT, colour);
        text(DataCell{cellIdx}.fLabel(end), DataCell{cellIdx}.averageFFT(end), num2str(cellIdx));
        hold off;
    end
end
%% Plot median points
figure(scatterFig);
xlabel('decay');
ylabel('amplitude');