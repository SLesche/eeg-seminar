% Script aiming to download data from moodle folder.

% Set folder it is downloaded to
mkdir(fullfile('C:/Users/Sven/Documents/Psychologie/Seminare/EEG/data_coding_task'))
path_data_folder = 'C:/Users/Sven/Documents/Psychologie/Seminare/EEG/data_coding_task'

% getting url
url_base = 'https://heibox.uni-heidelberg.de/d/199b355d2d6f4f5b84f3/files/?p=%2F'
url_download = '&dl=1'
url_eeg = {};
for i = 1:20
    if i < 10
        url_eeg{i} = strcat(url_base, 'Exp23_000', num2str(i), '.eeg', url_download);
    else 
        url_eeg{i} = strcat(url_base, 'Exp23_00', num2str(i), '.eeg', url_download);
    end 
end

url_vhdr = {};
for i = 1:20
    if i < 10
        url_vhdr{i} = strcat(url_base, 'Exp23_000', num2str(i), '.vhdr', url_download);
    else 
        url_vhdr{i} = strcat(url_base, 'Exp23_00', num2str(i), '.vhdr', url_download);
    end 
end

url_vmrk = {};  
for i = 1:20
    if i < 10
        url_vmrk{i} = strcat(url_base, 'Exp23_000', num2str(i), '.vmrk', url_download);
    else 
        url_vmrk{i} = strcat(url_base, 'Exp23_00', num2str(i), '.vmrk', url_download);
    end 
end

% Reading in all vhdr data
for i = 1:20
    urlwrite(url_vhdr{i}, strcat('data_', num2str(i), '.vhdr'))
end

% Reading in all vmrk data
for i = 1:20
    urlwrite(url_vmrk{i}, strcat('data_', num2str(i), '.vmrk'))
end

% Reading in all eeg data
for i = 1:20
    urlwrite(url_eeg{i}, strcat('data_', num2str(i), '.eeg'))
end
