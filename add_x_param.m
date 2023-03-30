function newStr = add_x_param(str)
% This function takes a string and replaces all occurrences of "x" with "b*x".
% str: the input string
% newStr: the new string with all "x" replaced by "b*x"
old = 'x';
new = 'b*x';

newStr = replace(str, old, new);
end
