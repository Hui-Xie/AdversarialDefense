% element shift for generating adversarial samples
clear all;
clc;
originFile = 'twoWrongsFemale.wav';
[originData,sRate] = audioread(originFile);
N = length(originData);
originStd = std(originData); 


% disp('method1: add small gaussian noise:');
% method = 'M1-';
% t = 150; % numuber of scale down factor of the std of originData;
% noiseG = normrnd(0,originStd/t, 28720,1);
% advData = originData + noiseG;
% end of method1

% disp('method2: simple loop shift');
% method = 'M2-';
% t=13; % number of element shift
%advData(1:t, 1) = originData(N-t+1:N,1); 
%advData(t+1:N,1) = originData(1:N-t, 1);
% end of method2

disp('method3: tailor tail elements and then sparsely diffuse them');
method = 'M3-';
t=18; % number of element shift
advData = zeros(size(originData));
tailElements = originData(N-t+1:N); 
nDivision = t+1;
lenDivision = fix((N-t)/nDivision);
i=0; j=0;
for nDiv=1:nDivision
    i = (nDiv-1)*(lenDivision+1)+1;     % start index in AdvData
    j = (nDiv-1)*lenDivision +1;        % start index in originData
    if nDiv ~= nDivision
        advData(i:i+lenDivision-1) = originData(j:j+lenDivision-1);
        advData(i+lenDivision) = tailElements(nDiv);
    else
       advData(i:N) = originData(j:N-t);        
    end
end
% end of method3

[filepath,name,ext] = fileparts(originFile);
outputFile = char(strcat(name,'Ad-',method, string(t),ext));
audiowrite(outputFile, advData,sRate); 
disp(['Ouput an adversarial example: ', outputFile]);


sound(advData, sRate);
disp("The correlation coefficient between originData and adversarial Data:");
[R,p] = corrcoef(originData,advData)

originMean = mean(originData);
disp(['originMean=',string(originMean), '  originStd=', string(originStd)]);

epsilon = advData - originData;
disp("The L2 norm of (advesarialData -originData ):");
l2norm = norm(epsilon, 2)

disp("The L1 norm of (advesarialData -originData ):");
l1norm = norm(epsilon, 1)

disp("The L infinite norm of (advesarialData -originData ):");
lInfnorm = norm(epsilon, Inf)

disp("the SNR(db):");
snrData = snr(originData, epsilon)

