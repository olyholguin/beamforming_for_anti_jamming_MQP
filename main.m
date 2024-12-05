% %% TODO: switch statement for createSignal vs. collectSignal
% % TODO: finish awgnJammer and barrageJammer
% 
% t = 0:0.001:0.3;            % time, sampling frequency is 1kHz
% carrierFreq = 100e6;        % 100MHz
% colSp = 0.5;
% rowSp = 0.4;
% noisePwr = 0.05;
% doa = [45;0];
% 
% [ura, x, noise] = createSignal(t, carrierFreq, colSp, rowSp, noisePwr, doa);
% 
% fprintf("Given DoA: %d %d \n", doa(1,1), doa(2,1))
% 
% [doas, averageMatrix] = estimateMUSIC(ura, x, noise, carrierFreq, averageMatrix); 
% 
% [signal, weights] = beamformerMVDR(ura, x, noise, doas, t, carrierFreq);

% Rachel URA Simulation
% Goal of this script is to convert Oly's code into separate functions
%% TODO: switch statement for createSignal vs. collectSignal
%% TODO: finish awgnJammer and barrageJammer

t = 0:0.001:0.3;            % time, sampling frequency is 1kHz
carrierFreq = 100e6;        % 100MHz
colSp = 0.5;
rowSp = 0.4;
pulseHeight = 1;
noisePwr = 0.05;
bjammerPwr = .01;
doa = [45;0];
azimuth_range = [-50 50];
elevation_range = [-22.5 22.5];

averageMatrix = zeros(1, 2);

for i = 1:1
[ura, x, noise] = createSignal(t, carrierFreq, colSp, rowSp, noisePwr, doa, i, pulseHeight);

[y] = barrage_Jammer(bjammerPwr); 
%Simulate y (jamming signal) with a direction relative to our recivers
%Then change its location to simulate it moving
% [y2] = barrage_Jammer(bjammerPwr);
% [y3] = barrage_Jammer(bjammerPwr);
% [y4] = barrage_Jammer(bjammerPwr);
% jammed = step(y);
jammed = zeros(301,4);
jammed(:,1) = step(y);
jammed(:,2) = step(y);
jammed(:,3) = step(y);
jammed(:,4) = step(y);

signal_jammed = jammed + x;
figure;
subplot(2,1,1)
histogram(real(signal_jammed))
title('Histogram of Real Part')
subplot(2,1,2)
histogram(imag(signal_jammed))
title('Histogram of Imaginary Part')
xlabel('Watts')
x = signal_jammed;
fprintf("Given DoA: %d %d \n", doa(1,1), doa(2,1))

rs = RandStream.create('mt19937ar', 'Seed', 2007+i);
noise = sqrt(noisePwr/2)*(randn(rs,size(x))+1i*randn(rs,size(x)));

[doas, averageMatrix] = estimateMUSIC(ura, x, noise, carrierFreq, averageMatrix, i, azimuth_range, elevation_range); 
end

[signal, weights] = beamformerMVDR(ura, x, noise, doas, t, carrierFreq);
