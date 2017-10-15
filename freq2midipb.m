% ------ freq2midipb.m ------
%
% Tim Pearce - Durham University - 2010

function [m, msb, lsb] = freq2midipb(f)

% Convert frequency, f, in Hz to MIDI note number (m=0-127) and values to 
% bend by (if required) to achieve freq (f can also be a vector or matrix)
% Make sure pitch bend range on synth is set to +/- 2 semitones
% if not, then can alter line 15 (4096 = 1683/(PBR*2))
%
% returns [integer MIDI note, most sig. bend byte, least sig. bend byte]

m = 69 + 12*log2(f/440);             % finds closest midi value
difference = round(m) - m;           % find dif. between closest 12-TET 
                                     % freq and actual desired  freq (Hz)
decvalue = round(8192 - (difference * 4096));   % = 14bit dec must bend by

% convert to two 7 bit decimal numbers
msb = bitshift(decvalue, -7);           % Most Significant Bit
lsb = decvalue - (msb*(2^7));           % Least Significant Bit

m=round(m);                             % nearest whole midi note
