冯可翊  Coye's homework 1 in thisone

only change the part of swap
the results are about 100 

annealing4 is the previous version

function stateCandidate = GenerateStateCandidate(state)
    nCities = numel(state);
    i = randi(nCities);
    j = randi(nCities);
    while i == j
        j = randi(nCities);
    end
    
    if i > j
        temp = i;
        i = j;
        j = temp;
    end
    
    stateCandidate = state;
    stateCandidate(i:j) = flip(state(i:j));
end
