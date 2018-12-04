function result = Xcorrelation(waveFile1, waveFile2)
% return the maximum of cross correlation of two wav files
[waveData1,sRate1] = audioread(waveFile1);
N1 = length(waveData1);

[waveData2,sRate2] = audioread(waveFile2);
N2 = length(waveData2);

if (sRate1 ~= sRate2)
   fprintf('Sample rates are different between %s and %s', waveFile1,waveFile2); 
end
minN = min(N1, N2);
wave1Sample = waveData1(1: minN);
wave2Sample = waveData2(1: minN);
[r,lags] = xcorr(wave1Sample, wave2Sample);
[~, maxPos] = max(r);
wave2Sample = circshift(wave2Sample, lags(maxPos));
corr = corrcoef(wave1Sample, wave2Sample);
result = corr(1,2);
return;

end