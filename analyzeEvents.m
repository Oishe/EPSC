load Data.mat
smoothWindow = 10;
baselineWindow = 150;
for cellNum = 1:length(Data.cell)
    if (Data.cell(cellNum).startTimeSample == -1)
        continue
    else
        for eventNum = 1:length(Data.cell(cellNum).events)
            %% events().patchSmooth DE
            Data.cell(cellNum).events(eventNum).patchSmooth = ...
                smooth(Data.cell(cellNum).events(eventNum).patch, smoothWindow);
            %% events().patchStd SE
            Data.cell(cellNum).events(eventNum).patchStd = ...
                std(Data.cell(cellNum).events(eventNum).patch);
            %% events().lpfStd SE
            Data.cell(cellNum).events(eventNum).lpfStd = ...
                std(Data.cell(cellNum).events(eventNum).lpf);
            %% events().baseline SE
            Data.cell(cellNum).events(eventNum).baseline = ...
                mean(Data.cell(cellNum).events(eventNum).patchSmooth(1:baselineWindow));
            %% events().patchSmoothNoDC DE
            Data.cell(cellNum).events(eventNum).patchSmoothNoDC = ...
                Data.cell(cellNum).events(eventNum).patchSmooth - Data.cell(cellNum).events(eventNum).baseline;
            %% events().amplitude SE
            Data.cell(cellNum).events(eventNum).amplitude = ...
                min(Data.cell(cellNum).events(eventNum).patchSmoothNoDC);
        end
        %% DisplayEvents DE
%         displayEvents(Data.cell(cellNum).events, 'patch');
        displayEvents(Data.cell(cellNum).events, 'patchSmoothNoDC');
        %% StatsEvents SE
%         statsEvents(Data.cell(cellNum).events, 'patchStd')
%         statsEvents(Data.cell(cellNum).events, 'lpfStd')
%         statsEvents(Data.cell(cellNum).events, 'baseline')
%         statsEvents(Data.cell(cellNum).events, 'amplitude')
        %% Average sample
        eventStarts = [Data.cell(cellNum).events.startSample];
        eventEnds = eventStarts + 500;
        baselines = transpose([Data.cell(cellNum).events.baseline]);
        sumEvents = Data.cell(cellNum).patch(eventStarts(1):eventEnds(1)) - baselines(1);
        
        for K = 2:length(eventStarts)
            sumEvents = sumEvents + Data.cell(cellNum).patch(eventStarts(K):eventEnds(K)) - baselines(K);
        end
        normEvents = sumEvents ./ length(eventStarts);
        figure;
        plot(normEvents);
    end
end