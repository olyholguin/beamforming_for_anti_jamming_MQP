function [] = checkNaN(doas)

% checkNan() will stop execution if no DoA is found
doa_NaN = isnan(doas(1,1)) || isnan(doas(2,1));
if(doa_NaN)
    msg = 'No DoA was found';
    error(msg)
end

end
