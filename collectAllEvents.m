    load Data.mat
for i = 1:length(Data.cell)
    if(Data.cell(i).startTimeSample == -1)
        continue
    else
%        helperPlot = true;
       helperPlot = false;
       Data.cell(i).events = collectEvents(Data.cell(i).lpf, Data.cell(i).patch, Data.cell(i).patchFilter, Data.cell(i).Fs, helperPlot);
%        keyboard
%        close all
    end
end
clearvars -except Data
save Data.mat Data -v7.3