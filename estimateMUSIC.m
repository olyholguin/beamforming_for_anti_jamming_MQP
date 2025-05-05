function [doas] = estimateMUSIC(ura, x, carrierFreq, azimuth_range, elevation_range)

% estimateMUSIC takes in ura and noise and outputs doa array
% figure;
% plot(abs(x));


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

% [~,doas] = estimator2D(x + noise);
[~,doas] = estimator2D(x);

% figure;
% plotSpectrum(estimator2D);
% title("URA 2x2 with 2D MUSIC Estimator");

fprintf("Measured DoA: \t%.2f \t%.2f \n", round(doas(1,1),2), round(doas(2,1),2))

end