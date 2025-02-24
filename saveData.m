function [] = saveData(sweep, cardinal_start, cardinal_end)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
% targetlocB - pass in sweep of targetlocB which would be n x 3 matrix
% targetlocA - pass in sweep of targetlocA which would be n x 3 matrix
% jammerloc - pass in sweep of targetlocA which would be n x 3 matrix
% tx_rx_dist - calcualte per row in this func
% j_rx_dist - 
% j_tx_dist - 
% signal_pow_b4 - passed in
% signal_pow_after -  passed in 
% snr_b4,snr_after - passed in 

labels = ["Tx Location x", "Tx Location y", "Tx Location z", "Rx Location x", "Rx Location y", "Rx Location z", "Jammer Location x", "Jammer Location y", "Jammer Location z (m)", "Tx - Rx Distance (m)", "J - Rx Distance (m)", "J - Tx Distance (m)", "Signal Power Before (V)", "Signal Power After (V)", "SNR Before (dB)", "SNR After (dB)"];
sweep(:,10) = sqrt((sweep(:,4) - sweep(:,1)).^2+(sweep(:,5) - sweep(:,2)).^2+ (sweep(:,6)-sweep(:,3)).^2);
sweep(:,11) = sqrt((sweep(:,7) - sweep(:,4)).^2+(sweep(:,8) - sweep(:,5)).^2+ (sweep(:,9)-sweep(:,6)).^2);
sweep(:,12) = sqrt((sweep(:,7) - sweep(:,1)).^2+(sweep(:,8) - sweep(:,2)).^2+ (sweep(:,9)-sweep(:,3)).^2);

date_curr = datestr(datetime('now', 'TimeZone', 'local', 'Format', 'd_MMM_y HH:mm:ss'));
date_curr = replace(date_curr,"-", "_");
date_curr = replace(date_curr," ", "_");
date_curr = replace(date_curr,":", "_");
filename = strcat('sim_data_', cardinal_start(1), '2', cardinal_end(1), '_', date_curr, '.csv');

writematrix(sweep, filename);
T = readtable(filename, 'TextType','string');
T = renamevars(T, 1:width(T),labels);
writetable(T, filename);


end