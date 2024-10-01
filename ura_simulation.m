% URA Simulation

% Rectangular Pulse
t = 0:0.001:0.3;                % Time, sampling frequency is 1kHz
s = zeros(size(t));  
s = s(:);                       % Signal in column vector
s(201:205) = s(201:205) + 1;    % Define the pulse
carrierFreq = 100e6;            % 100MHz
wavelength = physconst('LightSpeed')/carrierFreq; % wavelength is in meters

% DOA for Arbitrary Array Geometries (URA)

fc = carrierFreq;
colSp = 0.5*wavelength;
rowSp = 0.4*wavelength;
ura = phased.URA('Size',[2 2],'ElementSpacing',[rowSp colSp]); % N310 is 4T4R
ura.Element.FrequencyRange = [90e5 110e6];
rs = RandStream.create('mt19937ar','Seed',2008);
noisePwr = 0.05;

estimator2D = phased.MUSICEstimator2D('SensorArray',ura,...
    'OperatingFrequency',fc,...
    'NumSignalsSource','Property',...
    'DOAOutputPort',true,'NumSignals',1,...
    'AzimuthScanAngles',-50:.5:50,...
    'ElevationScanAngles',-30:.5:30);

outputDoA = zeros(101,2);

for i = -50:1:50
    doa1 = [i;0];
    x = collectPlaneWave(ura,s,doa1,carrierFreq);
    noise = sqrt(noisePwr/2)*(randn(rs,size(x))+1i*randn(rs,size(x)));

    [~,doas2D] = estimator2D(x + noise);

    outputDoA(i+51,1) = doa1(1,1);
    outputDoA(i+51,2) = doas2D(1,1);
end

figure(1);
diff = outputDoA(:,2)-outputDoA(:,1);
plot(outputDoA(:,1), diff)
title("Measured Azimuth Angle - Given Azimuth Angle")
xlim([-50 50])
ylim([-7 7])
yline(0)


doa1 = [45;0];
fc = carrierFreq;
colSp = 0.5*wavelength;
rowSp = 0.4*wavelength;
ura = phased.URA('Size',[2 2],'ElementSpacing',[rowSp colSp]); % N310 is 4T4R
ura.Element.FrequencyRange = [90e5 110e6];

x = collectPlaneWave(ura,s,doa1,carrierFreq);
rs = RandStream.create('mt19937ar','Seed',2008);
noisePwr = 0.05;
noise = sqrt(noisePwr/2)*(randn(rs,size(x))+1i*randn(rs,size(x))); % increase noise power reduces accuracy of DOA estimation

estimator2D = phased.MUSICEstimator2D('SensorArray',ura,...
    'OperatingFrequency',fc,...
    'NumSignalsSource','Property',...
    'DOAOutputPort',true,'NumSignals',1,...
    'AzimuthScanAngles',-50:.5:50,...
    'ElevationScanAngles',-30:.5:30);
[~,doas2D] = estimator2D(x + noise);
figure(1);
plotSpectrum(estimator2D);
title("URA 2x2 with 2D MUSIC Estimator");
fprintf("Given DoA: %d %d \n", doa1(1,1), doa1(2,1))
% fprintf()
% fprintf()
fprintf("Received Doa: %d %d \n", doas2D(1,1), doas2D(2,1))
