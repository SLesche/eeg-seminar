function [params_str fitresult, gof] = return_grand_average_params(x, y, n_sin)
%Returns a function fitting the grand average datapoints

% if n_sin is not specified
if nargin < 3
    n_sin = 9;
end

% Prepare data for curve fitting
[xData, yData] = prepareCurveData(x, y);

% Prepare curve fit
lower_bounds = [-Inf 0 -Inf];
ft = fittype( strcat('sin', num2str(n_sin)) );
excludedPoints = (xData < -200) | (xData > 1000);
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.Lower = repmat(lower_bounds, 1, n_sin);
opts.Exclude = excludedPoints;
opts.MaxIter = 10000;
opts.MaxFunEvals = 2000;

[fitresult, gof] = fit( xData, yData, ft, opts );

params_str = add_params(get_fit_str(fitresult));
end