function syntheticOffOnAR = getOffOn(syntheticAR)
% convert 1 0 in each column to off on time lengths
    [r ,c] = size(syntheticAR);
    syntheticOffOnAR = cell(1, 2*c);
    for i = 1:c
        tmp = syntheticAR(:,i);
        rb_usage_p2 = zeros(1, r);
        rb_usage_p2(2:end) = tmp(2:end) - tmp(1:(end-1));

        nof_intervals = sum(rb_usage_p2==-1)-1;
        if nof_intervals>0            
            firstm1_idx = find(rb_usage_p2==-1,1,'first');
            lastm1_idx = find(rb_usage_p2==-1,1,'last');
            rb_usage_p2(lastm1_idx:end) = [];
            rb_usage_p2(1:(firstm1_idx-1)) = [];
            m1positions = find(rb_usage_p2==-1);
            interval_lengths = [m1positions(2:end)-m1positions(1:(end-1)) length(rb_usage_p2)-m1positions(end)+1];
            p1positions = find(rb_usage_p2==1);
            off_time = p1positions - m1positions;
            on_time = interval_lengths - off_time;
            syntheticOffOnAR{2*i-1} = off_time;
            syntheticOffOnAR{2*i} = on_time;            
        end
    end
end