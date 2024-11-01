%% TODO: switch statement for createSignal vs. collectSignal
% TODO: finish awgnJammer and barrageJammer

t = 0:0.001:0.3;            % time, sampling frequency is 1kHz
carrierFreq = 100e6;        % 100MHz
colSp = 0.5;
rowSp = 0.4;
noisePwr = 0.05;
doa = [45;0];

[ura, x, noise] = createSignal(t, carrierFreq, colSp, rowSp, noisePwr, doa);

fprintf("Given DoA: %d %d \n", doa(1,1), doa(2,1))

[doas, averageMatrix] = estimateMUSIC(ura, x, noise, carrierFreq, averageMatrix); 

[signal, weights] = beamformerMVDR(ura, x, noise, doas, t, carrierFreq);