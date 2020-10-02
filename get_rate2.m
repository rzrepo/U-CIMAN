function [measrate, ssize] = get_rate2(meastti, astti, meas, as)
    % In this case, assume measurement logged first, then as log, unlikely
    comp_length = length(astti);
    meastti_index = to_index(meastti);
    if meastti_index(end)>comp_length
        cut_idx = find((meastti_index-comp_length)>=0, 1, 'first');
        meastti_index(cut_idx:end) = [];
    end
    comp_as = as(1+meastti_index',:);
    measrate = sum(sum(abs(meas-comp_as)))/length(meastti_index)/size(as,2);
    ssize = length(meastti_index);
end