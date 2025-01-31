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
sweep_loc = 'j'; % a, b, j, j_up, j_down
if strcmp(sweep_loc,'b') || strcmp(sweep_loc,'a') || strcmp(sweep_loc,'j')
    sweep = zeros(60,3);
    locations = -120:20:120;
else
   sweep = zeros(360,3);
   locations = 0:20:100;
end
colors = sweep;

azimuth_range = [-90 90];
elevation_range = [-22.5 22.5];
azimuth_span = abs(azimuth_range(1) - azimuth_range(2));
elevation_span = abs(elevation_range(1) - elevation_range(2));

targetlocB =    [100; 0; 0];
targetlocA =    [0; 0; 0];
jammerloc =     [50; -50; 0];
zeroVelocity =  [0; 0; 0];

propagation_path = " B to A";

% Create Rectangular Pulse
[ura, x] = createSignal(t, carrierFreq, colSp, rowSp, i, pulseHeight);

% Initialize Phased Objects
[transmitter, radiator, targetchannel, amplifier] = initPhasedObjs(ura, carrierFreq, samplingFreq);

jamMatrix = [0.01 0.1 1 10 100 1000];
iteration = 1;
locations = 50;
jamMatrix = 10;
weights = ones(4,1);

for loc = locations
    for jamPwr = jamMatrix
        for i = 1:1:2
            bjammerPwr = jamPwr;

            % Locations of A, B and Jammer
            targetlocB = [100; 0; 0];
            targetlocA = [0; 0; 0];
            jammerloc = [50;50;0];
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
            disp("weight values " + weights);
            w1 = weights(1:2);
            w2 = weights(3:4);
            uraNewW = phased.URA([2,2],'Taper',[w1,w2], 'ElementSpacing', [1.19916 1.49895]);
            [rx_xA, noise] = propagateSignal(x, pathBtoA, targetlocB, targetlocA, zeroVelocity, carrierFreq, noisePwr, rs, transmitter, radiator, targetchannel, uraNewW);

            % Initialize Jammer values
            [jamsig] = startJammer(bjammerPwr, samplingFreq, carrierFreq, ura, jammerloc, targetlocA, zeroVelocity, pathJtoA);

            rx_xA_jamsig = rx_xA + jamsig;
            rx_xA_jamsig_noise = rx_xA_jamsig + noise;

            % Command Line Output
            disp(" ")
            disp("Transmitting B to A");
            disp(strcat("B (Tx) location: ",num2str(targetlocB(1,1)),", ",num2str(targetlocB(2,1)),", ",num2str(targetlocB(3,1))))
            disp(strcat("A (Rx) location: ",num2str(targetlocA(1,1)),", ",num2str(targetlocA(2,1)),", ",num2str(targetlocA(3,1))))
            disp(strcat("Jammer location: ",num2str(jammerloc(1,1)),", ",num2str(jammerloc(2,1)),", ",num2str(jammerloc(3,1))))
            before_MVDR_1noise = snr(rx_xA_jamsig, noise);
            disp("Before MVDR SNR: " + num2str(before_MVDR_1noise) + " dB");

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
            [signal, weights] = beamformerMVDR(uraNewW, rx_xA_jamsig_noise, noise, doas, t, carrierFreq, propagation_path, show_plots);
            after_MVDR_1noise = snr(signal, noise(:,1));
            disp("After MVDR SNR: " + num2str(after_MVDR_1noise) + " dB");

            sweep(iteration,1) = loc;
            sweep(iteration,2) = bjammerPwr;
            sweep(iteration,3) = total_percent_error;
            % sweep(iteration,3) = after_MVDR_1noise;

            if bjammerPwr == 0.01
                colors(iteration,:) = [0.039 0.58 0.039];
            elseif bjammerPwr == 0.1
                colors(iteration,:) = [0.098 0.949 0.098];
            elseif bjammerPwr == 1
                colors(iteration,:) = [0.929 0.969 0.129];
            elseif bjammerPwr == 10
                colors(iteration,:) = [1 0.651 0];
            elseif bjammerPwr == 100
                colors(iteration,:) = [1 0 0];
            else
                colors(iteration,:) = [0.6 0.051 0];
            end
            iteration = iteration + 1;
            figure;
            pattern(uraNewW,carrierFreq,'CoordinateSystem','polar','Type','powerdb'); 
            view(50,20);
            ax = gca;
            ax.Position = [-0.15 0.1 0.9 0.8];
            camva(4.5); 
            campos([520 -250 200]);
        end
    end
end

% load desiredSynthesizedAntenna;

% clf;


% figure;
% scatter(sweep(:,3), sweep(:,1), [], colors, 'filled')
% % set(gca,'xscale','log')
% xlabel('Percent Error')
% subtitle(strcat('Average Percent Error:', {' '}, num2str(mean(sweep(:,3)))))
% ylabel(y_axis)
% title(title_name)
% % legend('Jammer Power 0.01', 'Jammer Power 0.1', 'Jammer Power 1', ...
% %        'Jammer Power 10', 'Jammer Power 100', 'Jammer Power 1000')
% ylim([min(sweep(:,1))-10 max(sweep(:,1))+10])
% yticks(locations)
