load carsmall
X = [Weight,Horsepower,Acceleration];

mdl = fitlm(X,MPG);

mdl.Coefficients;

anova(mdl,'summary')

plot(mdl)

% New data for prediction
newData = [3000, 150, 10]; % Example: Weight = 3000, Horsepower = 150, Acceleration = 10

% Predict MPG using the fitted model
predictedMPG = predict(mdl, newData);

% Display the predicted MPG
disp(['Predicted MPG: ', num2str(predictedMPG)]);

% save('mdlSave', 'mdl')