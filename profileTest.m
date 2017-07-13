%% test signal
fs=25000;
t=0:1/fs:60;
x=square(2*pi*60*t);
%% decimate signal
fstart=5;
fstop=55;
wstart=2*pi*fstart/fs;
wstop=2*pi*fstop/fs;
b=fir1(4000,[wstart wstop]);
y=filtfilt(b,1,x);
%% frequency analysis
X = fft(x);
Y = fft(y);
f = (1:floor(L/2))*fs/L;
powerX = abs(X(1:floor(L/2)));
powerY = abs(Y(1:floor(L/2)));
%% display
displayGraph = true;
displaySpectogram=true;
if displayGraph
    figure;
    tax(1) = subplot(2,1,1);
    plot(t,x);
    tax(2) = subplot(2,1,2);
    plot(t,y);
    linkaxes(tax,'xy');
    figure;
    fax(1) = subplot(2,1,1);
    plot(f,powerX);
    fax(2) = subplot(2,1,2);
    plot(f,powerY);
    linkaxes(fax,'xy');
end