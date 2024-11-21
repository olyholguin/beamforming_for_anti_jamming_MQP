function gc = helperGetDesignSpecsParameters
% This function is only in support of MIMOBeamformingExample.
% It may be removed in a future release.

% Copyright 2012-2014 The MathWorks, Inc.


gc.modOrder = 4;
gc.modMode = gc.modOrder^2;
gc.upSample = 8;
gc.cLight = 3e8;
gc.fc = 2.4e9;               % 2.4 GHz ISM Band
gc.lambda = gc.cLight/gc.fc;
gc.nT = 290;       % Noise Temp in deg K
gc.dtVideo = 1/15;
gc.bitRate = 1/gc.dtVideo*8*2800;
gc.symRate = gc.bitRate/gc.modOrder;
gc.frameDelay = 10 * gc.modOrder;
gc.scanAz = -180:180;

sz = get(0, 'ScreenSize');

sz2 = repmat(sz(3:4), 1,2);
gc.envPlotPosition = round([0, 0.25, 0.25, 0.25] .* sz2);
gc.constPlotPosition = round([0.0125, 0.52, 0.2381, 0.38] .* sz2);

% OFDM 
gc.FRM=5760*4;
gc.numCarriers = 48;
gc.CyclicPrefixLength = 16;
gc.PilotCarrierIndices = [12;26;40;54];
gc.CarriersLocations=[7:11,13:25,27:32,34:39,41:53,55:59];
gc.FFTLength=64;
gc.NumGuardBandCarriers= [6; 5];

% Channel model
gc.Doppler = 5;
gc.chanSRate = 1e6;
DelaySpread = gc.CyclicPrefixLength -1;
numPaths= 5;
gc.PathDelays = floor(linspace(0,DelaySpread,numPaths))*(1/gc.chanSRate);
gc.PathGains  = zeros(size(gc.PathDelays));
for n=2:numPaths
    gc.PathGains(n) = gc.PathGains(n-1)-abs(randn);
end

