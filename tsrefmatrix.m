% ------ tsrefmatrix.m ------
%
% Tim Pearce - Durham University - 2010

function subtunsyst = tsrefmatrix
% -------------------------------------------------------------------------
% necessary before using gapitch.m
% returns matrix of all notes (in specified tuning system) that exist in 
% allowable range
global tuningsystem; global lowestpitch; global highestpitch; 

k = tuningsystem(1,2) - tuningsystem(size(tuningsystem,1),2);
numoctaves = 1;
while k > 12
  numoctaves = numoctaves + 1;  % finds the number of octaves for a scale
  k = k-12;                     % to repeat
end

% for above
subtunsyst = tuningsystem(:,1:2);
k=1;
while subtunsyst(size(subtunsyst,1),2) < highestpitch   
  subtunsyst = [subtunsyst;...
                tuningsystem(:,1), tuningsystem(:,2)+(numoctaves*12*k)];
  k=k+1;
end

% for below
k=1;
while subtunsyst(size(subtunsyst,1)-size(tuningsystem,1)+1,2) > lowestpitch   
  subtunsyst = [subtunsyst;...
                tuningsystem(:,1), tuningsystem(:,2)-(numoctaves*12*k)];
  k=k+1;
end