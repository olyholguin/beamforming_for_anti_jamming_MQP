function [pathAtoB, pathBtoA, pathJtoA, pathJtoB] = calculateExpected(targetlocA, targetlocB, jammerloc)

[~,pathAtoB] = rangeangle(targetlocA, targetlocB);  % B is looking for A
[~,pathBtoA] = rangeangle(targetlocB, targetlocA);  % A is looking for B
[~,pathJtoA] = rangeangle(jammerloc, targetlocA);   % A is looking for jammer
[~,pathJtoB] = rangeangle(jammerloc, targetlocB);   % B is looking for jammer

end