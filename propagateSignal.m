function [rx_xA, noise] = propagateSignal(x, pathBtoA, targetlocB, targetlocA, zeroVelocity, carrierFreq, noisePwr, rs, transmitter, radiator, targetchannel, ura)

% Transmit Signal
[x2, txstatus] = transmitter(x);

% Radiate pulse toward the target
x2 = radiator(x2,pathBtoA);

% Propagate pulse toward the target
x2 = targetchannel(x2,targetlocB,targetlocA,zeroVelocity,zeroVelocity);

rx_xA = collectPlaneWave(ura, x2, pathBtoA, carrierFreq);
noise = sqrt(noisePwr/2)*(randn(rs,size(rx_xA))+1i*randn(rs,size(rx_xA)));

end