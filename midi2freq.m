% ------ midi2freq.m ------
% Copyright (c) Ken Schutte 2009 - http://www.kenschutte.com/midi
%
% adapted (with permission) by Tim Pearce - Durham University - 2010 

function f = midi2freq(m)
% Convert MIDI note number (m=0-127 - but may be non integer) 
% to frequency, f, in Hz 
% (m can also be a vector or matrix)

f = (440/32)*2.^((m-9)/12);
