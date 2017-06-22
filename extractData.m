Data = [];

dirinfo = dir();
dirinfo(~[dirinfo.isdir]) = [];  %remove non-directories
for K = 3 : length(dirinfo) % don't include '.' and '..'
    thisdir = dirinfo(K).name;
    subdirinfo = dir(fullfile(thisdir, '*.abf'));
    % Include forloop iteration if more than one file insubdirinfo
    fileName = sprintf('%s/%s', thisdir, subdirinfo.name);
    infoFile = fopen(sprintf('%s/info.txt', thisdir),'r');
    times = fscanf(infoFile, '%f\n%f');
    Data.cell(K-2).filename = fileName;
    if(times(1)>0)
        [d,si,h]=abfload(fileName);
        Data.cell(K-2).si = si;
        Fs = 1/(si*1e-6);
        Data.cell(K-2).fs = Fs;
        StartTimeSample = floor(times(1)*60*Fs);
        Data.cell(K-2).startTimeSample = StartTimeSample;
        if(times(2)>0)
            StopTimeSample = floor(times(2)*60*Fs);
            Data.cell(K-2).stopTimeSample = StopTimeSample;
            Data.cell(K-2).patch = d(StartTimeSample:StopTimeSample,2);
            Data.cell(K-2).lpf = d(StartTimeSample:StopTimeSample,1);
        else
            Data.cell(K-2).stopTimeSample = -1;
            Data.cell(K-2).patch = d(StartTimeSample:end,2);
            Data.cell(K-2).lpf = d(StartTimeSample:end,1);
        end
    else
        Data.cell(K-2).startTimeSample = -1;
    end
end
save Data.mat Data
clearvars -except Data