t = 0:0.001:0.3;            % time, sampling frequency is 1kHz
carrierFreq = 100e6;        % 100MHz
colSp = 0.5;
rowSp = 0.4;
noisePwr = .0;
i = randi([0 99],1,1);
rs = RandStream.create('mt19937ar', 'Seed', 2007+i);
bjammerPwr = .01;
doa = [0;0];
averageMatrix = zeros(1, 2);

%Create signal
i=1;
[ura, x, noise] = createSignal(t, carrierFreq, colSp, rowSp, noisePwr, doa,i);

%Init Transmitter, radiator, jammer
transmitter = phased.Transmitter('PeakPower',1e4,'Gain',20,...
    'InUseOutputPort',true);
radiator = phased.Radiator('Sensor',ura,'OperatingFrequency',carrierFreq);
jammer = barrageJammer('ERP',bjammerPwr,...
    'SamplesPerFrame',301);
% jammer = barrageJammer('ERP',power,...
%     'SamplesPerFrame',301);
% jamsig = barrage_Jammer(bjammerPwr); 
% jammer = barrageJammer('ERP',1000,...
%     'SamplesPerFrame',waveform.NumPulses*waveform.SampleRate/waveform.PRF);
targetchannel = phased.FreeSpace('TwoWayPropagation',true,...
    'SampleRate',Fs,'OperatingFrequency', fc);
jammerchannel = phased.FreeSpace('TwoWayPropagation',false,...
    'SampleRate',Fs,'OperatingFrequency', fc);
collector = phased.Collector('Sensor',antenna,...
    'OperatingFrequency',fc);
amplifier = phased.ReceiverPreamp('EnableInputPort',true);
targetlocB = [100 ; 0; 0];
targetlocA = [0 ; 0; 0];
jammerloc = [50; 50; 0];
[~,tgtang] = rangeangle(targetlocB);
[~,jamang] = rangeangle(jammerloc);


% Transmit waveform
% s = x(:,1);
[x, txstatus] = transmitter(x); %instead of x needs to be s because s is the vector of the matix
% Radiate pulse toward the target
% x = s;
x = radiator(x,doa);
% Propagate pulse toward the target
x = targetchannel(x,[0;0;0],targetlocB,[0;0;0],[0;0;0]);

jamsig = jammer();
% jamsig = barrage_Jammer(bjammerPwr);
% Propagate the jamming signal to the array
jamsig = jammerchannel(jamsig,jammerloc,[0;0;0],[0;0;0],[0;0;0]);
% Collect the jamming signal
jamsig = collector(jamsig,jamang);



% figure(1);
% plot(t, real(x));
% hold off
% plot(t, imag(x))
% hold on
% title("Output of Radiator")
% legend('Real', 'Imag')

rx_xB = collectPlaneWave(ura, x, doa, carrierFreq);
noise = sqrt(noisePwr/2)*(randn(rs,size(rx_xB))+1i*randn(rs,size(rx_xB)));
% noise = newNoise;
rx_xB_jamsig = rx_xB + jamsig;
% noise = zeros(301,4);

% figure(2);
% plot(t, real(rx_xB));
% hold off
% plot(t, imag(rx_xB))
% hold on
% title("Output of Collect Plane Wave")
% legend('Real', 'Imag')

[doas, averageMatrix] = estimateMUSIC(ura, rx_xB_jamsig, noise, carrierFreq, averageMatrix, i); 
fprintf("Given DoA: %d %d \n", doa(1,1), doa(2,1))

doa_NaN = isnan(doas(1,1)) || isnan(doas(2,1));
if(doa_NaN == 1)
    disp("DOAs are NaN");
    return;
end
% percent_error_1_1 = abs(doas(1,1) - doa(1,1)) / abs(doa(1,1)) * 100;
% percent_error_2_1 = abs(doas(2,1) - doa(2,1)) / abs(doa(2,1)) * 100;
% % Display the result
% disp(['Percent Error 1: ', num2str(percent_error_1_1), '%']);
% disp(['Percent Error 2: ', num2str(percent_error_2_1), '%']);
%total_percent_error = (percent_error_1_1 + percent_error_2_1) / 2;
total_percent_error = 0;

switch true
    case (total_percent_error > 90)
        disp('Percent Error Greater than 90');
        % Run Things again
        return;
    case (total_percent_error > 70)
        disp('Percent Error Greater than 70');
        return;
    case (total_percent_error > 50)
        disp('Percent Error Greater than 50');
        return;
    otherwise
        % Perform MVDR Beamforming
        [signal, weights] = beamformerMVDR(ura, rx_xB_jamsig, noise, doas, t, carrierFreq);
end

