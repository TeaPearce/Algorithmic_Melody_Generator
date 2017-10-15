% ------ pitchassign.m ------
%
% Tim Pearce - Durham University - 2010

function notepitches = pitchassign
% -------------------------------------------------------------------------
% sets up options for genetic algorithm and then calls it

global noteons lowestpitch highestpitch;

gmax = 1000;                    % max number of generations
scale = 4; shrink = 0.8;        % mutation parameters
nvars = size(noteons,1);        % no. of variables = no. of notes
LB(1:nvars,1) = lowestpitch;    % lower and upper bounds for variables
UB(1:nvars,1) = highestpitch;  

global subtunsyst;
subtunsyst = tsrefmatrix;       % need to compile this for fitness fncn

% generate initial population - random values within center of pitch band
initialpop(1:size(noteons,1),1) = zeros;
for i = 1:size(initialpop,1)
  x = rand*(highestpitch - lowestpitch)/2 + ...
                        lowestpitch + (highestpitch - lowestpitch)/4;
  % find closest note in tuning system to random number
  [trash, array_position] = min(abs(subtunsyst(:,2) - x));
  initialpop(i,1) = subtunsyst(array_position,2);
end
initialpop = [initialpop]';     % change from row -> col vector


% put above selections into options
options = gaoptimset('Generations',gmax,'MutationFcn', ...  % std options
    {@mutationgaussian, scale, shrink},...
    'InitialPopulation',initialpop  ); %,...
 %  'PlotFcns',{@gaplotbestf,@gaplotbestindiv,@gaplotexpectation,@gaplotstopping});
 
 
% before entering G.A. adjust the note occurrence distribution according to
% which notes have been selected for use in the tuning system
global tuningsystem notefreqcount;
[row,col] = find(tuningsystem(:,3) == 0);
%notefreqcount(row,2) = 0;

global scorecounter;                              % #### useful for testing
scorecounter = [];                                % ####

% call the g.a. - fitness assessment performed by pitchassign.m
[notepitches, fval] = ga(@fitnessfunc,nvars,[],[],[],[],LB,UB,[],options);
% where fval = fitness function score
notepitches = [notepitches]';   % change from row -> col vector

% must round notes to nearest in scale again
for i=1:size(notepitches,1)
  [trash, array_position] = min(abs(subtunsyst(:,2) - notepitches(i,1)));
  notepitches(i,1) = subtunsyst(array_position,2);
end


% diss tests ####
fitnessfunc([notepitches]');
global test; global testsave;
testsave = [testsave; test];




