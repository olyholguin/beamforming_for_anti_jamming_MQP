function [txBits, rxBits,rxSymbs] = helperRerunMIMOBeamformingExample(gc,tp,wT)
% This function is only in support of MIMOBeamformingExample.
% It may be removed in a future release.

%   Copyright 2012-2019 The MathWorks, Inc.

numTx = tp.numTXElements;

[encoder,scrambler,modulatorOFDM,steeringvec,transmitter,...
    radiator,pilots,numDataSymbols,frmSz] = helperMIMOTxSetup(gc,tp);


[channel,interferenceTransmitter,toRxAng,spLoss] = helperMIMOEnvSetup(gc,tp);

[collector,receiver,demodulatorOFDM,descrambler,decoder] = ...
    helperMIMORxSetup(gc,tp,numDataSymbols);

rng(2016);
txBits = randi([0, 1], frmSz,1);
coded = encoder(txBits);
bitsS = scrambler(coded);
tx = qammod(bitsS,gc.modMode,'InputType','bit','UnitAveragePower',true);

% Convert data into subcarrier streams
ofdm1 = reshape(tx, gc.numCarriers,numDataSymbols);

ofdmData = repmat(ofdm1,[1, 1, numTx]);
txOFDM = modulatorOFDM(ofdmData, pilots);
%scale
txOFDM = txOFDM * ...
    (gc.FFTLength/sqrt(gc.FFTLength-sum(gc.NumGuardBandCarriers)-1));

%Amplify each channel
for n = 1:numTx
    txOFDM(:,n) = transmitter(txOFDM(:,n));
end

%Model signal traveling to mobile by applying a phaseshift on the
%elements since phased.Radiator does not do it when radiated signals are
%uncombined.
wR = steeringvec(gc.fc,[-tp.mobileAngle;0]);

weight = wT .*wR;
txOFDM = radiator(txOFDM,repmat([tp.mobileAngle;0],1,numTx),conj(weight));

[sigFade, chPathG] =  channel(txOFDM);

% Apply loss due to propagation of transmitted signal
% use phased.Freespace instead to also simulate propagation delays
sigLoss = sigFade/sqrt(db2pow(spLoss(1)));

%Generate interference and apply gain and propagation loss
numBits = size(sigFade,1);
interfSymbols = wgn(numBits,1,1,'linear','complex');
interfSymbols = interferenceTransmitter(interfSymbols);
interfLoss = interfSymbols/sqrt(db2pow(spLoss(2)));

rxArray = collector([sigLoss interfLoss],toRxAng);

% Apply front-end amplifier gain and add thermal noise and
rxArray = receiver(rxArray);

%  % Find Amplifier gain to Normalise symbols
%  pr = std(rxArray);
%  pt = std(sigFade);
%  G = pt/pr;
%  rxArray = G * rxArray;

rxOFDM = rxArray * ...
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

