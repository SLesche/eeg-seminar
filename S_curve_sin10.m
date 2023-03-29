clear all

% Setting paths
PATH_MAIN =  'C:\Users\Sven\Documents\Psychologie\Seminare\EEG\'; % Pfad in dem die Rohdaten liegen 
PATH_ERP = fullfile(PATH_MAIN, 'erp/');
cd(PATH_MAIN)%wir ändern das working directory in unseren main Ordner

% Reading in data

% Individual ERP
eeglab
[ERP ALLERP] = pop_loaderp( 'filename', {'flanker_1.erp', 'flanker_2.erp', 'flanker_3.erp', 'flanker_4.erp', 'flanker_5.erp', 'flanker_6.erp',...
 'flanker_7.erp', 'flanker_8.erp', 'flanker_9.erp', 'flanker_10.erp', 'flanker_11.erp', 'flanker_12.erp', 'flanker_13.erp', 'flanker_14.erp',...
 'flanker_15.erp', 'flanker_16.erp', 'flanker_17.erp', 'flanker_18.erp', 'flanker_19.erp', 'flanker_20.erp'}, 'filepath',...
 'C:\Users\Sven\Documents\Psychologie\Seminare\EEG\erp\' );

% Grand Average
erp_ga = pop_loaderp(strcat('erp/grand_average_flanker.erp'));

% time and value vector
ga_times = erp_ga(1).times;
ga_value_1 = erp_ga(1).bindata(11, :, 1);
% Curve fitting

func y = sine_func(x, a1, b1, c1, a2, b2, c2, a3, b3, c3, a4, b4, c4, a5, b5, c5, a6, b6, c6, a7, b7, c7, a8, b8, c8, a9, b9, c9, a10, b10, c10);
y = a1*sin(b1*x + c1) + a2*sin(b2*x + c2) + a3*sin(b3*x + c3) + a4*sin(b4*x + c4) + a5*sin(b5*x + c5) + a6*sin(b6*x + c6) + a7*sin(b7*x + c7) + a8*sin(b8*x + c8) + a9*sin(b9*x + c9) + a10*sin(b10*x + c10);

% define initial parameter estimates for all 10 sine terms
a1 = 1; b1 = 1; c1 = 0;
a2 = 1; b2 = 2; c2 = 0;
a3 = 1; b3 = 3; c3 = 0;
a4 = 1; b4 = 4; c4 = 0;
a5 = 1; b5 = 5; c5 = 0;
a6 = 1; b6 = 6; c6 = 0;
a7 = 1; b7 = 7; c7 = 0;
a8 = 1; b8 = 8; c8 = 0;
a9 = 1; b9 = 9; c9 = 0;
a10 = 1; b10 = 10; c10 = 0;

% combine all parameter estimates into a vector
params = [a1, b1, c1, a2, b2, c2, a3, b3, c3, a4, b4, c4, a5, b5, c5, a6, b6, c6, a7, b7, c7, a8, b8, c8, a9, b9, c9, a10, b10, c10];

% fit the function to the ERP waveform data
f = fit(t', erp_data', @sine_func, 'StartPoint', params);
