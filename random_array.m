function arr = random_array(n)
    size = n * 3;
    arr = zeros(1, size)
    for i = 1:size
       if mod(i, 3) == 1
           arr(i) = rand(1)*10
       elseif mod(i, 3) == 2
           arr(i) = rand(1)
       else
           arr(i) = rand(1)*0.1
       end
    end
end