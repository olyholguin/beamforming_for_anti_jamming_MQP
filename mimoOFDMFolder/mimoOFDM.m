addpath 'C:\Users\olivi\Documents\MATLAB\beamforming_for_anti_jamming_MQP'
%addpath 'C:\Users\lauren\Documents\MATLAB\beamforming_for_anti_jamming_MQP'
t = 0:0.001:0.3;            % time, sampling frequency is 1kHz
carrierFreq = 100e6;        % 100MHz
colSp = 0.5;
rowSp = 0.4;
noisePwr = 0.05;
bjammerPwr = .01;
doa = [45;0];

averageMatrix = zeros(1, 2);

%for i = 1:1
i=1;
[ura, x, noise] = createSignal(t, carrierFreq, colSp, rowSp, noisePwr, doa,i);
% Initialize system constants
rng(2014);
gc = helperGetDesignSpecsParameters();

% Tunable parameters
tp.txPower = 9;           % watt
tp.txGain = -8;           % dB
tp.mobileRange = 2750;    % m
tp.mobileAngle = 3;       % degrees
tp.interfPower = 1;       % watt
tp.interfGain = -20;      % dB
tp.interfRange = 9000;    % m
tp.interfAngle =   20;    % degrees
tp.numTXElements = 8;
tp.steeringAngle = 0;     % degrees
tp.rxGain = 108.8320 - tp.txGain; % dB

numTx= tp.numTXElements;

helperPlotMIMOEnvironment(gc, tp);

[encoder,scrambler,modulatorOFDM,steeringvec,transmitter,...
    radiator,pilots,numDataSymbols,frmSz] = helperMIMOTxSetup(gc,tp);

txBits = randi([0, 1], frmSz,1);
coded = encoder(txBits);
bitsS = scrambler(coded);
tx = qammod(bitsS,gc.modMode,'InputType','bit','UnitAveragePower',true);

ofdm1 = reshape(tx, gc.numCarriers,numDataSymbols);

ofdmData = repmat(ofdm1,[1, 1, numTx]);
txOFDM = modulatorOFDM(ofdmData, pilots);
%scale
txOFDM = txOFDM * ...
    (gc.FFTLength/sqrt(gc.FFTLength-sum(gc.NumGuardBandCarriers)-1));

% Amplify to achieve peak TX power for each channel
for n = 1:numTx
    txOFDM(:,n) = transmitter(txOFDM(:,n));
end

radiator.CombineRadiatedSignals = false;

wR = steeringvec(gc.fc,[-tp.mobileAngle;0]);

wT = steeringvec(gc.fc,[tp.steeringAngle;0]);
weight = wT.* wR;

txOFDM = radiator(txOFDM,repmat([tp.mobileAngle;0],1,numTx),conj(weight));

[channel,interferenceTransmitter,toRxAng,spLoss] = ...
    helperMIMOEnvSetup(gc,tp);
[sigFade, chPathG] =  channel(txOFDM);
sigLoss = sigFade/sqrt(db2pow(spLoss(1)));

% Generate interference and apply gain and propagation loss
numBits = size(sigFade,1);
interfSymbols = wgn(numBits,1,1,'linear','complex');
interfSymbols = interferenceTransmitter(interfSymbols);
interfLoss = interfSymbols/sqrt(db2pow(spLoss(2)));

[collector,receiver,demodulatorOFDM,descrambler,decoder] = ...
    helperMIMORxSetup(gc,tp,numDataSymbols);

rxSig = collector([sigLoss interfLoss],toRxAng);

% Front-end amplifier gain and thermal noise
rxSig = receiver(rxSig);

rxOFDM = rxSig * ...
    (sqrt(gc.FFTLength-sum(gc.NumGuardBandCarriers)-1)) / (gc.FFTLength);

% OFDM Demodulation
rxOFDM = demodulatorOFDM(rxOFDM);

% Channel estimation
hD = helperIdealChannelEstimation(gc,  numDataSymbols, chPathG);

% Equalization
rxEq = helperEqualizer(rxOFDM, hD, numTx);

% Collapse OFDM matrix
rxSymbs = rxEq(:);

rxBitsS = qamdemod(rxSymbs,gc.modMode,'UnitAveragePower',true,...
    'OutputType','bit');
rxCoded = descrambler(rxBitsS);
rxDeCoded = decoder(rxCoded);
rxBits = rxDeCoded(1:frmSz);

ber = comm.ErrorRate;
measures = ber(txBits, rxBits);
fprintf('BER = %.2f%%; No. of Bits = %d; No. of errors = %d\n', ...
    measures(1)*100,measures(3), measures(2));