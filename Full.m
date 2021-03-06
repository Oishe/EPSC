%% FULL SCRIPT
% to call everything in order to avoid loading and saving times
clear;
%% Pre-calls
% FIR design
D = designfilt('bandpassfir', 'StopbandFrequency1', 5,...
    'PassbandFrequency1', 15, 'PassbandFrequency2', 150,...
    'StopbandFrequency2', 200, 'StopbandAttenuation1', 60,...
    'PassbandRipple', 1, 'StopbandAttenuation2', 40,...
    'SampleRate', 1000, 'DesignMethod', 'kaiserwin');
% % IIR design
% D = designfilt('highpassiir', 'StopbandFrequency', 10,...
%     'PassbandFrequency', 20, 'StopbandAttenuation', 60,...
%     'PassbandRipple', 1, 'SampleRate', 1000);

%% Extract ABF files
dirinfo = dir();		% list of all the directories in main
dirinfo(~[dirinfo.isdir]) = [];  % remove non-directories
% don't include '+profile', '.', '..', and '.git'
dirIdx = 4; % number of directories to remove during search
numOfFolders = (length(dirinfo) - dirIdx);
DataCell{numOfFolders} = {};		% Pre-allocate DataCell - idx positions
disp('----------Extracting----------');
% going through each cell in directory
for cellIdx = 1:numOfFolders
    thisdir = dirinfo(cellIdx+dirIdx).name; % each cell directory
    % Search for text file to indicate files of importance
    subdirinfo = dir(fullfile(thisdir, '*.txt'));
    % If no .txt found set check value to -1
    if(isempty(subdirinfo))
    	DataCell{cellIdx}.startSample = -1;
    else
        %% Parsing the *.txt
        fullFileNameNoExt = sprintf('%s/%s', thisdir,subdirinfo.name(1:end-4));
        ABFName = sprintf('%s.abf', fullFileNameNoExt);
        % open .txt and parse
        infoFile = fopen(sprintf('%s.txt', fullFileNameNoExt),'r');
        MinuteTimes = [str2double(fgetl(infoFile)); str2double(fgetl(infoFile))];
        Type = fgetl(infoFile);
        Age = str2double(fgetl(infoFile));
        Gender = fgetl(infoFile);
        fclose(infoFile);
        DataCell{cellIdx}.fileName = ABFName;
        % include file or not
        if(MinuteTimes(1)<0)
            DataCell{cellIdx}.startSample = -1;
        else
            %% load the ABF file
            [d,si,h]=abfload(ABFName);
            Fs = 1/(si*1e-6);
            DataCell{cellIdx}.Fs = Fs;
            % Parse start time
            isZeroStartMinuteTimes = MinuteTimes(1) == 0;
            startSample = isZeroStartMinuteTimes...
                + (~isZeroStartMinuteTimes)*floor(MinuteTimes(1)*60*Fs);
            DataCell{cellIdx}.startSample = startSample;
            % Parse stop time
            isToEndMinuteTimes = MinuteTimes(2) <0;
            stopSample = (isToEndMinuteTimes)*(length(d))...
                + (~isToEndMinuteTimes)*(floor(MinuteTimes(2)*60*Fs));
            DataCell{cellIdx}.stopSample = stopSample;
            % include Cell information
            DataCell{cellIdx}.Type = Type;
            DataCell{cellIdx}.Age = Age;
            DataCell{cellIdx}.Gender = Gender;
            %% Local Patch and LPF Filtering
            patch = d(startSample:stopSample,2);
            lfp = d(startSample:stopSample,1);
            % Not storing patch or lfp
            % DataCell{idxCell}.patch = patch;
            % DataCell{idxCell}.lfp = lfp;
            disp('----------Filtering----------');
            % disp(fullFileNameNoExt);
            decimateValue = 25;
            newFs = floor(Fs/decimateValue);
            DataCell{cellIdx}.decimateValue = decimateValue;
            DataCell{cellIdx}.newFs = newFs;
            patchDecimateFirst = decimate(patch,5);
            patchDecimate = decimate(patchDecimateFirst,5);
            % FIR with newFs
%             d = designfilt('bandpassfir', 'StopbandFrequency1', 5,...
%             'PassbandFrequency1', 10, 'PassbandFrequency2', 50,...
%             'StopbandFrequency2', 55, 'StopbandAttenuation1', 60,...
%             'PassbandRipple', 1, 'StopbandAttenuation2', 60,...
%             'SampleRate', newFs, 'DesignMethod', 'kaiserwin');
            patchFilter = filtfilt(D,patchDecimate);
            disp('----------done filtering----------');
            %% Moving Standard Deviation on patchFilter
            % window duration = 40ms
            stdWindow = floor(40e-3*newFs);
            DataCell{cellIdx}.stdWindow = stdWindow;
            stdPatchFilter = movstd(patchFilter,[stdWindow 0],1,'Endpoints', 'shrink');
            meanPatchFilter = movmean(patchFilter,[stdWindow 0],'Endpoints', 'shrink');
            %% Thresholding
            stdThreshold = 3.8;
            DataCell{cellIdx}.stdThreshold = stdThreshold;
            detectThreshold = abs(patchFilter-meanPatchFilter)>(stdThreshold*stdPatchFilter);
            % detectThreshold = stdPatchFilter>stdThreshold;
            %% Mask
            % 10* 1ms = 10ms
            spreadPoints = 10; % spreading over points
            DataCell{cellIdx}.spreadTime = spreadPoints*1000/newFs;
            mask = conv(double(detectThreshold), ones(spreadPoints,1), 'same');
            %% Finding events
            % finding where the non-zero idx numbers jump more than by 1
            % the discontinuity is a new event
            idx = find(mask>0);
            diffIdx = find(diff(idx)>1);
            numOfEvents = length(diffIdx)-1;
            % preallocate
            DataCell{cellIdx}.events{numOfEvents}.startSample = 0;
            DataCell{cellIdx}.events{numOfEvents}.stopSample = 0;
            % finding a baseline and summing the events
            baselineWindow = 60;
            averageWindow = 600;
            DataCell{cellIdx}.baselineWindow=baselineWindow;
            DataCell{cellIdx}.averageWindow=averageWindow;
            % preallocate
            L = 2^9; % length of FFT
            sumEvents = zeros(averageWindow,1);
            sumFFT = zeros(2^9,1);
            amplitudes = zeros(numOfEvents,1);
            decays = zeros(numOfEvents,1);
            areas = zeros(numOfEvents,1);
            %% Analyzing events + Averaging + Graphing
            GRAPH = false;
            if GRAPH; figure; movegui('northwest'); hold on; end;
            for eventIdx = 1:numOfEvents
                eventStartSample = floor(idx(diffIdx(eventIdx)+1))*25;
                DataCell{cellIdx}.events{eventIdx}.eventStartSample = eventStartSample;
                eventStopSample = floor(idx(diffIdx(eventIdx+1)))*25;
                DataCell{cellIdx}.events{eventIdx}.eventStopSample = eventStopSample;
                baseline = mean(patch(eventStartSample:(eventStartSample+baselineWindow-1)));
                % baseline
                DataCell{cellIdx}.events{eventIdx}.baseline = baseline;
                % oneEvent adjusted
                oneEvent = patch(eventStartSample:(eventStartSample+averageWindow-1))-baseline;
                sumEvents = sumEvents + oneEvent;
                % FFT events
                sumFFT = sumFFT + abs(fft(oneEvent,L));
                if GRAPH; plot(oneEvent); end;
                % amplitude
                smoothOneEvent = smooth(oneEvent,5);
                amplitudes(eventIdx) = min(smoothOneEvent);
                DataCell{cellIdx}.events{eventIdx}.amplitude = amplitudes(eventIdx);
                % RC 0.67 decay from amplitude
                minPoint = mean(find(smoothOneEvent==amplitudes(eventIdx)));
                decay67Point = find(smoothOneEvent<(0.67*amplitudes(eventIdx)), 1, 'last');
                decay67 = decay67Point - minPoint;
%                 disp(decay67);
                decays(eventIdx) = decay67;
                DataCell{cellIdx}.events{eventIdx}.decays = decays(eventIdx);
%                 disp(' ');
                % Area under event
                areas(eventIdx) = abs(sum(patch(eventStartSample:eventStopSample)-baseline));
            end
            if GRAPH; hold off; end;
            %% Rejecting Noise + Updating Average
            % getting rid of events larger than 3std
            rejects = find(amplitudes<(mean(amplitudes)-2*std(amplitudes)));
%             rejects = [rejects find(amplitudes < 500) || decays > 400 );
            for rejectsIdx = 1 : length(rejects)
                rejectStartSample = DataCell{cellIdx}.events{rejects(rejectsIdx)}.eventStartSample;
                rejectStopSample = rejectStartSample + averageWindow - 1;
                sumEvents = sumEvents - patch(rejectStartSample:rejectStopSample)...
                    + DataCell{cellIdx}.events{rejects(rejectsIdx)}.baseline;
                sumFFT = sumFFT - abs(fft((patch(rejectStartSample:rejectStopSample)...
                    - DataCell{cellIdx}.events{rejects(rejectsIdx)}.baseline),L));
            end
            % deleteing rejected events from arrays
            DataCell{cellIdx}.events(rejects) = [];
            amplitudes(rejects) = [];
            decays(rejects) = [];
            areas(rejects) = [];
            numOfEvents = numOfEvents - length(rejects);
            averageEvent = sumEvents./numOfEvents;
            averageFFT = sumFFT/L/numOfEvents;
            averageFFT = averageFFT(1:L/2+1);
            % storing cell specific information
            DataCell{cellIdx}.decays = decays;
            DataCell{cellIdx}.numOfEvents = numOfEvents;
            DataCell{cellIdx}.averageEvent = averageEvent;
            DataCell{cellIdx}.averageFFT = averageFFT;
            DataCell{cellIdx}.amplitudes = amplitudes;
            DataCell{cellIdx}.areas = areas;
            f = Fs*(0:(L/2))/L;
            DataCell{cellIdx}.fLabel = f;
            if GRAPH
                pause(1)
                figure;
                movegui('northeast');
                plot(averageEvent);
                title('Average Event');
                pause(1)
                figure;
                movegui('southwest');
                plot(f,averageFFT);
                xlabel('f(Hz)');
                title('Average FFT');
                pause(1)
                figure;
                movegui('southeast');
                subplot(3,3,1);
                histogram(amplitudes)
                title('amplitudes');
                subplot(3,3,4);
                histogram(decays);
                title('decays');
                subplot(3,3,7);
                histogram(areas);
                title('areas');
                subplot(3,3,[2;3;5;6;8;9])
                scatter3(decays,amplitudes, areas);
                xlabel('decay');
                ylabel('amplitude');
                zlabel('area');
            end
            disp('NumberOfEvents=');
            disp(numOfEvents);
            disp('----------Done Cell----------');
            close all;
        end
    end
end


%% Save Data Structure
% include serialize save
saveDataCell = true;
if saveDataCell
    save ('DataCell.mat', 'DataCell', '-v7.3');
end










