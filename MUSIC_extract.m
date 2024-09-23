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



%DOA for Arbitrary Array Geometries (URA)
% Estimate DOAs of 2 signals MATLAB Example
%Two sine waves 450Hz and 600Hz strike WRA from two different dirrections
f1 = 450.0;
%f2 = 600.0;
doa1 = [42;-8];
%doa2 = [-7;22];
fc = carrierFreq;
%c = physconst('LightSpeed');
%lam = c/fc;
%fs = 8000;
%Creates URA with default elements. 
% Set the frequency response range of the elements
%array = phased.URA('Size',[11 11],'ElementSpacing',[lam/2 lam/2]);
%array.Element.FrequencyRange = [50.0e6 500.0e6];
colSp = 0.5*wavelength;
rowSp = 0.4*wavelength;
ura = phased.URA('Size',[10 5],'ElementSpacing',[rowSp colSp]);
ura.Element.FrequencyRange = [90e5 110e6];

x = collectPlaneWave(ura,s,doa1,carrierFreq);
noise = sqrt(noisePwr/2)*(randn(rs,size(x))+1i*randn(rs,size(x)));
%Create signals and add random noise
%t = (0:1/fs:1).';
%x1 = cos(2*pi*t*f1);
%x2 = cos(2*pi*t*f2);
%x = collectPlaneWave(array,x1,doa1,fc);
%noise = 0.1*(randn(size(x))+1i*randn(size(x)));

estimator = phased.MUSICEstimator2D('SensorArray',ura,...
    'OperatingFrequency',fc,...
    'NumSignalsSource','Property',...
    'DOAOutputPort',true,'NumSignals',1,...
    'AzimuthScanAngles',-50:.5:50,...
    'ElevationScanAngles',-30:.5:30);
[~,doas] = estimator(x + noise)

plotSpectrum(estimator);


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

%Rectangular pulse
%{
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

% Uniform Linear Array with 10 elements, 
% spacing between them is set to half the wavelength of the carrier wave 
ula = phased.ULA('NumElements',10,'ElementSpacing',wavelength/2);
ula.Element.FrequencyRange = [90e5 110e6];

% Defines the angle of arrival and elevation of arrival
inputAngle = [45; 0]; %[azimuth angle, elevation]
x = collectPlaneWave(ula,s,inputAngle,carrierFreq);

% Create and reset a local random number generator so the result is the
% same every time.
rs = RandStream.create('mt19937ar','Seed',2008);

noisePwr = .5;   % noise power 
noise = sqrt(noisePwr/2)*(randn(rs,size(x))+1i*randn(rs,size(x)));

rxSignal = x + noise;

% of the 10 elements, 2 are plotted
figure(2);
subplot(211)
plot(t,abs(rxSignal(:,1)))
axis tight
title('Pulse at Antenna 1')
xlabel('Time (s)')
ylabel('Magnitude (V)')
subplot(212)
plot(t,abs(rxSignal(:,2)))
axis tight
title('Pulse at Antenna 2')
xlabel('Time (s)')
ylabel('Magnitude (V)')
%}