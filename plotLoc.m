function [] = plotLoc(targetlocA,targetlocB,jammerloc)
%Plots the locations of reciver, transmiter, and Jammer
%   Detailed explanation goes here

% plot3(xt1,yt1,zt1,xt2,yt2,zt2);
figure();
% plot3(targetlocA(1),targetlocA(2),targetlocA(3),targetlocB(1),targetlocB(2),targetlocB(3),jammerloc(1),jammerloc(2),jammerloc(3));
plot(targetlocA(1),targetlocA(2),'.', 'markersize',20);
hold on;
plot(targetlocB(1),targetlocB(2),'.', 'markersize',20);
hold on; 
plot(jammerloc(1),jammerloc(2),'.', 'markersize',20);
title("Scenario Locations");
yline(0);
xline(0);
xlabel('X (Meters)') ;
ylabel('Y (Meters)') ;
legend('Receiver','Transmitter', 'Jammer');
xlim([-10 130]);
ylim([-130 130]);
grid on 
grid minor

end