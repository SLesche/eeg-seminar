function modified_func = add_y_param(func)
% This function takes a string that represents a function, adds a variable "a"
% as a parameter that multiplies the output of that function, and returns the
% modified function string.
% func: the string that represents the function
% result: the modified function string with "a*" added to the output

modified_func = strcat('a*(', func, ')');
end

