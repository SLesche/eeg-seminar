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

%% Fit: 'test_fit'.
[xData, yData] = prepareCurveData( ga_times, ga_value_1 );

% Set up fittype and options.
n_sin = 9;
lower_bounds = [-Inf 0 -Inf];


ft = fittype( strcat('sin', num2str(n_sin)) );
excludedPoints = (xData < -200) | (xData > 1000);
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.Lower = repmat(lower_bounds, 1, n_sin);
opts.Exclude = excludedPoints;
opts.MaxIter = 10000;
opts.MaxFunEvals = 2000;


% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, opts );

fit_names = coeffnames(fitresult);
fit_values = coeffvalues(fitresult);

% Get new function with elongate and stretch param
% put a scalar in front of every b parameter and a scalar infront of the
% whole function

plot(fitresult, xData, yData)

func = get_fit_func(fitresult)

f = inline(func_str, 'x')

new_x = round(linspace(-200, 1000, 300))
new_y = f(new_x)

plot(new_x, new_y)