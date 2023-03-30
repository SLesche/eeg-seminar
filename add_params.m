function [func] = add_params(str)
%UNTITLED This function returns a sin function with stretch and squish
%params added
%   Detailed explanation goes here
replace_b = add_x_param(str);
add_a = add_y_param(replace_b);

% func = @(x, a, b) eval(add_a);
func = add_a;
end