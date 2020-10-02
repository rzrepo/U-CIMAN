function [measrate, ssize] = get_rate(meastti, astti, meas, as)
    % In this case, assume measurement logged first, then as log, unlikely
    first_meas_tti = meastti(1);
    as_startm_index = find(astti==first_meas_tti, 1, 'first');
    if ~isempty(as_startm_index)
        as_left_length = length(astti) - as_startm_index;
        meastti_index = to_index(meastti);
        if meastti_index(end)>as_left_length
            cut_idx = find((meastti_index-as_left_length)>=0, 1, 'first');
            meastti_index(cut_idx:end) = [];
        end
        meas_size0 = length(meastti_index);
        comp_meas = meas(1:meas_size0,:);
        comp_as = as(as_startm_index+meastti_index',:);
        measrate0 = sum(sum(abs(comp_meas-comp_as)))/meas_size0/size(as,2);
    else
        measrate0 = 1;
        meas_size0 = length(meastti);
    end
    
    % In this case, assume as logged first, then measured, more unlikely
    first_as_tti = astti(1);
    meas_startas_index = find(meastti==first_as_tti, 1, 'first');
    if ~isempty(meas_startas_index)
        meastti(1:(meas_startas_index-1)) = [];
        meas(1:(meas_startas_index-1),:) = [];
        as_left_length = length(astti);
        meastti_index = to_index(meastti);
        if meastti_index(end)>as_left_length
            cut_idx = find((meastti_index-as_left_length)>=0, 1, 'first');
            meastti_index(cut_idx:end) = [];
        end
        meas_size1 = length(meastti_index);
        comp_meas = meas(1:meas_size1,:);
        comp_as = as(1+meastti_index',:);
        measrate1 = sum(sum(abs(comp_meas-comp_as)))/meas_size1/size(as,2);
    else
        measrate1 = 1;
        meas_size1 = length(meastti);
    end
    if measrate0 < measrate1
        measrate = measrate0;
        ssize = meas_size0;
    else
        measrate = measrate1;
        ssize = meas_size1;        
    end
end