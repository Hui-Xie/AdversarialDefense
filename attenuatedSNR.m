function result = attenuatedSNR(x,y)
% method1: compute attenuated SNR with first computing attenuation
% y = a*x+ w
% assume w is zero-mean noise vector, a is the attenuated factor;
%        x,y are column vector
% a = sum(y.*x)/norm(x,2)^2 
% w = y - a*x;
% attenuatedSNR = snr(x, w);

% first make sure x and y has same length
Nx = length(x);
Ny = length(y);
Nmax = max(Nx,Ny);
% if (Ny > Nx)
%    x = wextend('ar','zpd',x, (Nmax-Nx)/2 );
% end
% 
% if (Nx > Ny)
%    y = wextend('ar','zpd',y, (Nmax-Ny)/2);
% end

% a = sum(y.* x)/ (norm(x,2)^2);
% w = y - a*x;
% result = snr(y,w);


% method2: compute attenuated SNR by first using xcorr to shift signal
% if (Ny > Nx)
%    y = y(1:Nx);
% end
%  
% if (Nx > Ny)
%    x = x(1:Ny);
% end 
% 
% [r,lags] = xcorr(x, y);
% [~, maxPos] = max(r);
% y = circshift(y, lags(maxPos));
% w = y -x;
% result = snr(x, w);

% Method3: seek maximum match as the lag record effect, then compute snr
if (Ny > Nx)
   s = x; Ns = Nx; %small sample
   b = y; Nb = Ny; %big sample
elseif (Nx > Ny)
   s = y; Ns = Ny;
   b = x; Nb = Nx;
else
   w = y-x;
   result = snr(x,w);
   return;
end 

maxCorr = -1;
tempSNR = 0;
for i=0: Nb-Ns
    c = b(i+1:i+Ns); % the comparing portion
    corrMatrix = corrcoef(c, s);
    corr = corrMatrix(1,2);
    if corr > maxCorr
       maxCorr = corr;
       w = s - c;
       tempSNR = snr(s,w);
    end
end
result = tempSNR;

end
