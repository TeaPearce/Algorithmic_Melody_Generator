% ------ freq2diss.m ------
%
% William Sethares - http://eceserv0.ece.wisc.edu/~sethares/comprog.html
%
% adapted (with permission) by Tim Pearce - Durham University - 2010 

function diss = freq2diss(freq)

% given a frequency(Hz), returns dissonances relative to first freq in the
% vector

% first specify harmonic content of a standard timbre
basefreq = freq(1,1)*[1 2 3 4 5 6];     % all dissonances relative to first 
                                        % note in vector
amp = ones(size(basefreq)); 
for i = 1:size(basefreq,2)
  amp(1,i) = amp(1,i)*(0.88^(i-1));     % give amplitude of harmonics a 
end                                     % decay rate of 0.88

for i = 1:size(freq,1)
  % base frequency, compared to new freq.
  f = [basefreq, freq(i,1)*[1 2 3 4 5 6]]; 
  a = [amp, amp];
  
  % returns dissonance value for freq compared to ratio*freq
  diss(i,1) = dissmeasure(f, a);
end


function d=dissmeasure(fvec,amp) 

% given a set of partials in fvec, 
% with amplitudes in amp, 
% this routine calculates the dissonance 

Dstar=0.24; S1=0.0207; S2=18.96; C1=5; C2=-5;
A1=-3.51; A2=-5.75; firstpass=1;
N=length(fvec); % no. harmonics
[fvec,ind]=sort(fvec);
ams=amp(ind);
D=0;
for i=2:N  % no. of harmonics add
  Fmin=fvec(1:N-i+1);
  S=Dstar./(S1*Fmin+S2);
  Fdif=fvec(i:N)-fvec(1:N-i+1);
  a=min(ams(i:N),ams(1:N-i+1));
  Dnew=a.*(C1*exp(A1*S.*Fdif)+C2*exp(A2*S.*Fdif));
  D=D+Dnew*ones(size(Dnew))';
end
d=D;