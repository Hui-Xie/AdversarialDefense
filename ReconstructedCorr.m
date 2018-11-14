% compute the correlation coeficient of reconstructed wav and origin wav
clear all;
clc;
originFile = 'twoWrongsFemale.wav';
[originData,sRate] = audioread(originFile);
originN = length(originData);

advFile = 'twoWrongsFemaleAd-M3-18.wav';
[advData, sRate1]= audioread(advFile);


[filepath,name,ext] = fileparts(advFile);
reconstrFile = strcat(name,'-T2S',ext);
[reconstrData,sRate2] = audioread(reconstrFile);
reconstrN = length(reconstrData);
reconstrDataResample= resample(reconstrData, originN, reconstrN);

disp("The correlation coefficient between originData and adversarial Data (for a sanity check):");
[R,p] = corrcoef(originData,advData)

disp("The correlation coefficient between originData and reconstructedData after text2speech:");
[R,p] = corrcoef(originData,reconstrDataResample)

disp("The correlation coefficient between adversarial Data and reconstructedData after text2speech:");
[R,p] = corrcoef(advData,reconstrDataResample)




