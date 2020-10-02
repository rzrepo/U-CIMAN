function er = processRate(errorRate, mer, offsetCount)
    er = errorRate;
    er1 = er(1,:);
    max1 = max(er1);
    if mer < max1
        index = find(er1==max1, 1, 'first');
        er(1, index) = mer;
        er(2, index) = offsetCount;
    end
end