function [outputArg1,outputArg2] = mapping(inputArg1,inputArg2)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
outputArg1 = inputArg1;
outputArg2 = inputArg2;
matrix_zeros = zeros(204, 9);
for i = 1:97
    matrix_zeros(i, 1) = -101 + i; %A x val
    matrix_zeros(i, 2) = -4; %A y val
    matrix_zeros(i, 3) = 0; %A z val

    matrix_zeros(i, 4) = 0; %B x val
    matrix_zeros(i, 5) = 0; %B y val
    matrix_zeros(i, 6) = 0; %B z val

    matrix_zeros(i, 7) = -1; %J x val
    matrix_zeros(i, 8) = 24; %J y val
    matrix_zeros(i, 9) = 0; %J z val

end
j = 1;
for i = 98:200
    matrix_zeros(i, 1) = -4; %A x val
    matrix_zeros(i, 2) = -4 + j; %A y val
    matrix_zeros(i, 3) = 0; %A z val

    matrix_zeros(i, 4) = 0; %B x val
    matrix_zeros(i, 5) = 0; %B y val
    matrix_zeros(i, 6) = 0; %B z val

    matrix_zeros(i, 7) = -1; %J x val
    matrix_zeros(i, 8) = 24; %J y val
    matrix_zeros(i, 9) = 0; %J z val
    j = j+1;

end

end