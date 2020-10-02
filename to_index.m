function meastti_index = to_index(meastti)
    sm = length(meastti);
    diff = mod(meastti(2:end)-meastti(1:end-1), 10240);
    diff = [0; diff];
    meastti_index = tril(ones(sm))*diff;
end