function aibits = get_active_streaming_channels(p)

    chans = [];

    if p.chan1_rate ~= 0
        chans(end+1) = 1;
    end

    if p.chan2_rate ~= 0
        chans(end+1) = 2;
    end

    if p.chan3_rate ~= 0
        chans(end+1) = 3;
    end

    if p.chan4_rate ~= 0
        chans(end+1) = 4;
    end

    aibits = 0;

    for bit = chans
        aibits = bitset(aibits, bit);
    end 
end