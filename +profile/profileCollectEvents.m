%% to contiure after filtering
%% fft check
% L1 = 2^14;
% patchx = patchFilter;
% PatchX = fft(patchx, L1);
% f1 = (2:floor(L1/2))*newFs/L1;
% powerX = abs(PatchX(2:floor(L1/2)));
% figure;
% plot(f1,powerX);
%% Decimate Check
% t1Vector = 1:1:length(patch);
% t1 = t1Vector*(1/Fs);
% t2Vector = 1:1:length(patchDecimate);
% t2 = t2Vector*(1/newFs);
% 
% decimate = figure('Name','regular vs Decimate','NumberTitle','off');
% Dax(1) = subplot(2,1,1);
% plot(t1, patch);
% xlabel('seconds');
% title('regular');
% Dax(2) = subplot(2,1,2);
% plot(t2, patchDecimate);
% xlabel('seconds');
% title('patchDecimatex20');
% linkaxes(Dax,'xy');
%% Filter Check
% t1Vector = 1:1:length(patch);
% t1 = t1Vector*(1/Fs);
% t2Vector = 1:1:length(patchDecimate);
% t2 = t2Vector*(1/newFs);
% 
% decimate = figure('Name','regular vs decimate vs filter','NumberTitle','off');
% Dax(1) = subplot(3,1,1);
% plot(t1, patch);
% xlabel('seconds');
% title('regular');
% Dax(2) = subplot(3,1,2);
% plot(t2, patchDecimate);
% xlabel('seconds');
% title('patchDecimatex20');
% Dax(3) = subplot(3,1,3);
% plot(t2, patchFilter);
% xlabel('seconds');
% title('filter [5(20|135)150]');
% linkaxes(Dax,'x');


%% Moving Standard Deviation on patchFilter
% window duration = 25ms
stdWindow = floor(25e-3*newFs);
stdPatchFilter = movstd(patchFilter,[stdWindow 0],1,'Endpoints', 'shrink');
%% Thresholding
stdThreshold = 4;
% detectThreshold = abs(patchFilter)>(stdThreshold*stdPatchFilter);
detectThreshold = stdPatchFilter>stdThreshold;
%% Mask
% 10* 1ms = 10ms
points = 10; % spreading over points
mask = conv(double(detectThreshold), ones(points,1), 'same');
% mask = mask>0;
%% plot mask
% t1Vector = 1:1:length(patch);
% t1 = t1Vector*(1/Fs);
% t2Vector = 1:1:length(patchDecimate);
% t2 = t2Vector*(1/newFs);
% 
% rawFig = figure('Name','maskedPatch','NumberTitle','off');
% ax(1) = subplot(3,1,1);
% plot(t1,patch);
% title('patch');
% ax(2) = subplot(3,1,2);
% hold on;
% plot(t2,stdPatchFilter);
% plot(t2,stdThreshold*stdPatchFilter./stdPatchFilter);
% title('stdPatchFilter');
% hold off;
% ax(3) = subplot(3,1,3);
% plot(t2,mask);
% title('mask');
% maskedPatch = mask.*patchFilter;
% linkaxes(ax,'x');
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
baselineWindow = 150;
averageWindow = 600;
DataCell{cellIdx}.baselineWindow=baselineWindow;
DataCell{cellIdx}.averageWindow=averageWindow;
% preallocate
averageEvent = zeros(averageWindow,1);
figure;
hold on;
for eventIdx = 1:numOfEvents
    eventStartSample = floor(idx(diffIdx(eventIdx)+1));
    DataCell{cellIdx}.events{eventIdx}.eventStartSample = eventStartSample;
    eventStopSample = floor(idx(diffIdx(eventIdx+1)));
    DataCell{cellIdx}.events{eventIdx}.eventStopSample = eventStopSample;
    baseline = mean(patch(eventStartSample:(eventStartSample+baselineWindow-1)));
    DataCell{cellIdx}.events{eventIdx}.baseline = baseline;
    oneEvent = smooth(patch(eventStartSample:(eventStartSample+averageWindow-1)),20);
    averageEvent = averageEvent+ oneEvent -baseline;
    plot(oneEvent);
end
hold off

DataCell{cellIdx}.averageEvent = averageEvent./numOfEvents;

figure
plot(averageEvent);
title('Average Event');






