% Beamforming for Anti-Jamming Script

carrierFreq = 100e6;
samplingFreq = 1e3;
t = 0:(1/samplingFreq):0.3;
colSp = 0.5;
rowSp = 0.4;
pulseHeight = 10;
noisePwr = 0.0001;
n = randi([0 99],1,1);
rs = RandStream.create('mt19937ar', 'Seed', 2007 + n);
bjammerPwr = 10;
averageMatrix = zeros(1, 2);
i = 1;
show_plots = false;
sweep_loc = 'b'; % a, b, j, j_up, j_down
if strcmp(sweep_loc,'b') || strcmp(sweep_loc,'a') || strcmp(sweep_loc,'j')
    sweep = zeros(50,3);
    locations = -120:20:120;
else
   sweep = zeros(360,3);
   locations = 0:20:100;
end
% colors = sweep;
n = length(locations);
big_sweep = zeros(n,16);

azimuth_range = [-90 90];
elevation_range = [-22.5 22.5];
azimuth_span = abs(azimuth_range(1) - azimuth_range(2));
elevation_span = abs(elevation_range(1) - elevation_range(2));

targetlocB =    [100; 0; 0];
targetlocA =    [0; 0; 0];
jammerloc =     [50; 50; 0];
zeroVelocity =  [0; 0; 0];

propagation_path = " B to A";

% Create Rectangular Pulse
[ura, x] = createSignal(t, carrierFreq, colSp, rowSp, i, pulseHeight);

% Initialize Phased Objects
[transmitter, radiator, targetchannel, amplifier] = initPhasedObjs(ura, carrierFreq, samplingFreq);

% jamMatrix = [0.01 0.1 1 10 100 1000];
iteration = 1;
locations = 0;
jamMatrix = 10;
weights = ones(4,1);

for loc = locations
    for jamPwr = jamMatrix
        for i = 1:1:1
            bjammerPwr = jamPwr;

            % Locations of A, B and Jammer
            % targetlocB = [100; 0; 0];
            % targetlocA = [0; 0; 0];
            % jammerloc = [(51-i);(51-i);0];
            if strcmp(sweep_loc, 'b')
                targetlocB = [100; loc; 0];
                title_name = 'Mobile Transmitter';
                y_axis = 'Tx Y Coordinate';
            elseif strcmp(sweep_loc, 'a')
                targetlocA = [0; loc; 0];
                title_name = 'Mobile Receiver';
                y_axis = 'Rx Y Coordinate';
            elseif strcmp(sweep_loc, 'j')
                jammerloc = [50; loc; 0];
                title_name = 'Mobile Jammer';
                y_axis = 'Jammer Y Coordinate';
            elseif strcmp(sweep_loc, 'j_up')
                jammerloc = [loc; 50; 0];
                title_name = 'Mobile Jammer';
                y_axis = 'Jammer X Coordinate';
            else
                jammerloc = [loc; -50; 0];
                title_name = 'Mobile Jammer';
                y_axis = 'Jammer X Coordinate';
            end

            %Plot senario
            if (show_plots)
                plotLoc(targetlocA,targetlocB,jammerloc);
            end

            % Calculate Expected DoAs
            [pathAtoB, pathBtoA, pathJtoA, pathJtoB] = calculateExpected(targetlocA, targetlocB, jammerloc);

            % Transmit signal from B to A
            % disp("weight values " + weights);
            w1 = weights(1:2);
            w2 = weights(3:4);
            uraNewW = phased.URA([2,2],'Taper',[w1,w2], 'ElementSpacing', [1.19916 1.49895]);
            [rx_xA, noise] = propagateSignal(x, pathBtoA, targetlocB, targetlocA, zeroVelocity, carrierFreq, noisePwr, rs, transmitter, radiator, targetchannel, uraNewW);

            % Initialize Jammer values
            [jamsig] = startJammer(bjammerPwr, samplingFreq, carrierFreq, ura, jammerloc, targetlocA, zeroVelocity, pathJtoA);

            rx_xA_jamsig = rx_xA + jamsig;
            rx_xA_jamsig_noise = rx_xA_jamsig + noise;

            % % Command Line Output
            disp(" ")
            disp("Transmitting B to A");
            disp(strcat("B (Tx) location: ",num2str(targetlocB(1,1)),", ",num2str(targetlocB(2,1)),", ",num2str(targetlocB(3,1))))
            disp(strcat("A (Rx) location: ",num2str(targetlocA(1,1)),", ",num2str(targetlocA(2,1)),", ",num2str(targetlocA(3,1))))
            disp(strcat("Jammer location: ",num2str(jammerloc(1,1)),", ",num2str(jammerloc(2,1)),", ",num2str(jammerloc(3,1))))
            % before_MVDR_1noise = snr(rx_xA, noise+jamsig);
            % disp("Before MVDR SNR: " + num2str(before_MVDR_1noise) + " dB");
            
            entire_before_signal = (sum(rx_xA_jamsig_noise,2))./4; % rows combined
            [snr_dB_before_1_100, signal_pwr_before_1_100] = calculateSNR(entire_before_signal, 1, 100);
            disp("Before MVDR SNR fnc (1:100): " + num2str(snr_dB_before_1_100) + " dB");

            [snr_dB_before_101_205, signal_pwr_before_101_205] = calculateSNR(entire_before_signal, 101, 205);
            disp("Before MVDR SNR fnc (101:205): " + num2str(snr_dB_before_101_205) + " dB");

            [snr_dB_before_206_301, signal_pwr_before_206_301] = calculateSNR(entire_before_signal, 206, 301);
            disp("Before MVDR SNR fnc (206:301): " + num2str(snr_dB_before_206_301) + " dB");

            avg_before_snr = (snr_dB_before_1_100 + snr_dB_before_101_205 + snr_dB_before_206_301)/3;
            disp("Average Before SNR: " + num2str(avg_before_snr) + " dB");

            [snr1_1, ~] = calculateSNR(rx_xA_jamsig_noise(:,1), 1, 100);
            disp("SNR Column 1, Region 1: " + num2str(snr1_1) + " dB");
            [snr2_1, ~] = calculateSNR(rx_xA_jamsig_noise(:,2), 1, 100);
            disp("SNR Column 2, Region 1: " + num2str(snr2_1) + " dB");
            [snr3_1, ~] = calculateSNR(rx_xA_jamsig_noise(:,3), 1, 100);
            disp("SNR Column 3, Region 1: " + num2str(snr3_1) + " dB");
            [snr4_1, ~] = calculateSNR(rx_xA_jamsig_noise(:,4), 1, 100);
            disp("SNR Column 4, Region 1: " + num2str(snr4_1) + " dB");
            snr1_1_linear = 10.^(snr1_1 / 10);
            snr2_1_linear = 10.^(snr2_1 / 10);
            snr3_1_linear = 10.^(snr3_1 / 10);
            snr4_1_linear = 10.^(snr4_1 / 10);

            avg_region1_linear = (snr1_1_linear+snr2_1_linear+snr3_1_linear+snr4_1_linear)/4;
            avg_region1_fixed = 10 * log10(avg_region1_linear);
            disp("Average Region 1 Fixed: " + num2str(avg_region1_fixed) + " dB");

            [snr1_2, ~] = calculateSNR(rx_xA_jamsig_noise(:,1), 101, 205);
            disp("SNR Column 1, Region 2: " + num2str(snr1_2) + " dB");
            [snr2_2, ~] = calculateSNR(rx_xA_jamsig_noise(:,2), 101, 205);
            disp("SNR Column 2, Region 2: " + num2str(snr2_2) + " dB");
            [snr3_2, ~] = calculateSNR(rx_xA_jamsig_noise(:,3), 101, 205);
            disp("SNR Column 3, Region 2: " + num2str(snr3_2) + " dB");
            [snr4_2, ~] = calculateSNR(rx_xA_jamsig_noise(:,4), 101, 205);
            disp("SNR Column 4, Region 2: " + num2str(snr4_2) + " dB");
            snr1_2_linear = 10.^(snr1_2 / 10);
            snr2_2_linear = 10.^(snr2_2 / 10);
            snr3_2_linear = 10.^(snr3_2 / 10);
            snr4_2_linear = 10.^(snr4_2 / 10);

            avg_region2_linear = (snr1_2_linear+snr2_2_linear+snr3_2_linear+snr4_2_linear)/4;
            avg_region2_fixed = 10 * log10(avg_region2_linear);
            disp("Average Region 2 Fixed: " + num2str(avg_region2_fixed) + " dB");

            [snr1_3, ~] = calculateSNR(rx_xA_jamsig_noise(:,1), 206, 301);
            disp("SNR Column 1, Region 3: " + num2str(snr1_3) + " dB");
            [snr2_3, ~] = calculateSNR(rx_xA_jamsig_noise(:,2), 206, 301);
            disp("SNR Column 2, Region 3: " + num2str(snr2_3) + " dB");
            [snr3_3, ~] = calculateSNR(rx_xA_jamsig_noise(:,3), 206, 301);
            disp("SNR Column 3, Region 3: " + num2str(snr3_3) + " dB");
            [snr4_3, ~] = calculateSNR(rx_xA_jamsig_noise(:,4), 206, 301);
            disp("SNR Column 4, Region 3: " + num2str(snr4_3) + " dB");
            snr1_3_linear = 10.^(snr1_3 / 10);
            snr2_3_linear = 10.^(snr2_3 / 10);
            snr3_3_linear = 10.^(snr3_3 / 10);
            snr4_3_linear = 10.^(snr4_3 / 10);

            avg_region3_linear = (snr1_3_linear+snr2_3_linear+snr3_3_linear+snr4_3_linear)/4;
            avg_region3_fixed = 10 * log10(avg_region3_linear);
            disp("Average Region 3 Fixed: " + num2str(avg_region3_fixed) + " dB");

            % avg_region1 = (snr1_1+snr2_1+snr3_1+snr4_1)/4;
            % disp("Average Region 1: " + num2str(avg_region1) + " dB");
            % avg_region2 = (snr1_2+snr2_2+snr3_2+snr4_2)/4;
            % disp("Average Region 2: " + num2str(avg_region2) + " dB");
            % avg_region3 = (snr1_3+snr2_3+snr3_3+snr4_3)/4;
            % disp("Average Region 3: " + num2str(avg_region3) + " dB");
            % 
            % overall_avg = (avg_region1 + avg_region2 + avg_region3)/3;
            % disp("Average All: " + num2str(overall_avg) + " dB");

            % Old way
            rows_combined = (sum(rx_xA_jamsig_noise,2))./4;
            signal_power0 = rms(rows_combined).^2;
            noise_region0 = rx_xA_jamsig_noise(1:100);
            noise_power0 = var(noise_region0);
            snr_value_db0 = 10 * log10(signal_power0 / noise_power0);
            disp("Before MVDR SNR old: " + num2str(snr_value_db0) + " dB");
            
            [doas, averageMatrix] = estimateMUSIC(uraNewW, rx_xA_jamsig_noise, noise, carrierFreq, averageMatrix, i, azimuth_range, elevation_range);

            fprintf("Expected DoA: \t%.2f \t%.2f \n", pathBtoA(1,1), pathBtoA(2,1))

            checkNaN(doas);

            [runMVDR, total_percent_error] = percentErrors(doas, pathBtoA, azimuth_span, elevation_span);

            if (~runMVDR)
                msg = 'DoA Percent Error was too high';
                error(msg)
            end

            % Perform MVDR Beamforming
            disp('Running MVDR Script...');
            [signal, weights2] = beamformerMVDR(uraNewW, rx_xA_jamsig_noise, noise+jamsig, doas, t, carrierFreq, propagation_path, show_plots);

            % Power Calculation
            % signal_power = rms(signal)^2;
            % noise_region = signal(1:100); % Example: use a section where the signal is expected to be minimal
            % noise_power = var(noise_region);  % Variance of noise
            % snr_value_db = 10 * log10(signal_power / noise_power);
            [snr_dB_1_100, signal_pwr_1_100] = calculateSNR(signal, 1, 100);
            disp("After MVDR SNR (1:100)  : " + num2str(snr_dB_1_100) + " dB");

            % noise_region2 = signal(101:205);
            % noise_power2 = var(noise_region2);
            % snr_value_db2 = 10 * log10(signal_power / noise_power2);
            [snr_dB_101_205, signal_pwr_101_205] = calculateSNR(signal, 101, 205);
            disp("After MVDR SNR (101:205): " + num2str(snr_dB_101_205) + " dB");

            % noise_region3 = signal(206:301);
            % noise_power3 = var(noise_region3);
            % snr_value_db3 = 10 * log10(signal_power / noise_power3);
            [snr_dB_206_301, signal_pwr_206_301] = calculateSNR(signal, 206, 301);
            disp("After MVDR SNR (206:301): " + num2str(snr_dB_206_301) + " dB");

            avg_after_snr = (snr_dB_1_100 + snr_dB_101_205 + snr_dB_206_301)/3;
            disp("Average After SNR: " + num2str(avg_after_snr) + " dB");

            % sweep(iteration,1) = loc;
            % sweep(iteration,2) = bjammerPwr;
            % sweep(iteration,3) = total_percent_error;
            % sweep(iteration, 1) = (51-i);
            % sweep(iteration,2) = before_MVDR_1noise;
            % sweep(iteration,3) = after_MVDR_1noise;

            big_sweep(iteration, 1) = targetlocB(1,1); % X
            big_sweep(iteration, 2) = targetlocB(2,1); % Y
            big_sweep(iteration, 3) = targetlocB(3,1); % Z

            big_sweep(iteration, 4) = targetlocA(1,1);
            big_sweep(iteration, 5) = targetlocA(2,1);
            big_sweep(iteration, 6) = targetlocA(3,1);
            
            big_sweep(iteration, 7) = jammerloc(1,1);
            big_sweep(iteration, 8) = jammerloc(2,1);
            big_sweep(iteration, 9) = jammerloc(3,1);

            big_sweep(iteration, 13) = signal_pwr_before_1_100;   % Signal power before MVDR
            big_sweep(iteration, 14) = signal_pwr_1_100;    % Signal power after MVDR
            big_sweep(iteration, 15) = snr_dB_before_1_100;       % SNR before MVDR
            big_sweep(iteration, 16) = avg_after_snr;       % SNR after MVDR

            % big_sweep(iteration, 13) = signal_power0;     % Signal power before MVDR
            % big_sweep(iteration, 14) = signal_power;      % Signal power after MVDR
            % big_sweep(iteration, 15) = snr_value_db0;     % SNR before MVDR
            % big_sweep(iteration, 16) = avg_after_snr;     % SNR after MVDR

            % if bjammerPwr == 0.01
            %     colors(iteration,:) = [0.039 0.58 0.039];
            % elseif bjammerPwr == 0.1
            %     colors(iteration,:) = [0.098 0.949 0.098];
            % elseif bjammerPwr == 1
            %     colors(iteration,:) = [0.929 0.969 0.129];
            % elseif bjammerPwr == 10
            %     colors(iteration,:) = [1 0.651 0];
            % elseif bjammerPwr == 100
            %     colors(iteration,:) = [1 0 0];
            % else
            %     colors(iteration,:) = [0.6 0.051 0];
            % end
            iteration = iteration + 1;
            % Donut
            % figure;
            % pattern(uraNewW,carrierFreq,'CoordinateSystem','polar','Type','powerdb'); 
            % view(50,20);
            % ax = gca;
            % ax.Position = [-0.15 0.1 0.9 0.8];
            % camva(4.5); 
            % campos([520 -250 200]);
        end
    end
end

% Save matrix of data to csv file 
 saveData(big_sweep, n);

% figure;
% scatter(sweep(:,1), sweep(:,2),[], '*','b')
% hold on;
% scatter(sweep(:,1), sweep(:,3),[], 'o', 'r')
% legend('Before','After')
% xlabel("X and Y Coordinate of Jammer (Meters)")
% ylabel("SNR in dB")
% scatter(sweep(:,3), sweep(:,1), [], colors, 'filled')
% hold off;
% scatter(sweep(:,1), sweep(:,2),[], '*','b')
% hold on;
% scatter(sweep(:,1), sweep(:,3),[], 'o', 'r')
% set(gca,'xscale','log')
% xlabel('Percent Error')
% subtitle(strcat('Average Percent Error:', {' '}, num2str(mean(sweep(:,3)))))
% ylabel(y_axis)
% title(title_name)
% legend('Jammer Power 0.01', 'Jammer Power 0.1', 'Jammer Power 1', ...
%        'Jammer Power 10', 'Jammer Power 100', 'Jammer Power 1000')
% ylim([min(sweep(:,1))-10 max(sweep(:,1))+10])
% yticks(locations)

