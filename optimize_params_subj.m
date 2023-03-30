function [fitresult, gof] = optimize_params_subj(x, y, func)
%Finds optimal params a, b for a subject
%   Detailed explanation goes here

ft_optimize = fittype(func, 'independent', 'x', 'dependent', 'y');
opts_opt = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts_opt.Lower = [0 0];
opts_opt.MaxIter = 10000;
opts_opt.MaxFunEvals = 2000;
opts_opt.StartPoint = [1 1];

[xData, yData] = prepareCurveData(x, y);

[fitresult, gof] = fit( xData, yData, ft_optimize, opts_opt);

end