function [transmitter, radiator, targetchannel, amplifier] = initPhasedObjs(ura, carrierFreq, samplingFreq)

% Initialize Transmitter, Radiator, TargetChannel, and Amplifier
transmitter = phased.Transmitter('PeakPower',1e4,'Gain',20,'InUseOutputPort',true);
radiator = phased.Radiator('Sensor',ura,'OperatingFrequency',carrierFreq);
targetchannel = phased.FreeSpace('TwoWayPropagation',true,'SampleRate',samplingFreq,'OperatingFrequency', carrierFreq);
amplifier = phased.ReceiverPreamp('EnableInputPort',true);

end