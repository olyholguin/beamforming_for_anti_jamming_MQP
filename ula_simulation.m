%ULA
%MATLAB Script for MUSIC Algorithm

%Rectangular Pulse
t = 0:0.001:0.3;                % Time, sampling frequency is 1kHz
s = zeros(size(t));  
s = s(:);                       % Signal in column vector
s(201:205) = s(201:205) + 1;    % Define the pulse
figure(1);                      % Received signal is a rectangular pulse
plot(t,s)
title('Pulse')
xlabel('Time (s)')
ylabel('Amplitude (V)')         % Plots the signal in the time domain           

carrierFreq = 100e6;            % 100MHz
wavelength = physconst('LightSpeed')/carrierFreq; %wavelength is in meters



% DOA for Specific Array Geometries (ULA)
% Plot MUSIC Spectrum of Two Signals Arriving at ULA
fc = carrierFreq;
ula = phased.ULA('NumElements',4,'ElementSpacing',1.0);
doa1 = [45;0];
x = collectPlaneWave(ula,s,doa1,fc);

rs = RandStream.create('mt19937ar','Seed',2008);
noisePwr = .05;   % noise power 
noise = sqrt(noisePwr/2)*(randn(rs,size(x))+1i*randn(rs,size(x)));


estimator = phased.MUSICEstimator('SensorArray',ula,...
    'OperatingFrequency',fc,'ScanAngles',-50:.5:50,...
    'DOAOutputPort',true,'NumSignalsSource','Property',...
    'NumSignals',1);
[~,doaEstimate] = estimator(x + noise);
doas = broadside2az(sort(doaEstimate),[-20 5])
figure(2);
plotSpectrum(estimator,'NormalizeResponse',true)
% plotSpec = [y,doas];
% plotSpectrum(plotSpec)
% for loop -50 to 50 broadangle, set doa to index value
% store the DOA estimate output into matrix
% plot given - actual to show the difference
outputDOA = zeros(101, 2);
for i = -50:1:50
    doa1 = [i;0];
    x = collectPlaneWave(ula,s,doa1,fc);
    noise = sqrt(noisePwr/2)*(randn(rs,size(x))+1i*randn(rs,size(x)));
    [y, doaLoopEstimate] = estimator(x+noise);
    doas = broadside2az(sort(doaLoopEstimate),[-20 5]);
    outputDOA(i+51,1) = doa1(1,1);
    outputDOA(i+51,2) = doas(1,1);
end
figure(3);
diff = outputDOA(:,2)-outputDOA(:,1);
plot(outputDOA(:,1),diff)
title("ULA Measured - Given Azimuth Angle");
xlim([-50 50]);
yline(0);
