function [ura, x, noise] = createSignal(t, carrierFreq, colSp, rowSp, noisePwr, doa, i, pulseHeight)
% createSignal creates a rectangular pulse using carrierFreq, colSp, rowSp 
% function outputs URA and noise

s = zeros(size(t));  
s = s(:);                       % Signal in column vector
s(201:205) = s(201:205) + pulseHeight;    % Define the pulse
wavelength = physconst('LightSpeed')/carrierFreq; % wavelength is in meters
rowSpacing = rowSp * wavelength;
colSpacing = colSp * wavelength;

ura = phased.URA('Size',[2 2],'ElementSpacing',[rowSpacing colSpacing]); % N310 is 4T4R

ura_low = carrierFreq - 10e6;
ura_high = carrierFreq + 10e6;
ura.Element.FrequencyRange = [ura_low ura_high];

x = s;
rs = RandStream.create('mt19937ar', 'Seed', 2007+i);
noise = sqrt(noisePwr/2)*(randn(rs,size(x))+1i*randn(rs,size(x)));

end