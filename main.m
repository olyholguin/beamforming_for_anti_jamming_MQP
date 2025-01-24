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
b_moves_vert = zeros(780,3);

azimuth_range = [-90 90];
elevation_range = [-22.5 22.5];
azimuth_span = abs(azimuth_range(1) - azimuth_range(2));
elevation_span = abs(elevation_range(1) - elevation_range(2));

targetlocB =    [100; 0; 0];
targetlocA =    [0; 0; 0];
jammerloc =     [60; -50; 0];
zeroVelocity =  [0; 0; 0];

propagation_path = " B to A";

% Create Rectangular Pulse
[ura, x] = createSignal(t, carrierFreq, colSp, rowSp, i, pulseHeight);

% Initialize Phased Objects
[transmitter, radiator, targetchannel, amplifier] = initPhasedObjs(ura, carrierFreq, samplingFreq);

test_angles = [-120 -100 -80 -60 -40 -20 0 20 40 60 80 100 120];
% test_angles = [0 20 40 60 80 100];
% for j_location = test_angles

% Original locations of A, B and Jammer
targetlocB = [100; 0; 0];
targetlocA = [0; 0; 0];
% jammerloc = [50; j_location; 0];
% jammerloc = [j_location; 50; 0];
% jammerloc = [j_location; -50; 0];
jammerloc = [50;50;0];

%Plot senario
plotLoc(targetlocA,targetlocB,jammerloc);

% Calculate Expected DoAs
[pathAtoB, pathBtoA, pathJtoA, pathJtoB] = calculateExpected(targetlocA, targetlocB, jammerloc);

% Transmit signal from B to A
[rx_xA, noise] = propagateSignal(x, pathBtoA, targetlocB, targetlocA, zeroVelocity, carrierFreq, noisePwr, rs, transmitter, radiator, targetchannel, ura);

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

[doas, averageMatrix] = estimateMUSIC(ura, rx_xA_jamsig_noise, noise, carrierFreq, averageMatrix, i, azimuth_range, elevation_range);

fprintf("Expected DoA: \t%.2f \t%.2f \n", pathBtoA(1,1), pathBtoA(2,1))

checkNaN(doas);

[runMVDR] = percentErrors(doas, pathBtoA, azimuth_span, elevation_span);

if (~runMVDR)
   msg = 'DoA Percent Error was too high';
   error(msg)
end

% Perform MVDR Beamforming
disp('Running MVDR Script...');
[signal, weights] = beamformerMVDR(ura, rx_xA_jamsig_noise, noise, doas, t, carrierFreq, propagation_path);
after_MVDR_1noise = snr(signal, noise(:,1));
disp("After MVDR SNR: " + num2str(after_MVDR_1noise) + " dB");

% end