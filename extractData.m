Data = [];

dirinfo = dir();
dirinfo(~[dirinfo.isdir]) = [];  %remove non-directories
idx = 3;
for K = (idx+1): length(dirinfo) % don't include '.', '..', and '.git'
    thisdir = dirinfo(K).name;
    subdirinfo = dir(fullfile(thisdir, '*.abf'));
    % Include forloop iteration if more than one file insubdirinfo
    fileName = sprintf('%s/%s', thisdir, subdirinfo.name);
    infoFile = fopen(sprintf('%s/info.txt', thisdir),'r');
    times = fscanf(infoFile, '%f\n%f');
    Data.cell(K-idx).filename = fileName;
    if(times(1)>0)
        [d,si,h]=abfload(fileName);
        Data.cell(K-idx).si = si;
        Fs = 1/(si*1e-6);
        Data.cell(K-idx).fs = Fs;
        StartTimeSample = floor(times(1)*60*Fs);
        Data.cell(K-idx).startTimeSample = StartTimeSample;
        if(times(2)>0)
            StopTimeSample = floor(times(2)*60*Fs);
            Data.cell(K-idx).stopTimeSample = StopTimeSample;
            Data.cell(K-idx).patch = d(StartTimeSample:StopTimeSample,2);
            Data.cell(K-idx).lpf = d(StartTimeSample:StopTimeSample,1);
        else
            Data.cell(K-idx).stopTimeSample = -1;
            Data.cell(K-idx).patch = d(StartTimeSample:end,2);
            Data.cell(K-idx).lpf = d(StartTimeSample:end,1);
        end
    else
        Data.cell(K-idx).startTimeSample = -1;
    end
end
save Data.mat Data
sprintf('finished extractData')
clearvars -except Data