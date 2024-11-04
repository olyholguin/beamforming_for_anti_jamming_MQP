function [y] = barrage_Jammer(power)

% rng default
% jammer = barrageJammer('ERP',1000);
% y = jammer();
% subplot(2,1,1)
% histogram(real(y))
% title('Histogram of Real Part')
% subplot(2,1,2)
% histogram(imag(y))
% title('Histogram of Imaginary Part')
% xlabel('Watts')

y = barrageJammer('ERP',power,...
    'SamplesPerFrame',301);
figure;
plot(abs(y()))
xlabel('Samples')
ylabel('Magnitude')
end