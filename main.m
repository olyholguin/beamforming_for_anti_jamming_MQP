% Beamforming for Anti-Jamming Script
load('mdlSave.mat');
doa_archive = [];
num_features = 3;
model_used = 0;

carrierFreq = 100e6;
samplingFreq = 1e3;
t = 0:(1/samplingFreq):0.3;
colSp = 0.5;
rowSp = 0.4;
pulseHeight = 10;
noisePwr = 0.0001;
n = randi([0 99],1,1);
rs = RandStream.create('mt19937ar', 'Seed', 2007 + n);
show_plots = true;
cardinal_start = 'west';
cardinal_end = 'north';
mobile_jx = true;
cardinal_start_j = 'south';
cardinal_end_j = 'west';

locations = mapping(cardinal_start, cardinal_end, 2);
if mobile_jx
    locations = mapping_jammer(cardinal_start_j, cardinal_end_j, 2, locations);
end

n = length(locations);
sweep = zeros(n,16);

azimuth_range = [-90 90];
elevation_range = [-22.5 22.5];
azimuth_span = abs(azimuth_range(1) - azimuth_range(2));
elevation_span = abs(elevation_range(1) - elevation_range(2));

zeroVelocity =  [0; 0; 0];

propagation_path = " B to A";

% Create Rectangular Pulse
[ura, x] = createSignal(t, carrierFreq, colSp, rowSp, pulseHeight);


% Initialize Phased Objects
[transmitter, radiator, targetchannel, amplifier] = initPhasedObjs(ura, carrierFreq, samplingFreq);

iteration = 1;
weights = ones(4,1) / 4;

% Jammer Power Matrix used for Sweep
jamMatrix = 10;
% jamMatrix = [0.01 0.1 1 10 100 1000];

for loc = 1:height(locations)
    for jam_pwr = jamMatrix

        loc_tx =    [locations(loc, 1); locations(loc, 2); locations(loc, 3)];
        loc_rx =    [locations(loc, 4); locations(loc, 5); locations(loc, 6)];
        loc_jx =    [locations(loc, 7); locations(loc, 8); locations(loc, 9)];

        %Plot senario
        % show_plots = true;
        if (show_plots & loc_rx == [-2;18;0])
            plotLoc(loc_rx,loc_tx,loc_jx);
        end
        % show_plots = false;

        % Calculate Expected DoAs
        [pathAtoB, pathBtoA, pathJtoA, pathJtoB] = calculateExpected(loc_rx, loc_tx, loc_jx);

        % Run propagrateSignal and estimateMusic until DoA percent error is less than 10% or loop had run 10 times
        runMVDR = false;
        music_counter = 0;
        while ~runMVDR
            % Transmit signal from B to A
            disp(" ")
            disp("weight values " + weights);
            w1 = weights(1:2);
            w2 = weights(3:4);
            uraNewW = phased.URA([2,2],'Taper',[w1;w2], 'ElementSpacing', [1.19916 1.49895]);
            [rx, noise] = propagateSignal(x, pathBtoA, loc_tx, loc_rx, zeroVelocity, carrierFreq, noisePwr, rs, transmitter, radiator, targetchannel, uraNewW);

            % Initialize Jammer values
            [jx] = startJammer(jam_pwr, samplingFreq, carrierFreq, ura, loc_jx, loc_rx, zeroVelocity, pathJtoA);

            rx_jx = rx + jx;
            if iteration == 1
                prev_rx_total = rx_jx + noise;
            else
                prev_rx_total = rx_total;
            end 
            
            rx_total = rx_jx + noise;

            % Command Line Output of Locations
            disp(" ")
            disp("Transmitting");
            disp(strcat("Tx location: ",num2str(loc_tx(1,1)),", ",num2str(loc_tx(2,1)),", ",num2str(loc_tx(3,1))))
            disp(strcat("Rx location: ",num2str(loc_rx(1,1)),", ",num2str(loc_rx(2,1)),", ",num2str(loc_rx(3,1))))
            disp(strcat("Jammer location: ",num2str(loc_jx(1,1)),", ",num2str(loc_jx(2,1)),", ",num2str(loc_jx(3,1))))

            % Average Antenna Columns for SNR Calculation
            antennas_combined_signal = (sum((abs(rx_total)),2))./4;

            % Calculate SNR of Signal
            before_sig_pwr = extractPower(antennas_combined_signal, 101, 205);
            before_snr = 20 * log10(extractPower(antennas_combined_signal, 101, 205) / extractPower(antennas_combined_signal,  1, 100));
            disp("SNR Before MVDR: " + num2str(before_snr) + " dB");
            
            music_counter = music_counter+1;

            % string_loc_tx = strcat("Tx location: ",num2str(loc_tx(1,1)),", ",num2str(loc_tx(2,1)),", ",num2str(loc_tx(3,1)));
            % string_loc_rx = strcat(" Rx location: ",num2str(loc_rx(1,1)),", ",num2str(loc_rx(2,1)),", ",num2str(loc_rx(3,1)));
            % string_loc_jx = strcat(" Jammer location: ",num2str(loc_jx(1,1)),", ",num2str(loc_jx(2,1)),", ",num2str(loc_jx(3,1)));
            if (show_plots & loc_rx == [-46;-2;0])
                fig = figure;
                set(fig, 'Color', 'w');
                plot(t, abs(rx_total))
                axis tight;
                % title('Input to MVDR Beamformer');
                % % s = (strcat('Tx Location: ', loc_tx, 'Rx Location: ', loc_rx, 'Jammer Location: ', loc_jx));
                % s = strcat(string_loc_tx, string_loc_rx, string_loc_jx);
                % subtitle(s)
                xlabel('Time (s)','FontSize',16,'Color', 'w');
                ylabel('Magnitude (V)', 'FontSize',16,'Color', 'w');
                ax = gca;
                set(gca,'fontsize', 16,'FontName', 'Times New Roman');
                xlim([0 0.3])
                ylim([0 0.2])
                ax.XColor = 'w';
                ax.YColor = 'w';
                
                grid on
            end

            [doas] = estimateMUSIC(uraNewW, rx_total, carrierFreq, azimuth_range, elevation_range);
            fprintf("Expected DoA: \t%.2f \t%.2f \n", pathBtoA(1,1), pathBtoA(2,1))

             % checkNaN(doas);
             if checkNaN(doas) == false
                [runMVDR, total_percent_error] = percentErrors(doas, pathBtoA, azimuth_span, elevation_span);
             else
                 runMVDR = true;
                 total_percent_error = 100000;
                 music_counter = 3;
             end
             % [runMVDR, total_percent_error] = percentErrors(doas, pathBtoA, azimuth_span, elevation_span);
             
            if (~runMVDR)
                disp("DoA Percent Error was too high running MUSIC again");
            end
            if music_counter == 3
                % error('DoA Percent Error was too high, Stopping program')
                % This is where we put the predict function
                % newData = X(1,:);
                % newData = prevously saved 
                disp('Noisy MUSIC Reading: Calling our ML Model')
                model_used = 1;
                if length(doa_archive) < 3
                    doa_archive = [doas(1,1), doas(1,1), doas(1,1)];
                end
                
                if isnan(doa_archive)
                    doa_archive = [[0;0], [0;0], [0;0]];
                end
                tic;
                predictedDoA = predict(mdl, doa_archive);
                toc;
                disp(['Predicted Azimuth: ', num2str(predictedDoA)]);
                doas = [predictedDoA ; 0];
                runMVDR = true;
            end
            %save doa so that we can access it above
            
        end
        
        if length(doa_archive) >= num_features
            doa_archive = doa_archive(2:end);
        end
        doa_archive = [doa_archive, doas(1,1)];

        % Perform MVDR Beamforming
        disp('Running MVDR Script...');
        % ura_25 = phased.URA([2,2],'Taper',[[.25;.25],[.25;.25]], 'ElementSpacing', [1.19916 1.49895]);
        % [signal, weights] = beamformerMVDR(ura_25, rx_total, noise+jx, doas, t, carrierFreq, propagation_path, show_plots);
        % if iteration == 1
            [signal, weights2] = beamformerMVDR(uraNewW, rx_total, noise+jx, doas, t, carrierFreq, propagation_path, show_plots,loc_rx);
        % else
        %     [signal, weights2] = beamformerMVDR2(uraNewW, rx_total, noise+jx, doas, t, carrierFreq, propagation_path, show_plots, prev_rx_total);
        % end
        % [signal, weights2] = beamformerMVDR(uraNewW, rx_total, noise+jx, doas, t, carrierFreq, propagation_path, show_plots);
        % [signal, weights] = beamformerMVDR(uraNewW, rx_total, noise+jx, pathBtoA, t, carrierFreq, propagation_path, show_plots);

        % Calculate SNR of Signal after MVDR Beamforming
        after_sig_pwr = extractPower(signal, 101, 205);
        after_snr = 20 * log10(extractPower(signal, 101, 205) / extractPower(signal, 1, 100));
        disp("SNR After MVDR: " + num2str(after_snr) + " dB");

        sweep(iteration, 1) = loc_tx(1,1); % X
        sweep(iteration, 2) = loc_tx(2,1); % Y
        sweep(iteration, 3) = loc_tx(3,1); % Z

        sweep(iteration, 4) = loc_rx(1,1);
        sweep(iteration, 5) = loc_rx(2,1);
        sweep(iteration, 6) = loc_rx(3,1);

        sweep(iteration, 7) = loc_jx(1,1);
        sweep(iteration, 8) = loc_jx(2,1);
        sweep(iteration, 9) = loc_jx(3,1);

        sweep(iteration, 13) = before_sig_pwr;     % Signal power before MVDR
        sweep(iteration, 14) = after_sig_pwr;      % Signal power after MVDR
        sweep(iteration, 15) = before_snr;     % SNR before MVDR
        sweep(iteration, 16) = after_snr;     % SNR after MVDR
        sweep(iteration, 17) = total_percent_error;     % Average DOA
        sweep(iteration, 18) = pathBtoA(1,1);   % Expected Azimuth
        sweep(iteration, 19) = pathBtoA(2,1);   % Expected Elevation
        sweep(iteration, 20) = doas(1,1);       % Measured Azimuth
        sweep(iteration, 21) = doas(2,1);       % Measured Elevation
        sweep(iteration, 22) = model_used;

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
        model_used = 0;
    end
end

% Save matrix of data to csv file
sweep = saveData(sweep, cardinal_start, cardinal_end);

fig = figure;
% fig.FontSize = 14; 
scatter(0:1:47, sweep(:,15),[], '*','r')
hold on;
scatter(0:1:47, sweep(:,16),[], 'o', 'b')
legend('Before MVDR','After MVDR', 'FontSize', 14)
% title('SNR Comparison', 'FontSize', 18); % Title
xlabel("Sample", 'FontSize',16,'Color', 'w')
ylabel("SNR (dB)",'FontSize',16,'Color', 'w')
set(fig, 'Color', 'w');
% ax = gca;
% set(gca,'fontsize', 16,'FontName', 'Times New Roman','XTickLabelColor', 'red', 'YTickLabelColor', 'blue');
ax = gca;
ax.FontSize = 16;
ax.FontName = 'Times New Roman';
ax.XColor = 'w';
ax.YColor = 'w';
grid on;


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

