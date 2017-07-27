close all
figure;
hold on
fs = 25000;
newfs = 250;
D1 = designfilt('bandpassfir', 'StopbandFrequency1', 5,...
    'PassbandFrequency1', 20, 'PassbandFrequency2', 40,...
    'StopbandFrequency2', 50, 'StopbandAttenuation1', 60,...
    'PassbandRipple', 1, 'StopbandAttenuation2', 60,...
    'SampleRate', fs, 'DesignMethod', 'kaiserwin');
D2 = designfilt('bandpassfir', 'StopbandFrequency1', 5,...
    'PassbandFrequency1', 20, 'PassbandFrequency2', 40,...
    'StopbandFrequency2', 50, 'StopbandAttenuation1', 60,...
    'PassbandRipple', 1, 'StopbandAttenuation2', 60,...
    'SampleRate', newfs, 'DesignMethod', 'kaiserwin');
patch2 = patch(1:25000*2);
decimatepatch1 = decimate(patch2,10);
decimatepatch2 = decimate(decimatepatch1,10);
t1Vector = 1:1:length(patch2);
t1 = t1Vector*(1/fs);
t2Vector = 1:1:length(decimatepatch2);
t2 = t2Vector*(1/newfs);
plot(t1, patch2);
plot(t2, decimatepatch2);
hold off
figure
hold on
temp1 = filtfilt(D1,patch2);
temp2 = filtfilt(D2, decimatepatch2);
plot(t1,temp1)
plot(t2, temp2)
hold off
%%
figure
ax(1)= subplot(2,1,1);
plot(t1,patch2)
ax(2)= subplot(2,1,2);
plot(t2,abs(hilbert(temp2)))
linkaxes(ax,'x');
%%
window=1000;
kurts(length(patch))=0;
for idx = 1:(length(patch)-window)
    kurts(idx) = kurtosis(patch(idx:idx+window));
end
figure
plot(kurts);
    
   