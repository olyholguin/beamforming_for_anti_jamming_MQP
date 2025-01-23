function H = helperIdealChannelEstimation(prm, Nsymb, chPathG)
% This function is only in support of MIMOBeamformingExample.
% It may be removed in a future release.

% Copyright 2012-2016 The MathWorks, Inc.

% Ideal channel estimation 
persistent dft; 
if isempty(dft) 
   dft = dsp.FFT; 
end 
% get parameters
numDataTones = prm.numCarriers;       % Number of subcarriers
N = prm.FFTLength;                    % FFT Length
cpLen = prm.CyclicPrefixLength;       % Cyclic Prefix Length
slotLen = (N+ cpLen);                 % Slot length 
% Get path delays
pathDelays = prm.PathDelays;
% Delays, in terms of number of channel samples, +1 for indexing
sampIdx = round(pathDelays/(1/prm.chanSRate)) + 1;

[~, numPaths, numTx, numRx] = size(chPathG);

H = complex(zeros(numDataTones, Nsymb, numTx, numRx));
for i= 1:numTx
    for j = 1:numRx
        link_PathG = chPathG(:, :, i, j);
        % Split this per OFDM symbol
        g = complex(zeros(Nsymb, numPaths));
        for m = 1:Nsymb 
            % First OFDM symbol 
            index=(m-1)*slotLen + (1:slotLen);
            g(m, :) = mean(link_PathG(index, :), 1);
        end
        hImp = complex(zeros(Nsymb, N));
        hImp(:, sampIdx) = g; % assign pathGains at sample locations
        % FFT processing
        h = dft(hImp.');
        h2=fftshift(h,1);
        sc=h2(prm.CarriersLocations,:);
        H(:,:,i,j) = sc;
    end
end
H=sum(H, 3)/numTx;
