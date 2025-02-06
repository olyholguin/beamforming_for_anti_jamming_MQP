function [yURA, w] = beamformerMVDR(ura, x, noise, doas, t, carrierFreq, propagation_path, show_plots)
% beamformerMVDR takes in URA and DoA and outputs signal and weights

mvdrbeamformer = phased.MVDRBeamformer('SensorArray',ura,...
    'Direction',doas,'OperatingFrequency',carrierFreq,...
    'TrainingInputPort',true,'WeightsOutputPort',true);
rxSignal = x + noise;
[yURA, w]= mvdrbeamformer(rxSignal, noise);

if (show_plots)
    figure;
    plot(t,abs(yURA));
    axis tight;
    title(strcat('Output of MVDR Beamformer: ', propagation_path));
    xlabel('Time (s)');
    ylabel('Magnitude (V)');
    xlim([0 0.3])
    ylim([0 0.3])

    % figure;
    % p = pattern(ura, carrierFreq, -90:90, 0 ,'Weights', w,'Type','powerdb',...
    %     'PropagationSpeed',physconst('LightSpeed'),'Normalize',false,...
    %     'CoordinateSystem','rectangular');
    % % p = pattern(ura, carrierFreq, -90:90, 0 ,'Weights', w,'Type','powerdb',...
    % %     'PropagationSpeed',physconst('LightSpeed'),...
    % %     'CoordinateSystem','polar');
    % plot(p)
    % title('Response Pattern at 0 Degrees Elevation');

    % figure;
    % polarpattern(p);
    % % thetalim([-90 90])
    % title('MVDR Beam Pattern');
end

end
