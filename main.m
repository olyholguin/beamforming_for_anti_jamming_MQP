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
noisePwr = 0.05;
doa = [45;0];

averageMatrix = zeros(1, 2);

for i = 1:1
[ura, x, noise] = createSignal(t, carrierFreq, colSp, rowSp, noisePwr, doa,i);

fprintf("Given DoA: %d %d \n", doa(1,1), doa(2,1))

[doas, averageMatrix] = estimateMUSIC(ura, x, noise, carrierFreq, averageMatrix, i); 
end

[signal, weights] = beamformerMVDR(ura, x, noise, doas, t, carrierFreq);
