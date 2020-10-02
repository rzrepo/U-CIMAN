function syntheticOffOnD01 = get01(syntheticOffOnD, fitLength)
    [~, c] = size(syntheticOffOnD);
    syntheticOffOnD01 = zeros(fitLength, c/2);
    for i = 1:c/2
        off = syntheticOffOnD{2*i-1};
        on = syntheticOffOnD{2*i};
        cycleC = numel(off);
        offOn = [off; on];
        offOn = offOn(:);
        if sum(offOn) < fitLength
            syntheticOffOnD01(:,i) = NaN;
        else
            tmp = zeros(sum(offOn),1);
            idx = 1;
            for j = 1:cycleC
                length = offOn(2*j-1) + offOn(2*j);
                tmp(idx:(idx+length-1)) = repelem([0 1],[offOn(2*j-1) offOn(2*j)]);
                idx = idx + length;
            end
            syntheticOffOnD01(:,i) = tmp(1:fitLength);
        end
    end
end