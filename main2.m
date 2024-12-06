% Beamforming for Anti-Jamming Script

% time, sampling frequency is 1kHz

carrierFreq = 100e6;
samplingFreq = 1e3;
t = 0:(1/samplingFreq):0.3;
colSp = 0.5;
rowSp = 0.4;
pulseHeight = 10;
noisePwr = 0.01;
n = randi([0 99],1,1);
rs = RandStream.create('mt19937ar', 'Seed', 2007 + n);
bjammerPwr = 0.01;
averageMatrix = zeros(1, 2);

doa = [0;0];
azimuth_range = [-50 50];
elevation_range = [-22.5 22.5];
azimuth_span = abs(azimuth_range(1) - azimuth_range(2));
elevation_span = abs(elevation_range(1) - elevation_range(2));

% Create Rectangular Pulse
i=1;
[ura, x, noise] = createSignal(t, carrierFreq, colSp, rowSp, noisePwr, doa, i, pulseHeight);

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
targetlocB = [100 ; 0; 0];
targetlocA = [0 ; 0; 0];
jammerloc = [50; 50; 0];
[~,tgtang] = rangeangle(targetlocB);
[~,jamang] = rangeangle(jammerloc);

% Transmit waveform
[x, txstatus] = transmitter(x);

% Radiate pulse toward the target
x = radiator(x,doa);

% Propagate pulse toward the target
x = targetchannel(x,[0;0;0],targetlocB,[0;0;0],[0;0;0]);

jamsig = jammer();

% Propagate the jamming signal to the array
jamsig = jammerchannel(jamsig,jammerloc,[0;0;0],[0;0;0],[0;0;0]);

% Collect the jamming signal
jamsig = collector(jamsig,jamang);

% % Debug Plotting
% figure(1);
% plot(t, real(x));
% hold off
% plot(t, imag(x))
% hold on
% title("Output of Radiator")
% legend('Real', 'Imag')

rx_xB = collectPlaneWave(ura, x, doa, carrierFreq);
noise = sqrt(noisePwr/2)*(randn(rs,size(rx_xB))+1i*randn(rs,size(rx_xB)));
rx_xB_jamsig = rx_xB + jamsig;
rx_xB_jamsig_noise = rx_xB_jamsig + noise; % "Realistic" full rx, not used
before_MVDR_1noise = snr(rx_xB_jamsig, noise);
% before_MVDR_2noise = snr(rx_xB_jamsig_noise,noise);
disp("Before MVDR SNR: " + num2str(before_MVDR_1noise) + " dB");
% disp("before_MVDR_2noise: " + num2str(before_MVDR_2noise));
[doas, averageMatrix] = estimateMUSIC(ura, rx_xB_jamsig, noise, carrierFreq, ...
   averageMatrix, i, azimuth_range, elevation_range);
fprintf("Given DoA: \t%.2f \t%.2f \n", doa(1,1), doa(2,1))
doa_NaN = isnan(doas(1,1)) || isnan(doas(2,1));
if(doa_NaN == 1)
   disp("DOAs are NaN");
   return;
end
percent_error_1_1 = abs(doas(1,1) - doa(1,1)) / azimuth_span * 100;
percent_error_2_1 = abs(doas(2,1) - doa(2,1)) / elevation_span * 100;
total_percent_error = (percent_error_1_1 + percent_error_2_1) / 2;
% Display the result
disp(['Azimuth Angle Percent Error: ', num2str(percent_error_1_1), '%']);
disp(['Elevation Angle Percent Error: ', num2str(percent_error_2_1), '%']);
disp(['Average Angle Percent Error: ', num2str(total_percent_error), '%']);
switch true
   case (total_percent_error > 15)
       disp('Percent Error Greater than 15%');
       % Run Things again
       return;
   case (total_percent_error > 10)
       disp('Percent Error Greater than 10%');
       return;
   case (total_percent_error > 5)
       disp('Percent Error Greater than 5%');
       return;
   otherwise
       % Perform MVDR Beamforming
       disp('Running MVDR Script...');
       [signal, weights] = beamformerMVDR(ura, rx_xB_jamsig, noise, doas, t, carrierFreq);
       after_MVDR_1noise = snr(signal, noise(:,1));
       disp("After MVDR SNR: " + num2str(after_MVDR_1noise) + " dB");
end

