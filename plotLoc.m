function [] = plotLoc(targetlocA,targetlocB,jammerloc)
%Plots the locations of reciver, transmiter, and Jammer
%   Detailed explanation goes here

% plot3(xt1,yt1,zt1,xt2,yt2,zt2);
% targetlocB =    [24; 0; 0];
% targetlocA =    [-8; -2; 0];
% jammerloc =     [-1; 24; 0];
figure();
% plot3(targetlocA(1),targetlocA(2),targetlocA(3),targetlocB(1),targetlocB(2),targetlocB(3),jammerloc(1),jammerloc(2),jammerloc(3));
plot([-100, -8], [-4, -4],'w', 'LineWidth', 2); % Horizontal bottom
hold on;
plot([-100, -8], [4, 4],'w', 'LineWidth', 2); % Horizontal top
hold on;
plot([-8, -8], [-4, -100],'w', 'LineWidth', 2); % Vertical Bottom
hold on;
plot([-8, -8], [4, 100],'w', 'LineWidth', 2); % Vertical Top
hold on;
plot([0, 0], [100, -100],'w', 'LineWidth', 2);
hold on;
plot([-8 -100], [0 0], 'y--');
hold on;
plot([-4 -4], [100 -100], 'y--');
hold on;
h_targetA = plot(targetlocA(1), targetlocA(2), '.', 'markersize', 20, 'Color','c');
hold on;
h_targetB = plot(targetlocB(1), targetlocB(2), '.', 'markersize', 20, 'Color','g');
hold on;
h_jammer = plot(jammerloc(1), jammerloc(2), '.', 'markersize', 20, 'Color','r');
title("Scenario: Mobile Rx, Stationary Jammer");
% yline(0);
% xline(0);
xlabel('X (Meters)') ;
ylabel('Y (Meters)') ;
legend([h_targetB, h_targetA, h_jammer], 'Cell Tower (Tx)', 'Mobile Car (Rx)', 'Jammer', 'location', 'northwest');
xlim([-70 70]);
ylim([-70 70]);
grid on 
grid minor
ax = gca;
% ax.Color = [0.5 0.5 0.5];
ax.Color = 'k';

end