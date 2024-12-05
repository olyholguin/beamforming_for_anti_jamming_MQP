function [yURA, w] = beamformerMVDR(ura, x, noise, doas, t, carrierFreq)
% beamformerMVDR takes in URA and DoA and outputs signal and weights

mvdrbeamformer = phased.MVDRBeamformer('SensorArray',ura,...
    'Direction',doas,'OperatingFrequency',carrierFreq,...
    'TrainingInputPort',true,'WeightsOutputPort',true);
rxSignal = x + noise;
[yURA, w]= mvdrbeamformer(rxSignal, noise);

% figure;
% plot(t,abs(yURA)); 
% axis tight;
% title('Output of MVDR Beamformer for URA');
% xlabel('Time (s)');
% ylabel('Magnitude (V)');
% 
% figure;
% p = pattern(ura, carrierFreq, -60:60, 0 ,'Weights', w,'Type','powerdb',...
%     'PropagationSpeed',physconst('LightSpeed'),'Normalize',false,...
%     'CoordinateSystem','rectangular');
% plot(p)
% title('Response Pattern at 0 Degrees Elevation');
% 
% figure;
% polarpattern(p);
% title('MVDR Beam Pattern');

end