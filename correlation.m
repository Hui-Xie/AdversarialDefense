function result = correlation(waveFile1, waveFile2)
% Compute correlation coefficient of 2 wave file;
[waveData1,sRate1] = audioread(waveFile1);
N1 = length(waveData1);

[waveData2,sRate2] = audioread(waveFile2);
N2 = length(waveData2);

if (sRate1 ~= sRate2)
   fprintf('Sample rates are different between %s and %s', waveFile1,waveFile2); 
end
minN = min(N1, N2);
sampleN = round(minN*0.1);
sampleIndex = round(sort(rand(sampleN, 1)).* minN);
sampleIndex(sampleIndex ==0) = [];  % delete all zeros in the index 
wave1Sample = waveData1(sampleIndex,1);
wave2Sample = waveData2(sampleIndex,1);
corr = corrcoef(wave1Sample, wave2Sample);
result = corr(1,2);
return;

end

