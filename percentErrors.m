function [runMVDR, total_percent_error] = percentErrors(doas, pathBtoA, azimuth_span, elevation_span)

% Calculates the percent error of the expected and measured DoAs
% Outputs whether or not to perform beamforming

% Azimuth and Elevation Percent Errors
percent_error_1_1 = abs(doas(1,1) - pathBtoA(1,1)) / azimuth_span * 100;
percent_error_2_1 = abs(doas(2,1) - pathBtoA(2,1)) / elevation_span * 100;
total_percent_error = (percent_error_1_1 + percent_error_2_1) / 2;

% Display the result
disp(['Azimuth Angle Percent Error: ', num2str(percent_error_1_1), '%']);
disp(['Elevation Angle Percent Error: ', num2str(percent_error_2_1), '%']);
disp(['Average Angle Percent Error: ', num2str(total_percent_error), '%']);

runMVDR = false;

switch true
    case (total_percent_error > 1500)
        disp('Percent Error Greater than 15%');
        % Run estimateMusic again for beter DOA
        return;
    case (total_percent_error > 1000)
        disp('Percent Error Greater than 10%');
        % Run estimateMusic again for beter DOA 
        return;
    case (total_percent_error > 750)
        disp('Percent Error Greater than 7.5%');
        % Percent Error not perfect, but still run MVDR
        % runMVDR = true;
        return;
    otherwise
        % Will perform MVDR Beamforming in main
        % disp('Running MVDR Script...');
        runMVDR = true;
end
end
