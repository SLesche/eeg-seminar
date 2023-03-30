function [func_str, func] = get_derivative_param(fitresult)
%Turns a string of a function into a string of the derivative of the
%function. Only works 
%   Detailed explanation goes here
str = get_fit_str(fitresult);

syms x
func = str2sym(str);
derivative = diff(func);

func_str = char(derivative);
func = derivative;
end