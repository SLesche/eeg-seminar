function [ERP, ALLERP] = fetch_erp_files(path, keyword)
% Return all files ending in ERP with a keyword
list = dir([path,'\*', keyword,'*.erp']);
arr = {};
for i = 1:length(list)
    arr{i} = list(i).name;
end

[ERP ALLERP] = pop_loaderp('filename', arr, 'filepath', path);
end