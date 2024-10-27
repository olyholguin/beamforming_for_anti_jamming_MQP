function [ura, x, noise] = createSignal(t, carrierFreq, colSp, rowSp, noisePwr, doa)
% createSignal creates a rectangular pulse using carrierFreq, colSp, rowSp 
% function outputs URA and noise

s = zeros(size(t));  
s = s(:);                       % Signal in column vector
s(201:205) = s(201:205) + 1;    % Define the pulse
wavelength = physconst('LightSpeed')/carrierFreq; % wavelength is in meters
rowSpacing = rowSp * wavelength;
colSpacing = colSp * wavelength;

ura = phased.URA('Size',[2 2],'ElementSpacing',[rowSpacing colSpacing]); % N310 is 4T4R
ura.Element.FrequencyRange = [90e5 110e6];

x = collectPlaneWave(ura, s, doa, carrierFreq);
rs = RandStream.create('mt19937ar','Seed',2008);
noise = sqrt(noisePwr/2)*(randn(rs,size(x))+1i*randn(rs,size(x)));

end