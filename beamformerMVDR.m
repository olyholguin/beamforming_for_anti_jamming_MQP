function [yURA, w] = beamformerMVDR(ura, x, noise, doas, t, carrierFreq, propagation_path, show_plots)
% beamformerMVDR takes in URA and DoA and outputs signal and weights
% figure;
% plot(abs(x))

mvdrbeamformer = phased.MVDRBeamformer('SensorArray',ura,...
    'Direction',doas,'OperatingFrequency',carrierFreq,...
    'TrainingInputPort',true,'WeightsOutputPort',true);
% rxSignal = x + noise; 
% [yURA, w]= mvdrbeamformer(rxSignal, noise);
[yURA, w]= mvdrbeamformer(x, noise);

if (show_plots)
    figure;
    plot(t,abs(yURA));
    axis tight;
    title('Output of MVDR Beamformer');
    % subtitle(s)
    xlabel('Time (s)');
    ylabel('Magnitude (V)');
    xlim([0 0.3])
    ylim([0 0.18])

    figure;
    p = pattern(ura, carrierFreq, -90:90, 0 ,'Weights', w,'Type','powerdb',...
        'PropagationSpeed',physconst('LightSpeed'),'Normalize',false,...
        'CoordinateSystem','rectangular');
    % p = pattern(ura, carrierFreq, -90:90, 0 ,'Weights', w,'Type','powerdb',...
    %     'PropagationSpeed',physconst('LightSpeed'),...
    %     'CoordinateSystem','polar');
    angles = -90:1:90;
    plot(angles, p)
    xlim([-90 90])
    xticks(-90:45:90)
    title('Beam Pattern');
    xlabel('Azimuth Angle (degrees)')
    ylabel('Power (dB)')

    % figure;
    % polarpattern(p);
    % % thetalim([-90 90])
    % title('MVDR Beam Pattern');
end

end
