data_n2s_w2n = readmatrix('figure_8_n2s_w2n.csv');
data_n2w_w2s = readmatrix('figure_8_n2w_w2s.csv');
data_s2n_n2w = readmatrix('figure_8_s2n_n2w.csv');
data_s2w_n2s = readmatrix('figure_8_s2w_n2s.csv');
data_w2n_s2w = readmatrix('figure_8_w2n_s2w.csv');
data_w2s_s2n = readmatrix('figure_8_w2s_s2n.csv');

data_1 = data_n2s_w2n(:,16) - data_n2s_w2n(:,15);
data_2 = data_n2w_w2s(:,16) - data_n2w_w2s(:,15);
data_2 = [data_2; [0;0]];
data_3 = data_s2n_n2w(:,16) - data_s2n_n2w(:,15);
data_4 = data_s2w_n2s(:,16) - data_s2w_n2s(:,15);
data_4 = [data_4; [0;0]];
data_5 = data_w2n_s2w(:,16) - data_w2n_s2w(:,15);
data_5 = [data_5; [0;0]];
data_6 = data_w2s_s2n(:,16) - data_w2s_s2n(:,15);
data_6 = [data_6; [0;0]];

fig = figure;
% scatter(1:1:50, data_1(:,1),[], '*','r');
plot(1:1:50, data_1(:,1),'r','LineWidth',1.5);
hold on;
% scatter(1:1:50, data_1(:,1),[], '*','b');
plot(1:1:50, data_2(:,1),'b','LineWidth',1.5);
hold on;
% scatter(1:1:50, data_1(:,1),[], '*','g')
plot(1:1:50, data_3(:,1),'g','LineWidth',1.5);
hold on;
% scatter(1:1:50, data_1(:,1),[], '*', 'm')
plot(1:1:50, data_4(:,1),'m','LineWidth',1.5);
hold on;
% scatter(1:1:50, data_1(:,1),[], '*','c')
plot(1:1:50, data_5(:,1),'c','LineWidth',1.5);
hold on;
% scatter(1:1:50, data_1(:,1),[], '*','y')
plot(1:1:50, data_6(:,1),'y','LineWidth',1.5);
hold on;
legend('North to South','North to West', 'South to North','South to West', 'West to North','West to South', 'FontSize', 14)
xlabel("Sample", 'FontSize',16,'FontWeight','bold')
ylabel("SNR Improvement (dB)",'FontSize',16,'FontWeight','bold')
set(fig, 'Color', 'w');
set(gca,'fontsize', 16, 'FontName', 'Times New Roman'); 
ax = gca;
ax.XColor = 'k';
                ax.YColor = 'k';
grid on