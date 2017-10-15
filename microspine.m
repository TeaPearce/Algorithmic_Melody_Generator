% ------ microspine.m ------
%
% Tim Pearce - Durham University - 2010
% 
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% creates MIDI file of an algorithmically composed (2 bar) melody 
%
% a.
% user specifies parameters for the melody - tuning system, density
% envelope, tension envelope, range selection, G.A. coefficients. Also 
% dependent on scale needs note occurrence and pitch jump occurrence
% distributions
% 
% b.
% generates a series of 1/16 bars for note on's. via a Markov process by
% analysing sub folder (/library) containing midi melodies. Then alters 
% this according to density envelope
%
% c.
% assigns pitches to this rhthym structure using a genetic algorithm - uses
% fitness fcn utilising: tension envelope and note/pitch interval
% occurence distributions
%
% d.
% converts the midi matrix to a MIDI file and saves
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Inputs:
% 
% user specified parameters and envelopes
% a collection of MIDI files in a sub-folder named 'library'
% 
% outputs:
% for each midi file, a matrix of the follwoing form is compiled:
%
% other files required in working directory (or otherwise):
%
%   microspine.m (this)
%   midi2freq.m
%   freq2diss.m
%   libraryanalysis.m
%   readmidi.m
%   midiInfo.m
%   getTempoChanges.m
%   markovrhythm.m
%   tsrefmatrix.m
%   pitchassign.m
%   fitnessfunc.m
%   freq2midipb.m
%   matrix2midi.m
%   writemidi.m
%
%   also need a subfolder named 'library' with *.mid files
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
clear all;
% =========================================================================
% USER INPUT REQUIRED
% =========================================================================

% specify tuning system/scale ---------------------------------------------
% -------------------------------------------------------------------------
% first column = order of tones
% second column = midi note number (doesnt have to be integers)
% third column = specify which notes to use in scale
% where: 0 = not in scale, 1 = used in scale (e.g. major/minor)
% N.B. first row value is taken as the tonic (root) note
% micro assigns what type of scale is used so programme runs correct
% functions.
% 0 = 12-TET            includes all functions
% 1 = N-TET             requires manual input of distrubutions
% 2 = unequal tempered  req. manual note prob dist, and doesnt use pitch j
global tuningsystem MicroType;

%{
MicroType = 0;
% midi no. of each note in scale                
tuningsystem =   [...           %12-tet          
   1     2     3     4     5     6     7     8     9    10    11    12;...
  60    61    62    63    64    65    66    67    68    69    70    71;...
   1     0     1     1     0     1     0     1     1     0     1     0]';
%   c    c#    d     eb    e     f     f#    g     ab    a     Bb    B
%}

%
MicroType = 1;
tuningsystem =   [...           % 19-tet
  1  2  3  4  5  6  7  8  9 10 11 12 13  14  15  16  17  18  19;...
 60.0  60.63  61.26  61.89  62.53  63.16  63.78  64.42  65.05 65.68 ...
 66.31  66.94 67.57 68.21   68.84   69.47  70.10   70.73   71.36;...
  1  0  1  1  0  1  1  0  0  1  0  0  1   0   1   0   0   0   1]';
%}

%{
MicroType = 1;
tuningsystem =     [1   60      1   % 24-tet system 
                    2   60.5    0
                    3   61      0
                    4   61.5    0
                    5   62      1
                    6   62.5    0
                    7   63      1
                    8   63.5    0
                    9   64      0
                    10  64.5    0
                    11  65      1
                    12  65.5    0
                    13  66      0
                    14  66.5    0
                    15  67      1
                    16  67.5    0
                    17  68      1
                    18  68.5    0
                    19  69      0
                    20  69.5    0
                    21  70      1
                    22  70.5    0
                    23  71      0
                    24  71.5    0];
%}
                      
% note occurrence distribution --------------------------------------------
% -------------------------------------------------------------------------
% user can input this manually if a microtonal scale selected, otherwise
% compile in libraryanalysis.m
global notefreqcount; 
if MicroType ~= 0   % only manually input if microtonal scale selected
  %
  notefreqcount = [...
     1  2  3  4  5  6  7  8  9  10  11  12  13  14  15  16  17  18  19;...
   100 10 20 50 70 50  70 5 60  20  10  70  30   5  20   5  10  30  10]';
%}
  %{
  notefreqcount = [ 1,  100 
                    2,  2
                    3,  2
                    4,  20
                    5,  70
                    6,  20
                    7,  60
                    8,  5
                    9,  60
                   10,  3
                   11,  50
                   12,  2
                   13,  3
                   14,  5
                   15,  80
                   16,  2
                   17,  10
                   18,  30
                   19,  50
                   20,  30
                   21,  15
                   22,  10
                   23,  2
                   24,  2  ];
%}
end


% interval occurrence distribution-----------------------------------------
% -------------------------------------------------------------------------
% user can input this manually if a microtonal scale selected, otherwise
% compile in libraryanalysis.m
global pjumpfreqcount;
if MicroType ~= 0   % if microtonal scale selected
  %
  pjumpfreqcount =[...             
   0  1  2  3  4  5  6  7  8  9 10 11 12 13  14  15  16  17  18  19;...
 100 20 30 40 30 28 26 20 18 50 30 20 40 15  10   8   8   5   2  10]';
%}
    %{
  pjumpfreqcount =[ 0,      100
                    1,      2      
                    2,      2
                    3,      4
                    4,      40
                    5,      35
                    6,      34
                    7,      30
                    8,      25
                    9,      20
                   10,      15
                   11,      2
                   12,      3
                   13,      13
                   14,      25
                   15,      13
                   16,      8
                   17,      5
                   18,      2
                   19,      2
                   20,      2
                   21,      2
                   22,      2
                   23,      2
                   24,      20];
            %}

  % mirror pitch jumps & quantities for -ve pitch jumps
  pjumpfreqcount = [flipud(pjumpfreqcount(2:size(pjumpfreqcount,1),:));...
                    pjumpfreqcount];
  pjumpfreqcount(1:floor(size(pjumpfreqcount,1)/2),1) = ...
                    -pjumpfreqcount(1:floor(size(pjumpfreqcount,1)/2),1);
end


% density envelope --------------------------------------------------------
% -------------------------------------------------------------------------
% sets how the number (density) of notes changes over the (2 bar) melody
% each row represents a 1/4 bar as indicated by the first column
% values must be between 10.0 (lots of notes) and 0.0 (few notes)
global densityenv;
densityenv =  [...   
     1     2     3     4     5     6     7     8;...
     7     7     7     7     7     7     7     7]';

        
% tension envelope --------------------------------------------------------
% -------------------------------------------------------------------------
% sets how the tension level of the melody varies over the 2 bars
% each row represents a 1/4 bar as indicated by the first column
% values must be between 10.0 (very dissonant) and 0.0 (very consonant)
% 10.0 corresponds to most dissonant out of notes allowed
global dissenv; 
dissenv =  [...   
     1     2     3     4     5     6     7     8;...
     6     6     4     4     6     6     4     4]';
            

% range selection ---------------------------------------------------------
% -------------------------------------------------------------------------
% sets the maximum and minimum pitches that are allowed to be considered 
% in generation
global lowestpitch highestpitch;
lowestpitch = 58;
highestpitch = 73;

% Genetic Algorithm power coeff. ------------------------------------------
% -------------------------------------------------------------------------
% vary the (relative) effect of each criteria in fitness function
% values may be as large as desired, set as zero to negate the criteria
global tpow npow jpow; 
npow = 5; % larger value = a closer match to note prob distribution
jpow = 2; % larger value = a closer match to note pitch jump distribution
tpow = 0; % larger value = a closer match to desired tension envelope
% N.B. by increasing the value of one criteria, the influence of all others
% are effectively reduced

% =========================================================================
% USER INPUT COMPLETE
% could add in some checks here to verify data is input correctly
% =========================================================================



% 1. compile information for tuning sytem selected ------------------------
% -------------------------------------------------------------------------
% calc. frequency(Hz) of MIDI notes
tuningsystem(:,4) = midi2freq(tuningsystem(:,2));  

% calc. dissonance(arbitary scale) of frequencies (compared to root freq.)
tuningsystem(:,5) = freq2diss(tuningsystem(:,4)); 


% 2. collect information from melody library ------------------------------
% -------------------------------------------------------------------------
% call the library analyser to compile; note freq. count, pitch jump
% freq. count, and rhythm transition matrix
global transition firstnoteon firstinterval;
[notefreqcount, pjumpfreqcount...
        transition, firstnoteon, firstinterval] = libraryanalysis;


% 3. create rhythm structure ----------------------------------------------
% -------------------------------------------------------------------------
% returns note-on structure (1/16ths) for 2 bars using a markov chain
global noteons;
noteons = markovrhythm;


% 4. pitch assignment -----------------------------------------------------
% -------------------------------------------------------------------------
% assigns pitches to the note-on structure using a genetic algorithm
notepitches = pitchassign;


% 5. output midi file -----------------------------------------------------
% -------------------------------------------------------------------------
% convert to midi matrix form as recognised by 'writemidi.m'  
M = zeros(size(noteons,1),8);       % create matrix
M(:,1) = 1;                         % all in track 1
M(:,2) = 1;                         % all in channel 1
M(:,3) = notepitches(:,1);          % note midi pitch (may be non-integer)
M(:,4) = 100;                       % velocity   (all = 100)
M(:,5) = noteons(:,1)/8;            % time note on (seconds @120bpm)
M(:,6) = (noteons(:,1)+1)/8;        % time note off (duration = 1/16th)
% round midi pitch and add pitch bend:
[M(:,3), M(:,7), M(:,8)] = freq2midipb(midi2freq(M(:,3)));

M   % print info in command window for the MIDI file

savefilename = 'midiout.mid';
midi_new = matrix2midi(M);          % convert to saveable form
writemidi(midi_new, savefilename);  % save midi file
