% measure L2 norm of 110-dim vector
clc;
clear all;
advDataDir = '/home/hxie1/temp_advData';
originalFile = '6-LayerID50.txt';
advFileVector = ["6-Ad0-LayerID50.txt", "6-Ad3-LayerID50.txt",  "6-Ad7-LayerID50.txt",  
                 "6-Ad1-LayerID50.txt",  "6-Ad4-LayerID50.txt",  "6-Ad8-LayerID50.txt",
                 "6-Ad2-LayerID50.txt",  "6-Ad5-LayerID50.txt",  "6-Ad9-LayerID50.txt"];
             
vecOrigin = dlmread(strcat(advDataDir, '/', originalFile));
vecOrigin100 = vecOrigin(1:100);
vecOrigin10 = vecOrigin(101:110);

fprintf("%s: L2norm(originalFile)=%f, L2norm(vecOrigin100)=%f,  L2norm(vecOrigin10)=%f; \n", originalFile, norm(vecOrigin),norm(vecOrigin100), norm(vecOrigin10) );

for i=1:9
    advFile = advFileVector(i);
    vecAdv = dlmread(strcat(advDataDir, '/', advFile));
    vecAdv100 = vecAdv(1:100);
    vecAdv10 = vecAdv(101:110);
    fprintf("%s: L2norm(advFile)=%f, L2norm(vecAdv100)=%f,  L2norm(vecAdv10)=%f, L2norm(vecAdv-vecOrigin)=%f, L2norm(vecAdv100-vecOrigin100)=%f, L2norm(vecAdv10-vecOrigin10)=%f; \n",...
    advFile, norm(vecAdv), norm(vecAdv100), norm(vecAdv10), norm(vecAdv -vecOrigin), norm(vecAdv100 -vecOrigin100),norm(vecAdv10 -vecOrigin10));   
   
end




