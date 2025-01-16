% Beamforming for Anti-Jamming Script

carrierFreq = 100e6;
samplingFreq = 1e3;
t = 0:(1/samplingFreq):0.3; % time, sampling frequency is 1kHz
colSp = 0.5;
rowSp = 0.4;
pulseHeight = 10;
noisePwr = 0.0001;
n = randi([0 99],1,1);
rs = RandStream.create('mt19937ar', 'Seed', 2007 + n);
bjammerPwr = 10;
averageMatrix = zeros(1, 2);
% doa = [0;0];

azimuth_range = [-180 180];
elevation_range = [-22.5 22.5];
azimuth_span = abs(azimuth_range(1) - azimuth_range(2));
elevation_span = abs(elevation_range(1) - elevation_range(2));

% Create Rectangular Pulse
i=1;
[ura, x] = createSignal(t, carrierFreq, colSp, rowSp, i, pulseHeight);

% Initialize Transmitter, Radiator, and Jammer
transmitter = phased.Transmitter('PeakPower',1e4,'Gain',20,...
   'InUseOutputPort',true);
radiator = phased.Radiator('Sensor',ura,'OperatingFrequency',carrierFreq);
jammer = barrageJammer('ERP',bjammerPwr,...
   'SamplesPerFrame',301);
targetchannel = phased.FreeSpace('TwoWayPropagation',true,...
   'SampleRate',samplingFreq,'OperatingFrequency', carrierFreq);
jammerchannel = phased.FreeSpace('TwoWayPropagation',false,...
   'SampleRate',samplingFreq,'OperatingFrequency', carrierFreq);
collector = phased.Collector('Sensor',ura,...
   'OperatingFrequency',carrierFreq);
amplifier = phased.ReceiverPreamp('EnableInputPort',true);

% Original locations of A, B and Jammer
% targetlocB = [100 ; 0; 0];
% targetlocA = [0 ; 0; 0];
% jammerloc = [50; 50; 0];

% Switched locations of B and Jammer for testing
targetlocB = [50 ; -50; 0];
targetlocA = [0 ; 0; 0];
jammerloc = [100; 0; 0];

% Switched locations of B and A for testing
% targetlocB = [0 ; 0; 0];
% targetlocA = [50 ; 50; 0];
% jammerloc = [100; 0; 0];

% Switched locations of B and A for testing
% targetlocB = [30 ; 40; 0];
% targetlocA = [0 ; 0; 0];
% jammerloc = [100; 0; 0];

zeroVelocity = [0;0;0];

[~,pathAtoB] = rangeangle(targetlocB, targetlocA); % Replace tgtang with doa
[~,pathBtoA] = rangeangle(targetlocA, targetlocB);
% [~,jamang] = rangeangle(jammerloc);
[~,pathJtoA] = rangeangle(targetlocA, jammerloc); % Path between jammer and target A
[~,pathJtoB] = rangeangle(targetlocB, jammerloc); % Path between jammer and target B

%% A to B
propagation_path = " A to B";

% Transmit waveform
[x, txstatus] = transmitter(x);
% figure(1);
% plot(abs(x))
% title('Transmitted X')
% %B to A
% [x, txstatus] = transmitter(x);

% Radiate pulse toward the target
x = radiator(x,pathAtoB);

% figure(2);
% plot(abs(x))
% title('Radiated X')

% Propagate pulse toward the target
x = targetchannel(x,targetlocA,targetlocB,zeroVelocity,zeroVelocity);

% figure(3);
% plot(abs(x))
% title('Channeled X')

jamsig = jammer();
% Propagate the jamming signal to the array
jamsig = jammerchannel(jamsig,jammerloc,targetlocB,zeroVelocity,zeroVelocity);
% Collect the jamming signal
jamsig = collector(jamsig,pathJtoB);

% % Debug Plotting
% figure(1);
% plot(t, real(x));
% hold off
% plot(t, imag(x))
% hold on
% title("Output of Radiator")
% legend('Real', 'Imag')
rx_xB = collectPlaneWave(ura, x, pathAtoB, carrierFreq);
% figure(7);
% plot(abs(rx_xB))
% title('Received X after URA collectPlaneWave')
noise = sqrt(noisePwr/2)*(randn(rs,size(rx_xB))+1i*randn(rs,size(rx_xB)));
% figure(8);
% plot(abs(noise))
% xlim([0 300])
% title('Noise')

rx_xB_jamsig = rx_xB + jamsig;
% figure(9);
% plot(abs(rx_xB_jamsig))
% xlim([0 300])
% ylim([0 0.3])
% title('Jammer and Signal')

rx_xB_jamsig_noise = rx_xB_jamsig + noise; % "Realistic" full rx, not used
% figure(10);
% plot(abs(rx_xB_jamsig_noise))
% xlim([0 300])
% ylim([0 0.3])
% title('Jammer and Signal and Noise')

before_MVDR_1noise = snr(rx_xB_jamsig, noise);
% before_MVDR_2noise = snr(rx_xB_jamsig_noise,noise);
disp("Transmiting A to B");
disp("Before MVDR SNR: " + num2str(before_MVDR_1noise) + " dB");
% disp("before_MVDR_2noise: " + num2str(before_MVDR_2noise));

[doas, averageMatrix] = estimateMUSIC(ura, rx_xB_jamsig_noise, noise, carrierFreq, ...
  averageMatrix, i, azimuth_range, elevation_range);

% fprintf("Given DoA: \t%.2f \t%.2f \n", doa(1,1), doa(2,1))
fprintf("Expected DoA: \t%.2f \t%.2f \n", pathAtoB(1,1), pathAtoB(2,1))

doa_NaN = isnan(doas(1,1)) || isnan(doas(2,1));
if(doa_NaN == 1)
  disp("DOAs are NaN");
  return;
end

percent_error_1_1 = abs(doas(1,1) - pathAtoB(1,1)) / azimuth_span * 100;
percent_error_2_1 = abs(doas(2,1) - pathAtoB(2,1)) / elevation_span * 100;
total_percent_error = (percent_error_1_1 + percent_error_2_1) / 2;

% Display the result
disp(['Azimuth Angle Percent Error: ', num2str(percent_error_1_1), '%']);
disp(['Elevation Angle Percent Error: ', num2str(percent_error_2_1), '%']);
disp(['Average Angle Percent Error: ', num2str(total_percent_error), '%']);

switch true
  case (total_percent_error > 1500)
      disp('Percent Error Greater than 15%');
      % Run Things again
      return;
  case (total_percent_error > 1000)
      disp('Percent Error Greater than 10%');
      return;
  case (total_percent_error > 500)
      disp('Percent Error Greater than 5%');
      return;
  otherwise
      % Perform MVDR Beamforming
      disp('Running MVDR Script...');
      % Testing Broken Music
      % doas(1,1) = doas(1,1) - 180;
      [signal, weights] = beamformerMVDR(ura, rx_xB_jamsig_noise, noise, doas, t, carrierFreq, propagation_path);
      after_MVDR_1noise = snr(signal, noise(:,1));
      disp("After MVDR SNR: " + num2str(after_MVDR_1noise) + " dB");
end

%% B to A
propagation_path = " B to A";

% Transmit waveform
[x2, txstatus] = transmitter(signal.*42);

% figure(1);
% plot(abs(signal))
% figure(2);
% plot(abs(signal.*42))

% Radiate pulse toward the target
x2 = radiator(x2,pathBtoA);

% Propagate pulse toward the target
x2 = targetchannel(x2,targetlocB,targetlocA,zeroVelocity,zeroVelocity);

jamsig = jammer();
% Propagate the jamming signal to the array
jamsig = jammerchannel(jamsig,jammerloc,targetlocA,zeroVelocity,zeroVelocity);
% Collect the jamming signal
jamsig = collector(jamsig,pathJtoA);

rx_xA = collectPlaneWave(ura, x2, pathBtoA, carrierFreq);
rx_xA_jamsig = rx_xA + jamsig;
rx_xA_jamsig_noise = rx_xA_jamsig + noise; % "Realistic" full rx, not used

disp(" ")
disp("Transmiting B to A");
before_MVDR_1noise = snr(rx_xA_jamsig, noise);
disp("Before MVDR SNR: " + num2str(before_MVDR_1noise) + " dB");

[doas, averageMatrix] = estimateMUSIC(ura, rx_xA_jamsig_noise, noise, carrierFreq, ...
  averageMatrix, i, azimuth_range, elevation_range);

% fprintf("Given DoA: \t%.2f \t%.2f \n", doa(1,1), doa(2,1))
fprintf("Expected DoA: \t%.2f \t%.2f \n", pathBtoA(1,1), pathBtoA(2,1))

doa_NaN = isnan(doas(1,1)) || isnan(doas(2,1));
if(doa_NaN == 1)
  disp("DOAs are NaN");
  return;
end

% Given DOA angles cancel out, so we reuse pathAtoB instead of pathBtoA
% percent_error_1_1 = abs(doas(1,1) - pathAtoB(1,1)) / azimuth_span * 100;
% percent_error_2_1 = abs(doas(2,1) - pathAtoB(2,1)) / elevation_span * 100;
percent_error_1_1 = abs(doas(1,1) - pathBtoA(1,1)) / azimuth_span * 100;
percent_error_2_1 = abs(doas(2,1) - pathBtoA(2,1)) / elevation_span * 100;
total_percent_error = (percent_error_1_1 + percent_error_2_1) / 2;

% Display the result
disp(['Azimuth Angle Percent Error: ', num2str(percent_error_1_1), '%']);
disp(['Elevation Angle Percent Error: ', num2str(percent_error_2_1), '%']);
disp(['Average Angle Percent Error: ', num2str(total_percent_error), '%']);

switch true
  case (total_percent_error > 1500)
      disp('Percent Error Greater than 15%');
      % Run Things again
      return;
  case (total_percent_error > 1000)
      disp('Percent Error Greater than 10%');
      return;
  case (total_percent_error > 500)
      disp('Percent Error Greater than 5%');
      return;
  otherwise
      % Perform MVDR Beamforming
      disp('Running MVDR Script...');
      % Testing Broken Music
      % doas(1,1) = doas(1,1) + 180;
      [signal, weights] = beamformerMVDR(ura, rx_xA_jamsig_noise, noise, doas, t, carrierFreq, propagation_path);
      after_MVDR_1noise = snr(signal, noise(:,1));
      disp("After MVDR SNR: " + num2str(after_MVDR_1noise) + " dB");
end

