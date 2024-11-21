t = 0:0.001:0.3;            % time, sampling frequency is 1kHz
carrierFreq = 100e6;        % 100MHz
colSp = 0.5;
rowSp = 0.4;
noisePwr = 0.05;
bjammerPwr = .01;
doa = [45;0];

averageMatrix = zeros(1, 2);

%Init Transmitter, radiator
transmitter = phased.Transmitter('PeakPower',1e4,'Gain',20,...
    'InUseOutputPort',true);
radiator = phased.Radiator('Sensor',ura,'OperatingFrequency',fc);
targetloc = [1000 ; 500; 0];
%[~,tgtang] = rangeangle(targetloc);
%Create signal
i=1;
[ura, x, noise] = createSignal(t, carrierFreq, colSp, rowSp, noisePwr, doa,i);
% Transmit waveform
s = x(:,1);
[s,txstatus] = transmitter(s); %instead of x needs to be s because s is the vector of the matix
% Radiate pulse toward the target
x=s;
x = radiator(x,doa);
% Propagate pulse toward the target
x = targetchannel(x,[0;0;0],targetloc,[0;0;0],[0;0;0]);
plot(t, x);
