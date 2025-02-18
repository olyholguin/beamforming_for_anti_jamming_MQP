function [snr_dB_before, signal_power] = calculateSNR(entire_signal, region_start, region_end)

signal_power = rms(entire_signal).^2;
noise_region = entire_signal(region_start:region_end, 1);            
noise_power = var(noise_region);
snr_dB_before = 10 * log10(signal_power / noise_power);

end

% % Old way
%             rows_combined = (sum(rx_xA_jamsig_noise,2))./4;
%             signal_power0 = rms(rows_combined).^2;
%             noise_region0 = rx_xA_jamsig_noise(1:100);
%             noise_power0 = var(noise_region0);
%             snr_value_db0 = 10 * log10(signal_power0 / noise_power0);
%             disp("Before MVDR SNR old: " + num2str(snr_value_db0) + " dB");