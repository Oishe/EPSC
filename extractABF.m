dirinfo = dir();
dirinfo(~[dirinfo.isdir]) = [];  %remove non-directories
for K = 3 : length(dirinfo) % don't include '.' and '..'
    thisdir = dirinfo(K).name;
    subdirinfo = dir(fullfile(thisdir, '*.abf'));
    for i = 1:length(subdirinfo)
        fileName = sprintf('%s/%s', thisdir, subdirinfo(i).name);
        [d,si,h]=abfload(fileName);
        finalpath = sprintf('%s.mat', fileName(1:end-4));
        save(finalpath, 'd','si','h');
    end
end
