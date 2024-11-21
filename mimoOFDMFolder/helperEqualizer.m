function rxEq = helperEqualizer(rxOFDM, hD, numTx)
% This function is only in support of MIMOBeamformingExample.
% It may be removed in a future release.

% Copyright 2012-2014 The MathWorks, Inc.

num = conj(hD);
denum=conj(hD).*hD;
rxEq = (rxOFDM .* num) ./ (numTx * denum);
