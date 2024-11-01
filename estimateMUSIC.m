function [doas, averageMatrix] = estimateMUSIC(ura, x, noise, carrierFreq, averageMatrix, i)
% estimateMUSIC takes in ura and noise and outputs doa array

estimator2D = phased.MUSICEstimator2D('SensorArray',ura,...
    'OperatingFrequency',carrierFreq,...
    'NumSignalsSource','Property',...
    'DOAOutputPort',true,'NumSignals',1,...
    'AzimuthScanAngles',-50:.5:50,...
    'ElevationScanAngles',-30:.5:30);
[~,doas] = estimator2D(x + noise);

%figure;
%plotSpectrum(estimator2D);
%title("URA 2x2 with 2D MUSIC Estimator");

fprintf("Received Doa: %d %d \n", doas(1,1), doas(2,1))
averageMatrix(i, 1) = doas(1,1);
averageMatrix(i, 2) = doas(2,1);


end