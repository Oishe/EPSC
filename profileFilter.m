%% test signal with FIR
% fs1=25000;
% t1=0:1/fs1:10;
% % signal
% % x=sin(2*pi*25*t)+sin(2*pi*100*t)+sin(2*pi*500*t);
% x = square (2*pi*50*t1)+square(2*pi*500*t1);
% %% frequency
% fstart=5;
% fstop=55;
% wstart=2*pi*fstart/fs1;
% wstop=2*pi*fstop/fs1;
% % FIR
% b=fir1(4000,[wstart wstop]);
% a = 1;
% y=filtfilt(b,a,x);
% %% frequency analysis
% L1 = 2^20;
% X = fft(x, L1);
% Y = fft(y, L1);
% f1 = (1:floor(L1/2))*fs1/L1;
% powerX = abs(X(1:floor(L1/2)));
% powerY = abs(Y(1:floor(L1/2)));
% %% Graphing
% displayGraph = true;
% displaySpectogram= true;
% displayFreqz = false;
% if displayGraph
%     figure;
%     tax(1) = subplot(2,1,1);
%     plot(t1,x);
%     tax(2) = subplot(2,1,2);
%     plot(t1,y);
%     linkaxes(tax,'xy');
% end
% if displaySpectogram
%     figure;
%     fax(1) = subplot(2,1,1);
%     plot(f1,powerX);
%     fax(2) = subplot(2,1,2);
%     plot(f1,powerY);
%     linkaxes(fax,'xy');
% end
% if displayFreqz
%     figure;
%     freqz(b,a);
% end
% %% cheby2 test
% fs1=25000;
% t1=0:1/fs1:10;
% % signal
% x=sin(2*pi*25*t1)+sin(2*pi*100*t1)+sin(2*pi*500*t1);
% % x = square(2*pi*50*t1)+square(2*pi*500*t1);
% %% frequency
% fstart=5;
% fstop=55;
% wstart=2*pi*fstart/fs1;
% wstop=2*pi*fstop/fs1;
% % cheby type 2
% % d = designfilt('bandpassiir', 'StopbandFrequency1', 5,...
% %     'PassbandFrequency1', 10, 'PassbandFrequency2', 50,...
% %     'StopbandFrequency2', 55, 'StopbandAttenuation1', 60,...
% %     'PassbandRipple', 1, 'StopbandAttenuation2', 60,...
% %     'SampleRate', 25000, 'DesignMethod', 'cheby2');
% d = designfilt('bandpassfir', 'StopbandFrequency1', 5,...
%     'PassbandFrequency1', 10, 'PassbandFrequency2', 50,...
%     'StopbandFrequency2', 55, 'StopbandAttenuation1', 60,...
%     'PassbandRipple', 1, 'StopbandAttenuation2', 60,...
%     'SampleRate', 25000, 'DesignMethod', 'kaiserwin');
% 
% y=filtfilt(d,x);
% %% frequency analysis
% L1 = 2^20;
% X = fft(x, L1);
% Y = fft(y, L1);
% f1 = (1:floor(L1/2))*fs1/L1;
% powerX = abs(X(1:floor(L1/2)));
% powerY = abs(Y(1:floor(L1/2)));
% %% Graphing
% displayGraph = true;
% displaySpectogram= true;
% displayFreqz = true;
% if displayGraph
%     figure;
%     tax(1) = subplot(2,1,1);
%     plot(t1,x);
%     tax(2) = subplot(2,1,2);
%     plot(t1,y);
%     linkaxes(tax,'x');
% end
% if displaySpectogram
%     figure;
%     fax(1) = subplot(2,1,1);
%     plot(f1,powerX);
%     fax(2) = subplot(2,1,2);
%     plot(f1,powerY);
%     linkaxes(fax,'x');
% end
% if displayFreqz
%     fvtool(d);
% end
%% Decimate Test
% fs1=25000;
% fs2 = 25000/64;
% t1=0:1/fs1:10;
% t2=0:1/fs2:10;
% % signal
% x=sin(2*pi*3*t1)+sin(2*pi*100*t1)+sin(2*pi*500*t1);
% % x = square (2*pi*50*t1)+square(2*pi*500*t1);
% %% frequency
% fstart=5;
% fstop=55;
% wstart=2*pi*fstart/fs1;
% wstop=2*pi*fstop/fs1;
% % FIR
% % b=fir1(4000,[wstart wstop]);
% % a = 1;
% % y=filtfilt(b,a,x);
% y1 = decimate(x,8);
% y = decimate(y1,8);
% %% frequency analysis
% L1 = 2^20;
% % L2 = 2^14;
% L2 = L1;
% X = fft(x, L1);
% Y = fft(y, L2);
% f1 = (1:floor(L1/2))*fs1/L1;
% f2 = (1:floor(L2/2))*fs2/L2;
% powerX = abs(X(1:floor(L1/2)));
% powerY = abs(Y(1:floor(L2/2)));
% %% Graphing
% displayGraph = true;
% displaySpectogram= true;
% displayFreqz = false;
% if displayGraph
%     figure;
%     tax(1) = subplot(2,1,1);
%     plot(t1,x);
%     tax(2) = subplot(2,1,2);
%     plot(t2,y);
%     linkaxes(tax,'xy');
% end
% if displaySpectogram
%     figure;
%     fax(1) = subplot(2,1,1);
%     plot(f1,powerX);
%     fax(2) = subplot(2,1,2);
%     plot(f2,powerY);
%     linkaxes(fax,'x');
% end
% if displayFreqz
%     figure;
%     freqz(b,a);
% end
%% Decimate and FIR
fs1=25000;
fs2 = floor(25000/100);
t1=1/fs1:1/fs1:10;
% t2=4e-5:1/fs2:10;
% signal
x=sin(2*pi*3*t1)+sin(2*pi*40*t1)+sin(2*pi*60*t1)+sin(2*pi*500*t1);
% x = square (2*pi*50*t1)+square(2*pi*500*t1);
%% decimate and FIR
y1 = decimate(x,10);
y2 = decimate(y1,10);

%% FIR filter
d = designfilt('bandpassfir', 'StopbandFrequency1', 5,...
    'PassbandFrequency1', 10, 'PassbandFrequency2', 50,...
    'StopbandFrequency2', 55, 'StopbandAttenuation1', 60,...
    'PassbandRipple', 1, 'StopbandAttenuation2', 60,...
    'SampleRate', fs2, 'DesignMethod', 'kaiserwin');

y=filtfilt(d,y2);

%% frequency analysis
L1 = 2^20;
% L2 = 2^14;
L2 = L1;
X = fft(x, L1);
Y = fft(y, L2);
f1 = (1:floor(L1/2))*fs1/L1;
f2 = (1:floor(L2/2))*fs2/L2;
powerX = abs(X(1:floor(L1/2)));
powerY = abs(Y(1:floor(L2/2)));
%% Graphing
displayGraph = true;
displaySpectogram= true;
displayFreq = false;
if displayGraph
    figure;
    tax(1) = subplot(2,1,1);
    plot(t1,x);
    tax(2) = subplot(2,1,2);
    t2 = linspace(min(t1),max(t1),length(y));
    plot(t2,y);
    linkaxes(tax,'xy');
end
if displaySpectogram
    figure;
    fax(1) = subplot(2,1,1);
    plot(f1,powerX);
    fax(2) = subplot(2,1,2);
    plot(f2,powerY);
    linkaxes(fax,'x');
end
if displayFreq
    figure;
    fvt = fvtool(b,a,'Fs',fs2);
end