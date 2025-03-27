filename1 = 'sim_data_w2n_24_Mar_2025_14_37_40.csv';
data1 = readtable(filename1);
filename2 = 'sim_data_s2w_24_Mar_2025_14_40_34.csv';
data2 = readtable(filename2);
filename3 = 'sim_data_n2s_24_Mar_2025_14_39_35.csv';
data3 = readtable(filename3);
%
filename4 = 'sim_data_w2s_24_Mar_2025_14_38_45.csv';
data4 = readtable(filename4);
filename5 = 'sim_data_n2w_24_Mar_2025_14_40_04.csv';
data5 = readtable(filename5);
filename6 = 'sim_data_s2n_24_Mar_2025_14_41_00.csv';
data6 = readtable(filename6);
x_coord = data1.RxLocationX;
x_coord = [x_coord; data2.RxLocationX];
x_coord = [x_coord; data3.RxLocationX];
x_coord = [x_coord; data4.RxLocationX];
x_coord = [x_coord; data5.RxLocationX];
x_coord = [x_coord; data6.RxLocationX];
y_coord = data1.RxLocationY;
y_coord = [y_coord; data2.RxLocationY];
y_coord = [y_coord; data3.RxLocationY];
y_coord = [y_coord; data4.RxLocationY];
y_coord = [y_coord; data5.RxLocationY];
y_coord = [y_coord; data6.RxLocationY];
azimuth_truth = data1.ExpectedAzimuth;
azimuth_truth = [azimuth_truth; data2.ExpectedAzimuth];
azimuth_truth = [azimuth_truth; data3.ExpectedAzimuth];
azimuth_truth = [azimuth_truth; data4.ExpectedAzimuth];
azimuth_truth = [azimuth_truth; data5.ExpectedAzimuth];
azimuth_truth = [azimuth_truth; data6.ExpectedAzimuth];
elevation_truth = data1.ExpectedElevation;
elevation_truth = [elevation_truth; data2.ExpectedElevation];
elevation_truth = [elevation_truth; data3.ExpectedElevation];
elevation_truth = [elevation_truth; data4.ExpectedElevation];
elevation_truth = [elevation_truth; data5.ExpectedElevation];
elevation_truth = [elevation_truth; data6.ExpectedElevation];
X = [x_coord, y_coord];
Y = [azimuth_truth, elevation_truth];
X = [];
Y = [];
num_feature = 3;
for i = 1 : 500
   X(i, :) = azimuth_truth(i:i+num_feature-1);
   Y(i,:) = azimuth_truth(i+num_feature);
end
% Fit the model
mdl = fitlm(X, Y);
% mdl = fitnlm(X, azimuth_truth);
plot(mdl)
% mdl = fitrlinear(X, azimuth_truth);
% mdl = fitrlinear(X, azimuth_truth);
% mdl = fitglm(X,azimuth_truth,'linear','Distribution','poisson');
% mdl = fitglm(X,azimuth_truth,'quadratic',...
        % 'Distribution','binomial');
%Predict DOA using just 1 coordinate
newData = [-50,-2];
newData = X(1,:);
predictedMPG = predict(mdl, newData);
disp(['Predicted Azimuth: ', num2str(predictedMPG)]);
% save('mdlSave', 'mdl');
%%Car Example from MATLAB
% load carsmall
% X = [Weight,Horsepower,Acceleration];
%
% mdl = fitlm(X,MPG);
%
% mdl.Coefficients;
%
% anova(mdl,'summary')
%
% plot(mdl)
%
% % New data for prediction
% newData = [3000, 150, 10]; % Example: Weight = 3000, Horsepower = 150, Acceleration = 10
%
% % Predict MPG using the fitted model
% predictedMPG = predict(mdl, newData);
%
% % Display the predicted MPG
% disp(['Predicted MPG: ', num2str(predictedMPG)]);
%
% % save('mdlSave', 'mdl')
