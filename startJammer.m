function [jamsig] = startJammer(bjammerPwr, samplingFreq, carrierFreq, ura, jammerloc, targetlocA, zeroVelocity, pathJtoA)

% Initialize Jammer
jammer = barrageJammer('ERP',bjammerPwr,'SamplesPerFrame',301);
jammerchannel = phased.FreeSpace('TwoWayPropagation',false,'SampleRate',samplingFreq,'OperatingFrequency', carrierFreq);
collector = phased.Collector('Sensor',ura,'OperatingFrequency',carrierFreq);

jamsig = jammer();
% Propagate the jamming signal to the array
jamsig = jammerchannel(jamsig,jammerloc,targetlocA,[-1; -1; 0],zeroVelocity);
% Collect the jamming signal
jamsig = collector(jamsig,pathJtoA);

end