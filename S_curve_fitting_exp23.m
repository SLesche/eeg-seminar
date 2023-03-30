% Setting paths
PATH_MAIN =  'C:\Users\slesche\Documents\MATLAB\eeg-seminar\'; % Pfad in dem die Rohdaten liegen 
PATH_ERP = fullfile(PATH_MAIN, 'erp/');
cd(PATH_MAIN)

% Path for files
PATH_ERP23 = 'D:\Exp23 EF and intelligence\Flanker-Modellierung\erp'

% Load erpfiles
[ERP ALLERP] = fetch_erp_files(PATH_ERP23, 'flanker');

% grand average
cd(PATH_ERP23);
grand_average = pop_loaderp(['Flanker_GA_ERP.erp']);

% plot 
plot(grand_average(1).times, grand_average(1).bindata(11, :, 1))

% Fit a function to GA
[params_ga, fit_ga, gof_ga] = return_grand_average_param(grand_average(1).times, grand_average(1).bindata(11, :, 1));

% Check fit visually
% plot(fit_ga, grand_average(1).times, grand_average(1).bindata(11, :, 1))
% Check function visually

% get an individual erp
subj_1_x = ALLERP(1).times;
subj_1_y = ALLERP(1).bindata(11, :, 1);

plot(subj_1_x, subj_1_y)

% Optimize to this erp
[fit_subj1, gof_subj1] = optimize_params_subj(subj_1_x, subj_1_y, params_ga);

plot(fit_subj1, subj_1_x, subj_1_y)
