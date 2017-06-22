function displayEvents(events)
% displayEvents(Data.cell(x).events)
    eventFig = figure('Name','Events');
    hold on
    for K = 1:length(events)
        plot(events(K).patch);
    end
    hold off
end