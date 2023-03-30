% Setting paths
PATH_MAIN =  'C:\Users\slesche\Documents\MATLAB\eeg-seminar\'; % Pfad in dem die Rohdaten liegen 
PATH_ERP = fullfile(PATH_MAIN, 'erp/');
cd(PATH_MAIN)%wir ändern das working directory in unseren main Ordner

% Reading in data

% Individual ERP
eeglab
[ERP ALLERP] = pop_loaderp( 'filename', {'flanker_1.erp', 'flanker_2.erp', 'flanker_3.erp', 'flanker_4.erp', 'flanker_5.erp', 'flanker_6.erp',...
 'flanker_7.erp', 'flanker_8.erp', 'flanker_9.erp', 'flanker_10.erp', 'flanker_11.erp', 'flanker_12.erp', 'flanker_13.erp', 'flanker_14.erp',...
 'flanker_15.erp', 'flanker_16.erp', 'flanker_17.erp', 'flanker_18.erp', 'flanker_19.erp', 'flanker_20.erp'}, 'filepath',...
 PATH_ERP );

% Grand Average
erp_ga = pop_loaderp(strcat('erp/grand_average_flanker.erp'));

% time and value vector
ga_times = erp_ga(1).times;
ga_value_1 = erp_ga(1).bindata(11, :, 1);
erp_value_1 = ALLERP(1).bindata(11, :, 1);

% Curve fitting
% TODO: Save fitresult, GOF and plot
ga_param = return_grand_average_param(ga_times, ga_value_1, 9)


% Now optimize for subject data
subj_1_x = ALLERP(1).times;
subj_1_y = ALLERP(1).bindata(11,:,1);

fitresult_subj1 = optimize_params_subj(subj_1_x, subj_1_y, ga_param)

plot(fitresult_subj1, subj_1_x, subj_1_y)

