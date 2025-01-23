% Oly URA Simulation

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
%{
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
%}

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

mvdrbeamformer = phased.MVDRBeamformer('SensorArray',ura,...
    'Direction',doas2D,'OperatingFrequency',carrierFreq,...
    'TrainingInputPort',true,'WeightsOutputPort',true);
rxSignal = x+noise;
[yURA,w]= mvdrbeamformer(rxSignal, noise);

figure(12);
plot(t,abs(yURA)); 
axis tight;
title('Output of MVDR Beamformer for URA');
xlabel('Time (s)');
ylabel('Magnitude (V)');

figure(14);
pattern(ura,carrierFreq,-180:180,0,'Weights',w,'Type','powerdb',...
    'PropagationSpeed',physconst('LightSpeed'),'Normalize',false,...
    'CoordinateSystem','rectangular');
%axis([-90 90 -60 -5]);
title('Response Pattern at 0 Degrees Elevation');

%%%%%%%%%%%%%%%%%polar plot 
% Define scan angles (ensure it matches the output's resolution)
theta_scan = linspace(-pi, pi, length(yURA));  % From -180 to 180 degrees

% Process MVDR output: Take magnitude and convert to dB (if needed)
beam_pattern = 10 * log10(abs(yURA) + eps);  % Avoid log(0) with eps

% Create the polar plot
fig = figure;
ax = polaraxes;

% Plot beam pattern in polar coordinates
polarplot(ax, theta_scan, beam_pattern, 'LineWidth', 2);

% Set plot properties for better visualization
ax.ThetaZeroLocation = 'top';       % 0 degrees points up (North)
ax.ThetaDir = 'clockwise';          % Clockwise angle increase
ax.RLim = [-50 0];                  % Set radial limits for dB scale

% Add optional labels and title
title('MVDR Beam Pattern');
ax.RAxisLabel.String = 'Gain (dB)';
ax.RAxisLocation = 55;              % Adjust radial axis label position

% Show the figure
show(fig);
