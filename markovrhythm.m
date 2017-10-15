% ------ markovrhtyhm.m ------
%
% Tim Pearce - Durham University - 2010 

function [noteons] = markovrhythm;

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% generates timings of notes-on (pitches not assigned) for a 2 bar melody
% via Markov process and adjust according to a density envelope
%
% inputs:
% firstnoteon           (time and probabilities of first note in melody)
% firstinterval         (size and prob of first interval in melody)
% transition matrix     (rows = current state, cols = next state)
% density envelope      (1/4 bar bins with values relating to how many 
%                       notes are desired in each)
%
% outputs:
% a vector of times (1/16ths) corresponding to notes being triggered 'on'
%
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


% markov chain ------------------------------------------------------------
% -------------------------------------------------------------------------
% create a note on rhythm structure using transition matrix prev. compiled 
% in a markov process
global transition firstnoteon firstinterval;

% beginning ---------------------------------------------------------------
% to initiate: choose when first note should be & first interval
x = rand;
firstn = 1;             % default value - incase next unassigned below
for i = 1:size(firstnoteon,1)
  % using random number, find where falls in transition matrix
  if x < firstnoteon(i,2)
    firstn = i-1; break;
  end
end

x = rand;
firsti = 1;
for i = 1:size(firstinterval,1)
  % using random number, find where falls in transition matrix
  if x < firstinterval(i,2)
    firsti = i; break;
  end
end

% rhythm generation -------------------------------------------------------
noteons = firstn;       % initiate with calculated first note time
current = firsti;       % initiate with calculated interval
while sum(noteons) < 31 % generate until (over) two bars are completed
  x = rand;
  next = 1;
  for i = 1:size(transition,1)
    % using random number, find where falls in transition matrix
    if x < transition(current,i)
      next = i; break;
    end
  end
  noteons = [noteons; next];
  current = next;
end
noteons = noteons(1:size(noteons,1)-1,:);   % delete last note

% now tally the intervals
for i = 2:size(noteons,1)
  noteons(i) = noteons(i) + noteons(i-1); 
end 


% adjust notes according to the density envelope --------------------------
% -------------------------------------------------------------------------
global densityenv;
       
for i = 1:size(densityenv,1)                    % for each 1/4 bar segment
  for j = ((i-1)*4):2:((i-1)*4) + 3             % step through in 1/16ths
        % if need to reduce the amount of notes
    if densityenv(i,2) < 5 & isempty(find(noteons == j)) == 0
      if densityenv(i,2) < 5* rand          % probability of removing note
        noteons(find(noteons == j),:) = []; % remove note
      end  
    end
        % if need to increase the amount of notes
    if densityenv(i,2) > 5 & isempty(find(noteons == j)) ~= 0
      if densityenv(i,2) > 5* rand +5       % prob to add note
        noteons = [noteons; j];             % add note
      end
    end
  end
end

noteons = sort(noteons);                    % put in chronological order