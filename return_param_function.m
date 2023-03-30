function [func] = return_param_function(x, y)
%Reutn
%   Detailed explanation goes here
func_str = get_fit_str(fitresult);
func = add_params(func_str);
end