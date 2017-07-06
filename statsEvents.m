function statsEvents(events, value)
% statsEvents(Data.cell(x).events, value)
% value = 'patchStd' / 'lpfStd' / 'baseline' / 'amplitude' /x 'width'
    if(strcmp(value,'patchStd'))
        figure('Name','events.patchStd');
        histogram(abs([events.patchStd]),50);
    elseif(strcmp(value,'lpfStd'))
        figure('Name','events.lpfStd');
        histogram(abs([events.lpfStd]),50);
    elseif(strcmp(value,'baseline'))
        figure('Name','events.baseline');
        histogram(abs([events.baseline]),50);
    elseif(strcmp(value,'amplitude'))
        figure('Name','events.amplitude');
        histogram(abs([events.amplitude]),50);
    end
end