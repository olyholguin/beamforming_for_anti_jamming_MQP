function pilots = helperCreatePilots(numDataSymbols,numTx)
% This function is only in support of MIMOBeamformingExample.
% It may be removed in a future release.

% Copyright 2012-2016 The MathWorks, Inc.

% Create Pilots
pnseq = comm.PNSequence(...
        'Polynomial',[1 0 0 0 1 0 0 1],...
        'SamplesPerFrame', numDataSymbols,...
        'InitialConditions',[1 1 1 1 1 1 1]);
pilot = pnseq(); % Create pilot
pilots1 = repmat(pilot, 1, 4 ); % Expand to all pilot tones
pilots1 = 2*double(pilots1.'<1)-1; % Bipolar to unipolar
pilots1(4,:) = -1*pilots1(4,:); % Invert last pilot
% Multi-antenna pilots
pilots = repmat(pilots1,[1, 1, numTx]);
