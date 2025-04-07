function [locations] = mapping(cardinal_start, cardinal_end, step)

locations = zeros(1, 9);

targetlocB =    [14; 0; 0];
jammerloc =     [-6; -20; 0];

if strcmp(cardinal_start, 'west')
    for i = -50:step:-6
        new_loc(1, 1) = targetlocB(1);  % Tx x coord
        new_loc(1, 2) = targetlocB(2);  % Tx y coord
        new_loc(1, 3) = targetlocB(3);  % Tx z coord

        new_loc(1, 4) = i;              % Rx x coord
        new_loc(1, 5) = -2;             % Rx y coord
        new_loc(1, 6) = 0;              % Rx z coord

        new_loc(1, 7) = jammerloc(1);   % J x coord
        new_loc(1, 8) = jammerloc(2);   % J y coord
        new_loc(1, 9) = jammerloc(3);   % J z coord

        if sum(locations(1,:)) == 0
            locations = new_loc;
        else
            locations = [locations; new_loc];
        end

    end

elseif strcmp(cardinal_start, 'north')
    for i = 50:(-step):2
        new_loc(1, 1) = targetlocB(1);  % Tx x coord
        new_loc(1, 2) = targetlocB(2);  % Tx y coord
        new_loc(1, 3) = targetlocB(3);  % Tx z coord

        new_loc(1, 4) = -6;              % Rx x coord
        new_loc(1, 5) = i;             % Rx y coord
        new_loc(1, 6) = 0;              % Rx z coord

        new_loc(1, 7) = jammerloc(1);   % J x coord
        new_loc(1, 8) = jammerloc(2);   % J y coord
        new_loc(1, 9) = jammerloc(3);   % J z coord

        if sum(locations(1,:)) == 0
            locations = new_loc;
        else
            locations = [locations; new_loc];
        end
    end
elseif strcmp(cardinal_start, 'south')
    for i = -50:step:-2
        new_loc(1, 1) = targetlocB(1);  % Tx x coord
        new_loc(1, 2) = targetlocB(2);  % Tx y coord
        new_loc(1, 3) = targetlocB(3);  % Tx z coord

        new_loc(1, 4) = -2;              % Rx x coord
        new_loc(1, 5) = i;             % Rx y coord
        new_loc(1, 6) = 0;              % Rx z coord

        new_loc(1, 7) = jammerloc(1);   % J x coord
        new_loc(1, 8) = jammerloc(2);   % J y coord
        new_loc(1, 9) = jammerloc(3);   % J z coord

        if sum(locations(1,:)) == 0
            locations = new_loc;
        else
            locations = [locations; new_loc];
        end
    end
end

if strcmp(cardinal_end, 'north')
    for i = 2:step:50
        new_loc(1, 1) = targetlocB(1);  % Tx x coord
        new_loc(1, 2) = targetlocB(2);  % Tx y coord
        new_loc(1, 3) = targetlocB(3);  % Tx z coord

        new_loc(1, 4) = -2;             % Rx x coord
        new_loc(1, 5) = i;              % Rx y coord
        new_loc(1, 6) = 0;              % Rx z coord

        new_loc(1, 7) = jammerloc(1);    % J x coord
        new_loc(1, 8) = jammerloc(2);    % J y coord
        new_loc(1, 9) = jammerloc(3);    % J z coord

        locations = [locations; new_loc];
    end
elseif strcmp(cardinal_end, 'south')
    for i = -2:(-step):-50
        new_loc(1, 1) = targetlocB(1);  % Tx x coord
        new_loc(1, 2) = targetlocB(2);  % Tx y coord
        new_loc(1, 3) = targetlocB(3);  % Tx z coord

        new_loc(1, 4) = -6;             % Rx x coord
        new_loc(1, 5) = i;              % Rx y coord
        new_loc(1, 6) = 0;              % Rx z coord

        new_loc(1, 7) = jammerloc(1);    % J x coord
        new_loc(1, 8) = jammerloc(2);    % J y coord
        new_loc(1, 9) = jammerloc(3);    % J z coord

        locations = [locations; new_loc];
    end
elseif strcmp(cardinal_end, 'west')
    for i = -6:(-step):-50
        new_loc(1, 1) = targetlocB(1);  % Tx x coord
        new_loc(1, 2) = targetlocB(2);  % Tx y coord
        new_loc(1, 3) = targetlocB(3);  % Tx z coord

        new_loc(1, 4) = i;             % Rx x coord
        new_loc(1, 5) = 2;              % Rx y coord
        new_loc(1, 6) = 0;              % Rx z coord

        new_loc(1, 7) = jammerloc(1);    % J x coord
        new_loc(1, 8) = jammerloc(2);    % J y coord
        new_loc(1, 9) = jammerloc(3);    % J z coord

        locations = [locations; new_loc];
    end
end

end