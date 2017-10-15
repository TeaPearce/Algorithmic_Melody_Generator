% ------ libraryanalysis.m ------
%
% Tim Pearce - Durham University - 2010 

function [notefreqcount, pjumpfreqcount...
          transition, firstnoteon, firstinterval] = libraryanalysis

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% inputs:
% a hoard of midi files in a sub-folder
% 
% outputs:
% returns matrix of note and pitch jump occurrence distributions and 
% transition matrix (for note rhythms). Also matrices of info regarding
% timing of first note (to initiate later Markov process)
% 
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

% name of subfolder in directory w/ .mid files
subfol = 'library\';
list = dir(fullfile(subfol,'*.mid'));       % lists all the .mid file names

global grand;
grand = [];                                 % main matrix

for i = 1:size(list)                        % open each midi file in turn
  % get note information for each midi file
  [midmat,endtime] = midiInfo(readmidi([cd, '\', subfol,list(i).name]),0); 
  
  midmat(:,5:6) = round(midmat(:,5:6));     % quantizes note on/off
  endtime = ceil(endtime);                  % rounds up endtime

  grand = [grand;... 
           midmat(:,3)...                   % midi note no.
           midmat(:,5)...                   % 1/16th note on
           zeros(size(midmat,1),1)];    % midi note no. 1-12 (workoutlater)
end


% work out the unfinished columns of grand
global MicroType;
if MicroType == 0       % only bother working out if 12-TET
  for i = 1:size(grand,1)
    % calc. midi note no. 1-12
    m = 0; L = 12;     % convert from midi no. to 1-12 (c is 1, b is 12)
    while L>=12
      L = grand(i,1) - m;
      m = m + 12;
    end
    grand(i,3) = L+1;
  end
end


% ONLY DO IF MICROTONAL SCALE NOT SELECTED
% cumulative freq. of each note - - - - - - - - - - - - - - - - - - - - - -
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
global notefreqcount pjumpfreqcount;
if MicroType == 0       % only if 12-TET
  notefreqcount = [];
  for i = 1:12
   row = find(grand(:,3) == i);
   notefreqcount = [notefreqcount; i, size(row,1)];
  end
end
% could adjust here for those notes only found in maj or min scale (if
% library contains more of one type)

% ONLY DO IF MICROTONAL SCALE NOT SELECTED
% cumulative freq. of each pitch jump - - - - - - - - - - - - - - - - - - -
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% first find pitch jump for each interval
if MicroType == 0       % only if 12-TET
  pj = [];
  for i = 2:size(grand,1) % for all potential intervals
    % check for if note is first of song   
    if grand(i,2)>grand(i-1,2)   % if later than last note
      pj = [pj; grand(i,1)-grand(i-1,1)];% save as pitchjump from last note
    end
  end

  % now count how many times each pitch jump occurs
  pjumpfreqcount = [];         
  for i = min(pj):max(pj)
    [row,col] = find(pj(:,1) == i);
    pjumpfreqcount = [pjumpfreqcount; i, size(row,1)];
  end
end

% transition matrix - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% compile transition matrix for use in Markov process to create note rhythm
% structure. Also compile information for the first note of melodies
%
% for each note interval, must look at what each note separation is, and 
% then the proceeding division size. add each instance to cumulative
% counter (effectively transition probability matrix)
% 
% transition matrix has current states in rows, and next state in cols
% states go up in 1/16 graduations

maxint = 16;                    % max gap recognised by transition matrix
transition = zeros(99, 99);     % make excessively big at first
% matrices to do with first note
fno = []; fi = [];                      % preliminary matrices
firstinterval = []; firstnoteon = [];   % actual matrices


currentint = grand(2,2) - grand(1,2);       % for first interval
for i = 3:size(grand,1) % for all potential intervals
  % check for if note is first of song (time on is earlier than prev note)
  if grand(i,2)>=grand(i-1,2)   % if not first note in song 
      nextint = grand(i,2) - grand(i-1,2);
      if nextint ~= 0 &&  currentint ~= 0  % as long as 2 notes not at once
     transition(currentint, nextint) = transition(currentint, nextint) + 1;
      end
      currentint = nextint; % old becomes new for next iteration
  else                          % if first note in song
    fno = [fno; grand(i,2)];                % store time of first note on
    currentint = grand(i+1,2) - grand(i,2);
    fi = [fi; currentint];                  % store first time interval
    i = i+1;                    % fast-forward a step
  end
end


% order the 'first note timing' - - - - - - - - - - - - - - - - - - - - - -
for i = 0:max(fno)
  amount = find(fno(:,1)==i);
  firstnoteon = [firstnoteon; i, size(amount,1)];
end
% now must make so the column totals to one (as for transition matrix)
total = sum(firstnoteon(:,2));
firstnoteon(:,2) = firstnoteon(:,2)/total;
for i = 2: size(firstnoteon,1) % this orders row values so -> 1.0
  firstnoteon(i,2) = firstnoteon(i-1,2) + firstnoteon(i,2);
end

% order the 'first note interval' - - - - - - - - - - - - - - - - - - - - -
for i = 1:max(fi)
  amount = find(fi(:,1)==i);
  firstinterval = [firstinterval; i, size(amount,1)];
end
% ignore intervals greater than maxint
firstinterval = firstinterval(1:maxint,:);                                  %##### take out for tests ###############
% now must make so the column totals to one
total = sum(firstinterval(:,2));
firstinterval(:,2) = firstinterval(:,2)/total;
for i = 2: size(firstinterval,1) % this orders row values so -> 1.0
  firstinterval(i,2) = firstinterval(i-1,2) + firstinterval(i,2);
end


% order the 'transition matrix' - - - - - - - - - - - - - - - - - - - - - -
% ignore intervals greater than maxint
transition = transition(1:maxint,1:maxint); 
% now must make so each row in transition totals to 1
for i = 1:size(transition,1)
  total = sum(transition(i,:));
  if total ~= 0         % this avoids NaN's
    transition(i,:) = transition(i,:)/total;
  end
  for j = 2: size(transition,2) % this orders row values so -> 1.0
    transition(i,j) = transition(i,j-1) + transition(i,j);
  end
end