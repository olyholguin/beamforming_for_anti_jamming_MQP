function helperPlotMIMOEnvironment(gc, tp)
% This function is only in support of MIMOBeamformingExample.
% It may be removed in a future release.

% Copyright 2014-2016 The MathWorks, Inc.


% Antenna definition
ula = phased.ULA( tp.numTXElements, ...
        'ElementSpacing', 0.5*gc.lambda, ...
        'Element', phased.IsotropicAntennaElement('BackBaffled', true));

steeringvec = ...
    phased.SteeringVector('SensorArray',ula,'PropagationSpeed',gc.cLight);

arrayresp = phased.ArrayResponse('SensorArray',ula,'WeightsInputPort',true);


% Steer the transmitter main lobe
wT = steeringvec(gc.fc,[tp.steeringAngle;0]);

% Get array response for visualization
arrayResponse = arrayresp(gc.fc,gc.scanAz,wT);

max_rho = 5e3;

tgt_r = tp.mobileRange;
tgt_th = tp.mobileAngle(1);
int_r = tp.interfRange;
int_th = tp.interfAngle(1);


set(gcf,'Position',gc.envPlotPosition);
hNull = polar(pi, 2* max_rho, 'sw');
hPlotAxes = get(hNull, 'Parent');

hold(hPlotAxes, 'on')
hTarget = polar(degtorad(tgt_th), tgt_r, 'sg');
set(hTarget, 'MarkerFaceColor', 'r')

hInterferer = polar(degtorad(int_th), int_r, 'or');
set(hInterferer, 'MarkerFaceColor', 'b')

hTxArray = polar(degtorad(gc.scanAz(:)),abs(arrayResponse(:))*max_rho/4, '-m');
hold(hPlotAxes, 'off')

legend([hTxArray,hTarget,hInterferer],...
    'Tx Array Response Pattern','Receiver','Interference', ...
    'Location','northeastoutside');


