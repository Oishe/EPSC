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
% don't include '.', '..', and '.git'
dirIdx = 3; % number of directories to remove during search
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
        fullFileNameNoExt = sprintf('%s/%s', thisdir,subdirinfo.name(1:end-4));
        % open .txt
        infoFile = fopen(sprintf('%s.txt', fullFileNameNoExt),'r');
        ABFName = sprintf('%s.abf', fullFileNameNoExt);
        % values in .txt
        MinuteTimes = fscanf(infoFile, '%f\n%f');
        DataCell{cellIdx}.fileName = ABFName;
        % include file or not
        if(MinuteTimes(1)<0)
            DataCell{cellIdx}.startTimeSample = -1;
        else
            %% load the ABF file
            [d,si,h]=abfload(ABFName);
            Fs = 1/(si*1e-6);
            DataCell{cellIdx}.Fs = Fs;
            % Parse start time
            isZeroStartMinuteTimes = MinuteTimes(1) == 0;
            startSample = isZeroStartMinuteTimes + (~isZeroStartMinuteTimes)*floor(MinuteTimes(1)*60*Fs);
            DataCell{cellIdx}.startSample = startSample;
            % Parse stop time
            isToEndMinuteTimes = MinuteTimes(2) <0;
            stopSample = (isToEndMinuteTimes)*(length(d)) + (~isToEndMinuteTimes)*(floor(MinuteTimes(2)*60*Fs));
            DataCell{cellIdx}.stopSample = stopSample;
            %% Local Patch and LPF Filtering
            patch = d(startSample:stopSample,2);
            lpf = d(startSample:stopSample,1);
            % Considering not storing the actual patch
            % DataCell{idxCell}.patch = patch;
            % DataCell{idxCell}.lpf = lpf;
            disp('----------Filtering----------');
%             disp(fullFileNameNoExt);
            decimateValue = 25;
            newFs = floor(Fs/decimateValue);
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
            stdPatchFilter = movstd(patchFilter,[stdWindow 0],1,'Endpoints', 'shrink');
            meanPatchFilter = movmean(patchFilter,[stdWindow 0],'Endpoints', 'shrink');
            %% Thresholding
            stdThreshold = 4;
            detectThreshold = abs(patchFilter-meanPatchFilter)>(stdThreshold*stdPatchFilter);
            % detectThreshold = stdPatchFilter>stdThreshold;
            %% Mask
            % 10* 1ms = 10ms
            points = 10; % spreading over points
            mask = conv(double(detectThreshold), ones(points,1), 'same');
            %% Finding events + Average
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
            averageEvent = zeros(averageWindow,1);
            peakval = zeros(numOfEvents,1);
            GRAPH = false;
            if GRAPH; figure; hold on; end;
            for eventIdx = 1:numOfEvents
                eventStartSample = floor(idx(diffIdx(eventIdx)+1))*25;
                DataCell{cellIdx}.events{eventIdx}.eventStartSample = eventStartSample;
                eventStopSample = floor(idx(diffIdx(eventIdx+1)))*25;
                DataCell{cellIdx}.events{eventIdx}.eventStopSample = eventStopSample;
                baseline = mean(patch(eventStartSample:(eventStartSample+baselineWindow-1)));
                DataCell{cellIdx}.events{eventIdx}.baseline = baseline;
                % smooth
                % oneEvent = smooth(patch(eventStartSample:(eventStartSample+averageWindow-1)),20)-baseline;
                % original
                oneEvent = patch(eventStartSample:(eventStartSample+averageWindow-1))-baseline;
                averageEvent = averageEvent + oneEvent;
                if GRAPH; plot(oneEvent); end;
                peakval(eventIdx) = min(oneEvent);
                
            end
            if GRAPH; hold off; end;
            rejects=find(peakval<(mean(peakval)-3*std(peakval)));
            if length(rejects)>1
                for rejectsIdx = 1:length(rejects)
                    rejectStartSample = DataCell{cellIdx}.events{rejects(rejectsIdx)}.eventStartSample;
                    averageEvent = averageEvent - patch(rejectStartSample:(rejectStartSample+averageWindow-1))+DataCell{cellIdx}.events{rejects(rejectsIdx)}.baseline;
                end
            else
                rejectStartSample = DataCell{cellIdx}.events{rejects}.eventStartSample;
                averageEvent = averageEvent - patch(rejectStartSample:(rejectStartSample+averageWindow-1))+DataCell{cellIdx}.events{rejects}.baseline;
            end
            averageEvent = averageEvent./numOfEvents;
            DataCell{cellIdx}.averageEvent = averageEvent;

            if GRAPH
                figure
                plot(averageEvent);
                title('Average Event');
                disp('----------Done Cell----------');
            end
        end
    end
end


%% Save Data Structure
% include serialize save
saveDataCell = true;
saveSerialDataCell = false;
if saveDataCell
    save ('DataCell.mat', 'DataCell', '-v7.3');
end
% Doesn't work yet
if saveSerialDataCell
    bytes = serialData.hlp_serialize(DataCell);
    save ('SerialDataCell.mat', 'bytes', '-v7.3');   
end











