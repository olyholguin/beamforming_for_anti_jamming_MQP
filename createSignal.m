function [ura, x] = createSignal(t, carrierFreq, colSp, rowSp, i, pulseHeight)
% createSignal creates a rectangular pulse using carrierFreq, colSp, rowSp 
% function outputs URA and noise

s = zeros(size(t));  
s = s(:);                       % Signal in column vector
s(101:205) = s(101:205) + pulseHeight;    % Define the pulse
wavelength = physconst('LightSpeed')/carrierFreq; % wavelength is in meters
rowSpacing = rowSp * wavelength;
colSpacing = colSp * wavelength;

ura = phased.URA('Size',[2 2],'ElementSpacing',[rowSpacing colSpacing]); % N310 is 4T4R

ura_low = carrierFreq - 10e6;
ura_high = carrierFreq + 10e6;
ura.Element.FrequencyRange = [ura_low ura_high];

x = s;

end