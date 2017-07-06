function displayEvents(events, value)
% displayEvents(Data.cell(x).events, value)
% value = 'patch' / 'patchSmooth' / 'patchMovStd' / 'patchSmoothNoDC'
    
    if(strcmp(value,'patch'))
        figure('Name','events.patch');
        hold on
        for K = 1:length(events)
            plot(events(K).patch);
        end
    elseif(strcmp(value,'patchSmooth'))
        figure('Name','events.patchSmooth');
        hold on
        for K = 1:length(events)
            plot(events(K).patchSmooth);
        end
    elseif(strcmp(value,'patchMovStd'))
        figure('Name','events.patchMovStd');
        hold on
        for K = 1:length(events)
            plot(events(K).patchMovStd);
        end
    elseif(strcmp(value,'patchSmoothNoDC'))
        figure('Name','events.patchSmoothNoDC');
        hold on
        for K = 1:length(events)
            plot(events(K).patchSmoothNoDC);
        end
    end
    hold off
end