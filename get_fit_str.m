function fit_str = get_fit_str(coeffs)
    n = length(coeffs)/3;
    fit_str = "";
    for i = 1:n
        a = coeffs(3*i - 2);
        b = coeffs(3*i - 1);
        c = coeffs(3*i);
        term_str = strcat(num2str(a), '*sin(', num2str(b), '*x +', num2str(c), ')');
        if i == 1
            fit_str = term_str;
        else
            fit_str = fit_str + " + " + term_str;
        end
    end
end