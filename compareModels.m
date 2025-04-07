data_mdl = readmatrix('sim_data_w2n_01_Apr_2025_14_01_59.csv');
data_svm = readmatrix('sim_data_w2n_04_Apr_2025_15_46_37.csv');
figure;
subplot(2,1,1)
scatter(1:1:48, data_mdl(:,15),[], '*','b')
hold on;
scatter(1:1:48, data_mdl(:,16),[], 'o', 'r')
legend('Before MVDR','After MVDR')
xlabel("Time")
ylabel("SNR (dB)")
title('MDL')
subplot(2,1,2)
scatter(1:1:48, data_svm(:,15),[], '*','b')
hold on;
scatter(1:1:48, data_svm(:,16),[], 'o', 'r')
legend('Before MVDR','After MVDR')
xlabel("Time")
ylabel("SNR (dB)")
title('SVM')
