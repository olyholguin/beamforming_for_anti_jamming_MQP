function signal_power = extractPower(entire_signal, region_start, region_end)
signal_power = mean(abs(entire_signal(region_start:region_end, 1)));
end
