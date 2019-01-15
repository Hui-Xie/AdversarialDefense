function result = attenuatedSNR(x,y)
% y = a*x +w model, snr = 10log10(power_x/power_w)

Nx = length(x);
Ny = length(y);
% Method3: seek maximum match as the lag record effect, then compute snr
sIsx = false;
if (Ny > Nx)
   s = x; Ns = Nx; %small sample
   b = y; Nb = Ny; %big sample
   sIsx = true;
elseif (Nx > Ny)
   s = y; Ns = Ny;
   b = x; Nb = Nx;
   sIsx = false;
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
       if (sIsx)
           x = s;
           y = c;
       else
           y = s;
           x = c;
       end
       
       xx = norm(x, 2)^2;  %<x,x>
       yy = norm(y, 2)^2;  %<y,y>
       xy = sum(x.*y);    %<x,y> 
       
       a = xy/xx;
       ww = yy - a*a*xx;
       tempSNR = 10*log10(xx/ww);   
      
    end
end
result = tempSNR;

end
