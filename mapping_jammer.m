function locations = mapping_jammer(cardinal_start, cardinal_end, step, locations)

jam_loc = zeros(1, 3);

% Starting
if strcmp(cardinal_start, 'west')
    for i = -50:step:-6
        new_loc(1, 1) = i;      % J x coord
        new_loc(1, 2) = -2;     % J y coord
        new_loc(1, 3) = 0;      % J z coord

        if sum(jam_loc(1,:)) == 0
            jam_loc = new_loc;
        else
            jam_loc = [jam_loc; new_loc];
        end
    end
elseif strcmp(cardinal_start, 'north')
    for i = 50:(-step):2
        new_loc(1, 1) = -6;     % J x coord
        new_loc(1, 2) = i;      % J y coord
        new_loc(1, 3) = 0;      % J z coord

        if sum(jam_loc(1,:)) == 0
            jam_loc = new_loc;
        else
            jam_loc = [jam_loc; new_loc];
        end
    end
elseif strcmp(cardinal_start, 'south')
    for i = -50:step:-2
        new_loc(1, 1) = -2;   % J x coord
        new_loc(1, 2) = i;   % J y coord
        new_loc(1, 3) = 0;   % J z coord

        if sum(jam_loc(1,:)) == 0
            jam_loc = new_loc;
        else
            jam_loc = [jam_loc; new_loc];
        end
    end
end

% Ending

if strcmp(cardinal_end, 'north')
    for i = 2:step:50
        new_loc(1, 1) = -2;     % J x coord
        new_loc(1, 2) = i;      % J y coord
        new_loc(1, 3) = 0;      % J z coord

        jam_loc = [jam_loc; new_loc];
    end
elseif strcmp(cardinal_end, 'south')
    for i = -2:(-step):-50
        new_loc(1, 1) = -6;     % J x coord
        new_loc(1, 2) = i;      % J y coord
        new_loc(1, 3) = 0;      % J z coord

        jam_loc = [jam_loc; new_loc];
    end
elseif strcmp(cardinal_end, 'west')
    for i = -6:(-step):-50
        new_loc(1, 1) = i;      % J x coord
        new_loc(1, 2) = 2;      % J y coord
        new_loc(1, 3) = 0;      % J z coord

        jam_loc = [jam_loc; new_loc];
    end
end

if length(locations) < length(jam_loc)
    jam_loc = jam_loc(1:length(locations),:);
elseif length(locations) > length(jam_loc)
    len = length(jam_loc);
    while length(locations) ~= length(jam_loc)
        jam_loc = [jam_loc; jam_loc(len,:)];
    end
end

locations(:,7) = jam_loc(:,1);
locations(:,8) = jam_loc(:,2);
locations(:,9) = jam_loc(:,3);

end