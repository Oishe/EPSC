
function [events] = collectEvents(lpf, patch, patchFilter, fs, helperPlot)
    %% Moving Standard Deviation on patchFilter
    % 25000/25 * 40 us = 40ms window
    stdWindow = floor(fs/25);
    stdPatchFilter = movstd(patchFilter,[stdWindow 0]);
    %% Thresholding
    threshold = 4;
    detectThreshold = abs(patchFilter)>(threshold*stdPatchFilter);
    % detectThreshold = detectThreshold<(8*stdPatchFilter);
    %% Mask
    % 400*40 us = 16ms
    points = 400; % spreading over points
    mask = conv(double(detectThreshold), ones(points,1), 'same');
    mask = mask>0;
    %% Finding events
    idx = find(mask>0);
    diffIdx = find(diff(idx)>1);
    events(length(diffIdx)-1).startSample = 0;
    for K = 1:(length(diffIdx) - 1)
        events(K).startSample = floor(idx(diffIdx(K)+1));
        events(K).stopSample = floor(idx(diffIdx(K+1)));
        events(K).patch = patch(events(K).startSample:events(K).stopSample);
        events(K).lpf = lpf(events(K).startSample:events(K).stopSample);
        % finding movstd of raw patch
        tempPatch = patch((events(K).startSample-stdWindow):(events(K).stopSample+stdWindow));
        tempPatchStd = movstd(tempPatch,[stdWindow 0]);
        events(K).patchMovStd = tempPatchStd(stdWindow:(end-stdWindow));
    end
    %% helpful plotting
    if (helperPlot)
        rawFig = figure('Name','RawSignal','NumberTitle','off');
        ax(1) = subplot(2,1,1);
        plot(patch);
        title('patch');
        maskedPatch = mask.*patch;
        ax(2) = subplot(2,1,2);
        plot(maskedPatch);
        title('maskedPatch');
        signalFig = figure('Name','SignalTransformation','NumberTitle','off');
        ax(3) = subplot(4,1,1);
        plot(patchFilter);
        title('patchFilter');
        ax(4) = subplot(4,1,2);
%         hold on
        plot(stdPatchFilter);
%         plot(threshold*ones(length(stdPatchFilter)));
%         hold off
        title('stdPatchFilter');
        ax(5) = subplot(4,1,3);
        plot(detectThreshold);
        title('detectThreshold');
        ax(6) = subplot(4,1,4);
        plot(mask);
        title('mask');
        linkaxes(ax,'x');
        indexFig = figure('Name','Indexing','NumberTitle','off');
        subplot(2,1,1);
        plot(idx);
        title('idx');
        subplot(2,1,2);
        bar(diffIdx);
        title('diffIdx');
        %% Plots to close
%         close(rawFig);
%         close(signalFig);
        close(indexFig);
        
    end
    
end



