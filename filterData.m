function [patchFilter] = filterData(patch, fs)
    fstart = 5;
    fstop= 55;
    wstart = 2*pi*fstart/fs;
    wstop = 2*pi*fstop/fs;
    b = fir1(4000,[wstart wstop]);
    patchFilter = filtfilt(b,1,patch);
end