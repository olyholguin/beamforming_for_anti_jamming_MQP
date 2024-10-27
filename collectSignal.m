function [ura, x, noise] = collectSignal(~)
% function is to be used instead of createSignal, when we use N310 to Tx

ura = phased.URA('Size',[2 2],'ElementSpacing',[rowSpacing colSpacing]);
ura.Element.FrequencyRange = [90e5 110e6];

x = collectPlaneWave(ura, s, doa, carrierFreq);
rs = RandStream.create('mt19937ar','Seed',2008);
noise = sqrt(noisePwr/2)*(randn(rs,size(x))+1i*randn(rs,size(x)));
end