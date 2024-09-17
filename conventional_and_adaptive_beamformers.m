% MathWorks Script for Conventional and Adaptive Beamforming

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
inputAngle = [45; 0];
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

% Phase Shift Beamformer (conventional)
psbeamformer = phased.PhaseShiftBeamformer('SensorArray',ula,...
    'OperatingFrequency',carrierFreq,'Direction',inputAngle,...
    'WeightsOutputPort', true);
[yCbf,w] = psbeamformer(rxSignal);

% Plot the output
clf
figure(3);
plot(t,abs(yCbf))
axis tight
title('Output of Phase Shift Beamformer')
xlabel('Time (s)')
ylabel('Magnitude (V)')

% Plot array response with weighting
figure(4);
pattern(ula,carrierFreq,-180:180,0,'Weights',w,'Type','powerdb',...
    'PropagationSpeed',physconst('LightSpeed'),'Normalize',false,...
    'CoordinateSystem','rectangular')
axis([-90 90 -60 0]);

% Modeling the interference Signals
nSamp = length(t);
s1 = 10*randn(rs,nSamp,1);
s2 = 10*randn(rs,nSamp,1);

% interference at 30 degrees and 50 degrees
interference = collectPlaneWave(ula,[s1 s2],[30 50; 0 0],carrierFreq);

% low level of noise is added to compare phaseshift o/p with interference
noisePwr = 0.00001;   % noise power, 50dB SNR 
noise = sqrt(noisePwr/2)*(randn(rs,size(x))+1i*randn(rs,size(x)));

rxInt = interference + noise;       % total interference + noise
rxSignal = x + rxInt;               % total received Signal

yCbf = psbeamformer(rxSignal);

figure(5);
plot(t,abs(yCbf))
axis tight
title('Output of Phase Shift Beamformer With Presence of Interference')
xlabel('Time (s)')
ylabel('Magnitude (V)')

% MVDR Beamformer
% This also uses the uniform linear array
mvdrbeamformer = phased.MVDRBeamformer('SensorArray',ula,...
    'Direction',inputAngle,'OperatingFrequency',carrierFreq,...
    'WeightsOutputPort',true);

% training input is how the mvdr can learn from itself
mvdrbeamformer.TrainingInputPort = true;

[yMVDR, wMVDR] = mvdrbeamformer(rxSignal,rxInt);

figure(6);
plot(t,abs(yMVDR))
axis tight;
title('Output of MVDR Beamformer With Presence of Interference');
xlabel('Time (s)')
ylabel('Magnitude (V)')

% Response pattern of the beamformer, azimuth vs. power
figure(7);
pattern(ula,carrierFreq,-180:180,0,'Weights',wMVDR,'Type','powerdb',...
    'PropagationSpeed',physconst('LightSpeed'),'Normalize',false,...
    'CoordinateSystem','rectangular');
axis([-90 90 -80 20]);

hold on;   % compare to PhaseShift
pattern(ula,carrierFreq,-180:180,0,'Weights',w,...
    'PropagationSpeed',physconst('LightSpeed'),'Normalize',false,...
    'Type','powerdb','CoordinateSystem','rectangular');
hold off;
legend('MVDR','PhaseShift')

% Self Nulling Issue in MVDR
mvdrbeamformer_selfnull = phased.MVDRBeamformer('SensorArray',ula,...
    'Direction',inputAngle,'OperatingFrequency',carrierFreq,...
    'WeightsOutputPort',true,'TrainingInputPort',false);

% if signal is slightly off, mvdr output is not useful
expDir = [43; 0];
mvdrbeamformer_selfnull.Direction = expDir;

[ySn, wSn] = mvdrbeamformer_selfnull(rxSignal);

figure(8);
plot(t,abs(ySn)); 
axis tight;
title('Output of MVDR Beamformer With Signal Direction Mismatch');
xlabel('Time (s)');
ylabel('Magnitude (V)');

% also plots the angle perspective with slight mismatch
figure(9);
pattern(ula,carrierFreq,-180:180,0,'Weights',wSn,'Type','powerdb',...
    'PropagationSpeed',physconst('LightSpeed'),'Normalize',false,...
    'CoordinateSystem','rectangular');
axis([-90 90 -40 25]);

% LCMV Beamformer
% Initialize an LCMV beamformer object. 'WeightsOutputPort',true specifies
% that the beamforming weights will be output along with the beamformed signal
lcmvbeamformer = phased.LCMVBeamformer('WeightsOutputPort',true);

% Create a steering vector object for the uniform linear array 
% Generate the steering vectors for three directions: [43, 41, 45] degrees 
% at a specific carrier frequency (carrierFreq).
steeringvec = phased.SteeringVector('SensorArray',ula);
stv = steeringvec(carrierFreq,[43 41 45]);

% Set the beamformer's constraint to match the steering vector.
% This ensures that the beamformer maintains unity gain in the desired directions
lcmvbeamformer.Constraint = stv;
% Define the desired response in the directions of interest. In this case,
% we are specifying equal response (1) for the three directions.
lcmvbeamformer.DesiredResponse = [1; 1; 1];

% Apply the LCMV beamformer to recived signal
[yLCMV,wLCMV] = lcmvbeamformer(rxSignal);

% Plots LCMV output with slight mismatch that mvdr could not handle
figure(10);
plot(t,abs(yLCMV)); 
axis tight;
title('Output of LCMV Beamformer With Signal Direction Mismatch');
xlabel('Time (s)');
ylabel('Magnitude (V)');

% And plots angle representation
figure(11);
pattern(ula,carrierFreq,-180:180,0,'Weights',wLCMV,'Type','powerdb',...
    'PropagationSpeed',physconst('LightSpeed'),'Normalize',false,...
    'CoordinateSystem','rectangular');
axis([0 90 -40 35]);

hold on;  % compare to MVDR
pattern(ula,carrierFreq,-180:180,0,'Weights',wSn,...
    'PropagationSpeed',physconst('LightSpeed'),'Normalize',false,...
    'Type','powerdb','CoordinateSystem','rectangular');
hold off;
legend('LCMV','MVDR');

% 2D Array Beamforming
% this section introduces a Uniform Rectangular Array
% that can change signals in azimuth and elevation
colSp = 0.5*wavelength;
rowSp = 0.4*wavelength;
ura = phased.URA('Size',[10 5],'ElementSpacing',[rowSp colSp]);
ura.Element.FrequencyRange = [90e5 110e6];

x = collectPlaneWave(ura,s,inputAngle,carrierFreq);
noise = sqrt(noisePwr/2)*(randn(rs,size(x))+1i*randn(rs,size(x)));

s1 = 10*randn(rs,nSamp,1);
s2 = 10*randn(rs,nSamp,1);

% interference at [30; 10] and at [50; -5]
interference = collectPlaneWave(ura,[s1 s2],[30 50; 10 -5],carrierFreq);
rxInt = interference + noise;   % total interference + noise
rxSignal = x + rxInt;           % total received signal

mvdrbeamformer = phased.MVDRBeamformer('SensorArray',ura,...
    'Direction',inputAngle,'OperatingFrequency',carrierFreq,...
    'TrainingInputPort',true,'WeightsOutputPort',true);

[yURA,w]= mvdrbeamformer(rxSignal,rxInt);

figure(12);
plot(t,abs(yURA)); 
axis tight;
title('Output of MVDR Beamformer for URA');
xlabel('Time (s)');
ylabel('Magnitude (V)');

% Shows the input at -5 degrees elevation and 10 degress elevation
figure(13);
subplot(2,1,1);
pattern(ura,carrierFreq,-180:180,-5,'Weights',w,'Type','powerdb',...
    'PropagationSpeed',physconst('LightSpeed'),'Normalize',false,...
    'CoordinateSystem','rectangular');
title('Response Pattern at -5 Degrees Elevation');
axis([-90 90 -60 -5]);
subplot(2,1,2);
pattern(ura,carrierFreq,-180:180,10,'Weights',w,'Type','powerdb',...
    'PropagationSpeed',physconst('LightSpeed'),'Normalize',false,...
    'CoordinateSystem','rectangular');
axis([-90 90 -60 -5]);
title('Response Pattern at 10 Degrees Elevation');
