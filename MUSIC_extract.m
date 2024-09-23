%MATLAB Script for MUSIC Algorithm

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