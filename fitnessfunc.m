% ------ fitnessfunc.m ------
%
% Tim Pearce - Durham University - 2010

function score = fitnessfunc(pitch)
% -------------------------------------------------------------------------
% for use in genetic algorithm (this is fitness function) -----------------
% pitch = offspring
% increase variable 'score' according to how badly match criteria ---------
% no. variables = no. of notes

global tuningsystem dissenv noteons MicroType ...
                    notefreqcount pjumpfreqcount subtunsyst;

% begin by rounding pitch to a note in tuning system, then work out
% associated dissonance and join with time position in melody
pitch = [pitch]';       % change from row -> col vector
pitch(:,2:4) = zeros;   % fill up matrix

% closest pitch in scale ----
for i=1:size(pitch,1)
  [trash, array_position] = min(abs(subtunsyst(:,2) - pitch(i,1)));
  pitch(i,1) = subtunsyst(array_position,2);
  pitch(i,2) = subtunsyst(array_position,1);
end

% dissonance value ----
for i = 1:size(pitch,1)
  [row,col] = find(tuningsystem(:,1) == pitch(i,2));
  pitch(i,3) = tuningsystem(row,5);
end

% time of note-on ----
pitch(:,4) = noteons(:,1);

% first criteria - check notes according to note probability --------------
% -------------------------------------------------------------------------
% find expected hurt from note picking for the number of notes used
residual1 = [];
% chi-squared/residual method
for i = 1:size(tuningsystem,1)
  [row,col] = find(pitch(:,2) == tuningsystem(i,1));
  obsv = size(row,1)/size(pitch,1);
  expec = notefreqcount(i,2)/sum(notefreqcount(:,2));
  if expec ~= 0
    residual1(i,1) = abs(obsv - expec)^4/expec;
  else
    residual1(i,1) = abs(obsv - expec)^4/0.0001;
  end
end
score1 = 8*sum(residual1(:,1));


% second criteria - check notes according to note jump probability --------
% -------------------------------------------------------------------------
% chi-squared/residual method
score2 = 0;
if MicroType ~= 2   % only enter if scale selected is equal temperament
  residual = [];
  % work out pitch jump size for scale
  jumpsize = tuningsystem(2,2) - tuningsystem(1,2);
  % find actual pitch jumps present
  for i = 2:size(pitch,1)
    jump(i-1,1) = round((pitch(i,1) - pitch(i-1,1))/jumpsize);    
  end

  for i = 1:size(pjumpfreqcount,1)
    [row,col] = find(jump(:,1) == pjumpfreqcount(i,1));
    obsv = size(row,1)/size(jump,1);
    expec = pjumpfreqcount(i,2)/sum(pjumpfreqcount(:,2));
    if expec ~= 0
      residual(i,1) = abs(obsv - expec)^4/expec;
    else
      residual(i,1) = abs(obsv - expec)^4/0.005;
    end
  end

  % incase of rogue pitch jumps (beyond compiled range)
  [row,col] = find(jump(:,1) > max(pjumpfreqcount(:,1))); % if too large
  for i = min(jump(row,1)):max(jump(row,1))
    [row2,col2] = find(jump(:,1) == i);
    obsv = size(row2,1)/size(jump,1);
    residual = [residual; obsv^4/0.0003];      % expec = 0 less likely than in range desired - cld put in factor so further from 0, gets less likely
  end

  % same for if too small
  [row,col] = find(jump(:,1) < min(pjumpfreqcount(:,1))); 
  for i = min(jump(row,1)):max(jump(row,1))
    [row2,col2] = find(jump(:,1) == i);
    obsv = size(row2,1)/size(jump,1);
    residual = [residual; obsv^4/0.0003];      % expec = 0
  end
  score2 = 3*sum(residual(:,1));    % was 0.1
end

% third criteria - check tension level of notes against tension envelope --
% -------------------------------------------------------------------------
score3 = 0;

global test;test = [];
biggest = max(tuningsystem(find(tuningsystem(:,3) == 1),5));

for i = 1:size(dissenv,1)  % cycle through in 1/4 bars
  % find notes in that 1/4 bar
  row = find( (noteons(:,1) >= (i-1)*4) & (noteons(:,1) < (((i-1)*4)+4)) );  
  if isempty(row) == 0  % if have found notes
    % calculate mean dissonance
    avgdis = mean(pitch(row,3));
    % scale avgdis to envelope dissonance
    avgdis = avgdis* 10/biggest;
    
    test = [test; i avgdis];
    
    % check if mean dissonance is different to desired envelope
    if avgdis ~= dissenv(i,2)
      % score is increased by amount proportional to the difference
      score3 = score3 + 0.007 * norm(avgdis - dissenv(i,2));
    end
  end
end


% total score = sum of all components -------------------------------------
% -------------------------------------------------------------------------
% weight of each adjusted by user specified power coefficients
global npow jpow tpow;
score =  (npow*score1) + (jpow*score2) + (tpow*score3);


global scorecounter;                            % #### useful for testing
scorecounter = [scorecounter;score1, score2, score3, score];

