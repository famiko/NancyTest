arr = ones(1,5);
for i = 1:5
    arr(i) = native2unicode([176 + randi(39) 161 + randi(93)]);
end
arr