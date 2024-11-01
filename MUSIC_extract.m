%MATLAB Script for MUSIC Algorithm

%Rectangular Pulse
t = 0:0.001:0.3;                % Time, sampling frequency is 1kHz
s = zeros(size(t));  
s = s(:);                       % Signal in column vector
s(201:205) = s(201:205) + 1;    % Define the pulse
% figure(1);                      % Received signal is a rectangular pulse
% plot(t,s)
% title('Pulse')
% xlabel('Time (s)')
% ylabel('Amplitude (V)')         % Plots the signal in the time domain           

carrierFreq = 100e6;            % 100MHz
wavelength = physconst('LightSpeed')/carrierFreq; %wavelength is in meters



%DOA for Arbitrary Array Geometries (URA)
doa1 = [45;0];
fc = carrierFreq;
colSp = 0.5*wavelength;
rowSp = 0.4*wavelength;
ura = phased.URA('Size',[2 2],'ElementSpacing',[rowSp colSp]); %Change to 2x2 or 4x1, for N310
ura.Element.FrequencyRange = [90e5 110e6];

x = collectPlaneWave(ura,s,doa1,carrierFreq);
rs = RandStream.create('mt19937ar','Seed',2008);
noisePwr = 0.05;   % noise power 
noise = sqrt(noisePwr/2)*(randn(rs,size(x))+1i*randn(rs,size(x)));
estimator = phased.MUSICEstimator2D('SensorArray',ura,...
    'OperatingFrequency',fc,...
    'NumSignalsSource','Property',...
    'DOAOutputPort',true,'NumSignals',1,...
    'AzimuthScanAngles',-50:.5:50,...
    'ElevationScanAngles',-30:.5:30);
[~,doasURA] = estimator(x + noise)
% figure(2);
% plotSpectrum(estimator);
%Iteration of reciving to update weights based on DOA


%DOA for Specific Array Geometries (ULA)
%Plot MUSIC Spectrum of Two Signals Arriving at ULA
fc = carrierFreq;
array = phased.ULA('NumElements',10,'ElementSpacing',1.0);
doa2 = [45];
sig = collectPlaneWave(array,s,doa2,fc);

averageMatrix = zeros(100,1);

for i = 1:100
  rs = RandStream.create('mt19937ar', 'Seed', 2007+i);
noise = sqrt(noisePwr/2)*(randn(rs,size(sig))+1i*randn(rs,size(sig)));
%noise = 0.1*(randn(size(sig)) + 1i*randn(size(sig)));

estimator = phased.MUSICEstimator('SensorArray',array,...
    'OperatingFrequency',fc,...
    'DOAOutputPort',true,'NumSignalsSource','Property',...
    'NumSignals',1);
[y,doas] = estimator(sig + noise);
% doas
averageMatrix(i, 1) = doas(1,1);
doas_broadside = broadside2az(sort(doas),[20 -5]);
end
% figure(3);
% plotSpectrum(estimator,'NormalizeResponse',true)


%{
%DOA for Specific Array Geometries (ULA)
%Plot MUSIC Spectrum of Two Signals Arriving at ULA
fc = 150.0e6;
array = phased.ULA('NumElements',10,'ElementSpacing',1.0);

fs = 8000.0;
t = (0:1/fs:1).';
sig1 = cos(2*pi*t*300.0);
sig2 = cos(2*pi*t*400.0);
sig = collectPlaneWave(array,[sig1 sig2],[10 20; 60 -5]',fc);
noise = 0.1*(randn(size(sig)) + 1i*randn(size(sig)));

estimator = phased.MUSICEstimator('SensorArray',array,...
    'OperatingFrequency',fc,...
    'DOAOutputPort',true,'NumSignalsSource','Property',...
    'NumSignals',2);
[y,doas] = estimator(sig + noise);
doas = broadside2az(sort(doas),[20 -5])

plotSpectrum(estimator,'NormalizeResponse',true)

%}
