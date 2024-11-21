colSp = 0.5;
rowSp = 0.4;
wavelength = physconst('LightSpeed')/100e6; % wavelength is in meters
rowSpacing = rowSp * wavelength;
colSpacing = colSp * wavelength;
antenna = phased.URA('Size',[2 2],'ElementSpacing',[rowSpacing colSpacing]);
%antenna = phased.ULA(4); 
Fs = 1e6;
fc = 1e9;
rng('default')
waveform = phased.RectangularWaveform('PulseWidth',100e-6,...
    'PRF',1e3,'NumPulses',5,'SampleRate',Fs);
transmitter = phased.Transmitter('PeakPower',1e4,'Gain',20,...
    'InUseOutputPort',true);
radiator = phased.Radiator('Sensor',antenna,'OperatingFrequency',fc);
jammer = barrageJammer('ERP',1000,...
    'SamplesPerFrame',waveform.NumPulses*waveform.SampleRate/waveform.PRF);
target = phased.RadarTarget('Model','Nonfluctuating',...
    'MeanRCS',1,'OperatingFrequency',fc);
targetchannel = phased.FreeSpace('TwoWayPropagation',true,...
    'SampleRate',Fs,'OperatingFrequency', fc);
jammerchannel = phased.FreeSpace('TwoWayPropagation',false,...
    'SampleRate',Fs,'OperatingFrequency', fc);
collector = phased.Collector('Sensor',antenna,...
    'OperatingFrequency',fc);
amplifier = phased.ReceiverPreamp('EnableInputPort',true);


targetloc = [1000 ; 500; 0];
jammerloc = [2000; 2000; 100];
[~,tgtang] = rangeangle(targetloc);
[~,jamang] = rangeangle(jammerloc);

wav = waveform();
% Transmit waveform
[wav,txstatus] = transmitter(wav);
% Radiate pulse toward the target
wav = radiator(wav,tgtang);
% Propagate pulse toward the target
wav = targetchannel(wav,[0;0;0],targetloc,[0;0;0],[0;0;0]);
% Reflect it off the target
wav = target(wav);
% Collect the echo
wav = collector(wav,tgtang);

jamsig = jammer();
% Propagate the jamming signal to the array
jamsig = jammerchannel(jamsig,jammerloc,[0;0;0],[0;0;0],[0;0;0]);
% Collect the jamming signal
jamsig = collector(jamsig,jamang);

% Receive target echo alone and target echo + jamming signal
pulsewave = amplifier(wav,~txstatus);
pulsewave_jamsig = amplifier(wav + jamsig,~txstatus);

subplot(2,1,1)
t = unigrid(0,1/Fs,size(pulsewave,1)*1/Fs,'[)');
plot(t*1000,abs(pulsewave(:,1)))
title('Magnitudes of Pulse Waveform Without Jamming--Element 1')
ylabel('Magnitude')
subplot(2,1,2)
plot(t*1000,abs(pulsewave_jamsig(:,1)))
title('Magnitudes of Pulse Waveform with Jamming--Element 1')
xlabel('millisec')
ylabel('Magnitude')