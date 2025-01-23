function [doas, averageMatrix] = estimateMUSIC(ura, x, noise, carrierFreq, averageMatrix, i, azimuth_range, elevation_range)
% estimateMUSIC takes in ura and noise and outputs doa array

% azimuth_range(1) = 180-azimuth_range(1);
% azimuth_range(2) = 180-azimuth_range(2);
% a_low = azimuth_range(2);
% a_high = azimuth_range(1);
% e_low = elevation_range(1);
% e_high = elevation_range(2);

a_low = azimuth_range(1);
a_high = azimuth_range(2);
e_low = elevation_range(1);
e_high = elevation_range(2);

estimator2D = phased.MUSICEstimator2D('SensorArray',ura,...
    'OperatingFrequency',carrierFreq,...
    'NumSignalsSource','Property',...
    'DOAOutputPort',true,'NumSignals',1,...
    'AzimuthScanAngles',a_low:.5:a_high,...
    'ElevationScanAngles',e_low:.5:e_high);

% Testing different Azimuth Scan Angles
% estimator2D = phased.MUSICEstimator2D('SensorArray',ura,...
%     'OperatingFrequency',carrierFreq,...
%     'NumSignalsSource','Property',...
%     'DOAOutputPort',true,'NumSignals',1,...
%     'AzimuthScanAngles',130:-.5:-130,...
%     'ElevationScanAngles',e_low:.5:e_high);

[~,doas] = estimator2D(x + noise);

% figure;
% plotSpectrum(estimator2D);
% title("URA 2x2 with 2D MUSIC Estimator");

fprintf("Measured DoA: \t%.2f \t%.2f \n", round(doas(1,1),2), round(doas(2,1),2))
averageMatrix(i, 1) = doas(1,1);
averageMatrix(i, 2) = doas(2,1);


end