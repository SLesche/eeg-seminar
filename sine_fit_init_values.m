function init_vals = sine_fit_init_values(num_sines, x, y)

% Compute the Fourier Transform of the data
N = length(y);
NFFT = 2^nextpow2(N);
Y = fft(y, NFFT) / N;
f = linspace(0, 1, ceil((NFFT+1)/2)) / (x(2)-x(1));

% Find the peaks in the Fourier Transform
[~, locs] = findpeaks(abs(Y(1:ceil((NFFT+1)/2))), f, 'SortStr', 'descend', 'NPeaks', num_sines);

% Use the peaks to estimate the initial values for the fit parameters
A = zeros(num_sines, 1);
B = zeros(num_sines, 1);
freq = zeros(num_sines, 1);
for k = 1:num_sines
    freq(k) = 2*pi*f(round(locs(k)));
    A(k) = 2*abs(Y(locs(k))) / N;
    B(k) = angle(Y(locs(k))) - freq(k)*x(1);
end

% Combine the initial values into a single vector
init_vals = [A, freq, B];

end
