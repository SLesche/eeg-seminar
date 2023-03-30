function [subj_p3] = return_modified_p3(fitresult, ga_lat, ga_amp)
% Takes 
%   Detailed explanation goes here
values = coeffvalues(fitresult);
a = values(1);
b = values(2);

lat = ga_lat / b,
amp = ga_amp * a;

subj_p3 = [];
subj_p3(:, 1) = lat;
subj_p3(:, 2) = amp;
end
