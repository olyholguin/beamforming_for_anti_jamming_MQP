function [encoder,scrambler,modulatorOFDM,steeringvec,transmitter,...
    radiator,pilots,numDataSymbols,frmSz] = helperMIMOTxSetup(gc,tp)
% This function helperMIMOTxSetup is only in support of
% MIMOBeamformingExample. It may be removed in a future release.

% Copyright 2012-2019 The MathWorks, Inc.

%frame size
BitsPerSample=log2(double(gc.modMode));
frmSz = (gc.FRM*BitsPerSample*(1/3))-6;
numTx= tp.numTXElements;

encoder = comm.ConvolutionalEncoder( ...
    'TrellisStructure',poly2trellis(7, [133 171 165]), ...
    'TerminationMethod',  'Terminated');

% Length of ConvolutionalEncoder output 
% n = log2( enc.TrellisStructure.numInputSymbols)
% k = log2( enc.TrellisStructure.numOutputSymbols)
% = (input length + Constraints-1)*n/k   %n/k = 3 Constraints = 7; 
lengthConvOut = (frmSz+6)*3;

scrambler = comm.Scrambler(2, [1 0 1 1 0 1 0 1], [1 1 1 1 1 1 0]);

lengthQAMOut = lengthConvOut/log2(gc.modMode);
% resource grid
numDataSymbols = lengthQAMOut/gc.numCarriers;

% Multi-antenna pilots
pilots = helperCreatePilots(numDataSymbols,numTx);

% Construct OFDM Modulator with multiple antennas
modulatorOFDM = comm.OFDMModulator(...
    'FFTLength' ,                      gc.FFTLength,...
    'NumGuardBandCarriers', gc.NumGuardBandCarriers,...
    'InsertDCNull',                   true, ...
    'PilotInputPort',                 true,...
    'PilotCarrierIndices',         gc.PilotCarrierIndices,...
    'CyclicPrefixLength',         gc.CyclicPrefixLength,...
    'NumSymbols',                  numDataSymbols,...
    'NumTransmitAntennas',  numTx);

% Antenna definition
ula = phased.ULA( tp.numTXElements, ...
        'ElementSpacing', 0.5*gc.lambda, ...
        'Element', phased.IsotropicAntennaElement('BackBaffled', true));
    
steeringvec = phased.SteeringVector('SensorArray',ula,'PropagationSpeed',gc.cLight);

%Gain per antenna element 
transmitter = phased.Transmitter('PeakPower',tp.txPower/numTx,'Gain',tp.txGain);

%Transmit array
radiator = phased.Radiator('Sensor',ula,'WeightsInputPort',true,...
        'PropagationSpeed',gc.cLight,'OperatingFrequency',gc.fc,...
        'CombineRadiatedSignals',false);
