function [x,mn,mx] = mel_scale(p,n,fs,fl,fh,w)
%  
%  Determine matrix for a mel-spaced filterbank 
%
%  Inputs:   p   number of filters in filterbank
%            n   length of fft
%            fs  sample rate in Hz
%            fl  low end of the lowest filter as a fraction of fs (default = 0)
%            fh  high end of highest filter as a fraction of fs (default = 0.5)
%            w   any sensible combination of the following:
%                't'  triangular shaped filters in mel domain (default)
%                'n'  hanning shaped filters in mel domain
%                'm'  hamming shaped filters in mel domain
%
%                'z'  highest and lowest filters taper down to zero (default)
%                'y'  lowest filter remains at 1 down to 0 frequency and
%                     highest filter remains at 1 up to nyquist freqency
%
%                If 'ty' or 'ny' is specified, the total power in the FFT 
%                is preserved.
%
%  Outputs:  x   sparse matrix containing the filterbank amplitudes
%                If x is the only output argument then 
%                  size(x)=[p,1+floor(n/2)]
%                otherwise 
%                  size(x)=[p,mx-mn+1]
%            mn  the lowest fft bin with a non-zero coefficient
%            mx  the highest fft bin with a non-zero coefficient

if nargin < 6
  w='tz';
  if nargin < 5
    fh=0.5;
    if nargin < 4
      fl=0;
    end
  end
end
f0=700/fs;
%f0=1000/fs;
fn2=floor(n/2);
lr=log((f0+fh)/(f0+fl))/(p+1);
% convert to fft bin numbers with 0 for DC term
bl=n*((f0+fl)*exp([0 1 p p+1]*lr)-f0);
b2=ceil(bl(2));
b3=floor(bl(3));
if any(w=='y')
  pf=log((f0+(b2:b3)/n)/(f0+fl))/lr;
  fp=floor(pf);
  r=[ones(1,b2) fp fp+1 p*ones(1,fn2-b3)];
  c=[1:b3+1 b2+1:fn2+1];
  v=2*[0.5 ones(1,b2-1) 1-pf+fp pf-fp ones(1,fn2-b3-1) 0.5];
  mn=1;
  mx=fn2+1;
else
  b1=floor(bl(1))+1;
  b4=min(fn2,ceil(bl(4)))-1;
  pf=log((f0+(b1:b4)/n)/(f0+fl))/lr;
  fp=floor(pf);
  pm=pf-fp;
  k2=b2-b1+1;
  k3=b3-b1+1;
  k4=b4-b1+1;
  r=[fp(k2:k4) 1+fp(1:k3)];
  c=[k2:k4 1:k3];
  v=2*[1-pm(k2:k4) pm(1:k3)];
  mn=b1+1;
  mx=b4+1;
end
if any(w=='n')
  v=1-cos(v*pi/2);
elseif any(w=='m')
  v=1-0.92/1.08*cos(v*pi/2);
end
if nargout > 1
  x=sparse(r,c,v);
else
  x=sparse(r,c+mn-1,v,p,1+fn2);
end
