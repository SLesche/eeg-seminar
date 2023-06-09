function [p3_values] = calc_p3_values(erp)
%calculates the P3 Latencies and Amplitudes of a given ERP
%   Detailed explanation goes here

% Check the nbins
nbins = erp.nbin;

% Calculate latency values
[erp_lat values_lat] = pop_geterpvalues( ...
    erp, ...
    [200 900], ...
    1:nbins,  ...
    11, ...
    'Baseline', 'pre', ...
    'Fracreplace', 'NaN', ...
    'InterpFactor',  1, ...
    'Measure', 'peaklatbl', ...
    'Neighborhood',  10, ...
    'PeakOnset',  1, ...
    'Peakpolarity', 'positive', ...
    'Peakreplace', 'absolute', ...
    'Resolution',  3 ...
    );

% Calculate peak values
[erp_lat values_amp] = pop_geterpvalues( ...
    erp, ...
    [200 900], ...
    1:nbins,  ...
    11, ...
    'Baseline', 'pre', ...
    'Fracreplace', 'NaN', ...
    'InterpFactor',  1, ...
    'Measure', 'peakampbl', ...
    'Neighborhood',  10, ...
    'PeakOnset',  1, ...
    'Peakpolarity', 'positive', ...
    'Peakreplace', 'absolute', ...
    'Resolution',  3 ...
    );

% Create array of peak latencies and amplitudes
% Each row is a bin of latency, amplitude
p3_values = [];
p3_values(:, 1) = values_lat;
p3_values(:, 2) = values_amp;

end