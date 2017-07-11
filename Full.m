%% FULL SCRIPT
% to call everything in order to avoid loading and saving times

%% Extract ABF files

dirinfo = dir();		% list of all the directories in main
dirinfo(~[dirinfo.isdir]) = [];  % remove non-directories
DataCell{length(dirinfo)} = 0;		% Pre-allocate DataCell + 3 positions
idx = 3; % number of directories to remove during search
% don't include '.', '..', and '.git'
for K = 1: (length(dirinfo) - idx)
    thisdir = dirinfo(K+idx).name; % each cell directory
    % Search for text file to indicate files of importance
    subdirinfo = dir(fullfile(thisdir, '*.txt'));
    % If no .txt found set check value to -1
    if(isempty(subdirinfo))
    	DataCell{K}.startSample = -1;
	else
		% Include forloop iteration if more than one file insubdirinfo
		for L = 1: numel(subdirinfo) %#ok<ALIGN>
		    fileNameNoExt = sprintf('%s/%s', thisdir, subdirinfo(L).name(1:end-4));
		    % open .txt
            infoFile = fopen(sprintf('%s.txt', fileNameNoExt),'r');
		    ABFName = sprintf('%s.abf', fileNameNoExt);
		    % values in .txt
            MinuteTimes = fscanf(infoFile, '%f\n%f');
		    DataCell{K+L-1}.fileName = ABFName;
            % include file or not
		    if(MinuteTimes(1)<0)
                DataCell{K+L-1}.startTimeSample = -1;
            else
                % load the ABF file
                [d,si,h]=abfload(ABFName);
		        Fs = 1/(si*1e-6);
		        DataCell{K+L-1}.Fs = Fs;
                % Parse start time
                isZeroStartMinuteTimes = MinuteTimes(1) == 0;
                startSample = isZeroStartMinuteTimes + (~isZeroStartMinuteTimes)*floor(MinuteTimes(1)*60*Fs);
		        DataCell{K+L-1}.startSample = startSample;
                % Parse stop time
                isToEndMinuteTimes = MinuteTimes(2) <0;
                stopSample = (isToEndMinuteTimes)*(length(d)) + (~isToEndMinuteTimes)*(floor(MinuteTimes(2)*60*Fs));
                DataCell{K+L-1}.stopSample = stopSample;
                %Local Patch and LPF
                patch = d(startSample:stopSample,2);
                lpf = d(startSample:stopSample,1);
                % Considering not storing the actual patch
%                 DataCell{K+L-1}.patch = patch;
%                 DataCell{K+L-1}.lpf = lpf;
		    end
        end
    end
end


%% Save Data Structure
% include serialize save
save ('DataCell.mat', 'DataCell', '-v7.3');