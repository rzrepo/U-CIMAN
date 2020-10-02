function usage_out = get_usage2(ra_indicator, rnti, is_down, usage_input)
    usage_out = usage_input;
    nrb = (size(usage_input, 2)-2)/2;
    if (is_down)
        temp_usage_in = usage_input(2:(nrb+1));
    else
        temp_usage_in = usage_input((nrb+2):(end-1));
    end
    ra_type = ra_indicator(1);
    if ra_type == 2
        rb_start = ra_indicator(2)+1;
        length = ra_indicator(3);
        if rb_start+length-1 > nrb
            disp('Wrong RA type 2 assignment, beyond nrb!! Ignored!!');
            temp_usage_out = temp_usage_in;
        else
            usage = [zeros(1, rb_start-1) ones(1, length).*rnti zeros(1, nrb - (rb_start + length -1))];
            temp_usage_out = (usage==0).*temp_usage_in + usage;
        end
    elseif ra_type == 0
        if (nrb <=10 )
            p = 1;
        elseif (nrb<=26)
            p = 2;
        elseif (nrb<=63)
            p = 3;
        else
            p = 4;
        end
        rbg_bitmask = ra_indicator(2);
        nof_bit = ceil(nrb/p);
        rbg_bitmask = uint32(rbg_bitmask);
        if rbg_bitmask>2^nof_bit-1
            disp('Wrong RA type 0 assignment, bitmask too large!! Ignored!!');
            temp_usage_out = temp_usage_in;
        else
            usage = bitget(rbg_bitmask, nof_bit:-1:1);
            last_bit_repeat_times = nrb - p*(nof_bit-1);
            usage = [repelem(usage(1:end-1), p) repelem(usage(end), last_bit_repeat_times)].*rnti;
            usage = double(usage);
            temp_usage_out = (usage==0).*temp_usage_in + usage;
        end
    elseif ra_type == 1
        if (nrb <=10 )
            p = 1;
        elseif (nrb<=26)
            p = 2;
        elseif (nrb<=63)
            p = 3;
        else
            p = 4;
        end
        nof_bitmask = ceil(nrb/p) - ceil(log2(p)) -1;
        vrb_bitmask = ra_indicator(2);
        vrb_bitmask = uint32(vrb_bitmask);
        if vrb_bitmask>2^nof_bitmask-1
            disp('Wrong RA type 1 assignment, bitmask too large!! Ignored!!');
            temp_usage_out = temp_usage_in;
        else
            rbg_subset = ra_indicator(3);
            shift = ra_indicator(4);
            if shift == 0
                prbs = (1:nof_bitmask)*p - p + 1 + rbg_subset;
            else
                prbs = nrb + 1 - ((1:nof_bitmask)*p - p + 1 + rbg_subset);
            end
            usage = bitget(vrb_bitmask, nof_bitmask:-1:1);
            usage = double(usage);
            current_usage = zeros(size(temp_usage_in));
            current_usage(prbs) = usage;
            current_usage = current_usage.*rnti;
            temp_usage_out = (current_usage==0).*temp_usage_in + current_usage;
        end
    else
        temp_usage_out = temp_usage_in;
    end
    if (is_down)
        usage_out(2:(nrb+1)) = temp_usage_out;
    else
        usage_out((nrb+2):(end-1)) = temp_usage_out;
    end
end