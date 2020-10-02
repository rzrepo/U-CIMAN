function synthed = synth(offOnModel, fitLength, fitChannel)
% trim the result to be of the same size with the original data
    synthed = cell(1, 2*fitChannel);
    for i = 1:fitChannel
        tmpL = 0;
        synthed{2*i-1} = [];
        synthed{2*i} = [];
        while tmpL < fitLength
            tmpL = 0;
            synthed{2*i-1} = [synthed{2*i-1} ceil(offOnModel{1}.random(1,1))];
            synthed{2*i} = [synthed{2*i} ceil(offOnModel{2}.random(1,1))];
            tmpL = tmpL + sum(synthed{2*i-1}) + sum(synthed{2*i});
        end
    end
end
