t = 0:0.001:0.3;                % Time, sampling frequency is 1kHz
s = zeros(size(t));  
s = s(:);                       % Signal in column vector
s(201:205) = s(201:205) + 1;    % Define the pulse
plot(t,s)
title('Pulse')
xlabel('Time (s)')
ylabel('Amplitude (V)')

carrierFreq = 100e6;
wavelength = physconst('LightSpeed')/carrierFreq;

ula = phased.ULA('NumElements',10,'ElementSpacing',wavelength/2);
ula.Element.FrequencyRange = [90e5 110e6];

inputAngle = [45; 0];
x = collectPlaneWave(ula,s,inputAngle,carrierFreq);

% Create and reset a local random number generator so the result is the
% same every time.
rs = RandStream.create('mt19937ar','Seed',2008);

noisePwr = .5;   % noise power 
noise = sqrt(noisePwr/2)*(randn(rs,size(x))+1i*randn(rs,size(x)));

rxSignal = x + noise;


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

%%%Phase Shift Beamformer
psbeamformer = phased.PhaseShiftBeamformer('SensorArray',ula,...
    'OperatingFrequency',carrierFreq,'Direction',inputAngle,...
    'WeightsOutputPort', true);
[yCbf,w] = psbeamformer(rxSignal);
% Plot the output
clf
plot(t,abs(yCbf))
axis tight
title('Output of Phase Shift Beamformer')
xlabel('Time (s)')
ylabel('Magnitude (V)')

% Plot array response with weighting
pattern(ula,carrierFreq,-180:180,0,'Weights',w,'Type','powerdb',...
    'PropagationSpeed',physconst('LightSpeed'),'Normalize',false,...
    'CoordinateSystem','rectangular')
axis([-90 90 -60 0]);

%%%%Modeling the interference Signals
nSamp = length(t);
s1 = 10*randn(rs,nSamp,1);
s2 = 10*randn(rs,nSamp,1);
% interference at 30 degrees and 50 degrees
interference = collectPlaneWave(ula,[s1 s2],[30 50; 0 0],carrierFreq);

noisePwr = 0.00001;   % noise power, 50dB SNR 
noise = sqrt(noisePwr/2)*(randn(rs,size(x))+1i*randn(rs,size(x)));

rxInt = interference + noise;                 % total interference + noise
rxSignal = x + rxInt;                % total received Signal

yCbf = psbeamformer(rxSignal);

plot(t,abs(yCbf))
axis tight
title('Output of Phase Shift Beamformer With Presence of Interference')
xlabel('Time (s)');ylabel('Magnitude (V)')

%%%%%%MVDR Beamformer
% Define the MVDR beamformer
mvdrbeamformer = phased.MVDRBeamformer('SensorArray',ula,...
    'Direction',inputAngle,'OperatingFrequency',carrierFreq,...
    'WeightsOutputPort',true);

mvdrbeamformer.TrainingInputPort = true;

[yMVDR, wMVDR] = mvdrbeamformer(rxSignal,rxInt);

plot(t,abs(yMVDR)); axis tight;
title('Output of MVDR Beamformer With Presence of Interference');
xlabel('Time (s)');ylabel('Magnitude (V)');

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

%%%%%Self Nulling Issue in MVDR
mvdrbeamformer_selfnull = phased.MVDRBeamformer('SensorArray',ula,...
    'Direction',inputAngle,'OperatingFrequency',carrierFreq,...
    'WeightsOutputPort',true,'TrainingInputPort',false);

expDir = [43; 0];
mvdrbeamformer_selfnull.Direction = expDir;

[ySn, wSn] = mvdrbeamformer_selfnull(rxSignal);

plot(t,abs(ySn)); axis tight;
title('Output of MVDR Beamformer With Signal Direction Mismatch');
xlabel('Time (s)');ylabel('Magnitude (V)');

pattern(ula,carrierFreq,-180:180,0,'Weights',wSn,'Type','powerdb',...
    'PropagationSpeed',physconst('LightSpeed'),'Normalize',false,...
    'CoordinateSystem','rectangular');
axis([-90 90 -40 25]);

%%%%LCMV Beamformer
lcmvbeamformer = phased.LCMVBeamformer('WeightsOutputPort',true);

steeringvec = phased.SteeringVector('SensorArray',ula);
stv = steeringvec(carrierFreq,[43 41 45]);

lcmvbeamformer.Constraint = stv;
lcmvbeamformer.DesiredResponse = [1; 1; 1];

[yLCMV,wLCMV] = lcmvbeamformer(rxSignal);

plot(t,abs(yLCMV)); axis tight;
title('Output of LCMV Beamformer With Signal Direction Mismatch');
xlabel('Time (s)');ylabel('Magnitude (V)');

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

%%%%%2D Array Beamforming
colSp = 0.5*wavelength;
rowSp = 0.4*wavelength;
ura = phased.URA('Size',[10 5],'ElementSpacing',[rowSp colSp]);
ura.Element.FrequencyRange = [90e5 110e6];

x = collectPlaneWave(ura,s,inputAngle,carrierFreq);
noise = sqrt(noisePwr/2)*(randn(rs,size(x))+1i*randn(rs,size(x)));

s1 = 10*randn(rs,nSamp,1);
s2 = 10*randn(rs,nSamp,1);

%interference at [30; 10] and at [50; -5]
interference = collectPlaneWave(ura,[s1 s2],[30 50; 10 -5],carrierFreq);
rxInt = interference + noise;                 % total interference + noise
rxSignal = x + rxInt;                % total received signal

mvdrbeamformer = phased.MVDRBeamformer('SensorArray',ura,...
    'Direction',inputAngle,'OperatingFrequency',carrierFreq,...
    'TrainingInputPort',true,'WeightsOutputPort',true);

[yURA,w]= mvdrbeamformer(rxSignal,rxInt);

plot(t,abs(yURA)); axis tight;
title('Output of MVDR Beamformer for URA');
xlabel('Time (s)');ylabel('Magnitude (V)');

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
