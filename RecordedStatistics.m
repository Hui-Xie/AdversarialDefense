% compute SNR data

clc;
clear all;

recordFileDir = '/home/hxie1/Projects/DeepSpeech/data/originalWaveRecord';
originalWavDir = '/home/hxie1/Projects/DeepSpeech/data/originalWave';  

snr_O_Rec= zeros(10,1);
snr_Rec_Adv = zeros(10,1);

for i=1:10
   originFile = sprintf('%s/T%d.wav',originalWavDir, i);
   recordedFile = sprintf('%s/T%d-Record.wav',recordFileDir, i);
   advWavFile = sprintf('%s/T%d-Record-Ad.wav',recordFileDir, i);
   
   [originWavData,sRate] = audioread(originFile);
   Norigin = length(originWavData);
   [recordWavData,sRate] = audioread(recordedFile);
   Nrecord = length(recordWavData);
   [advWavData,sRate] = audioread(advWavFile);
   Nadv = length(advWavData);
   
   % first compute snr_Rec_Adv
   epsilon1 = advWavData - recordWavData; 
   snr_Rec_Adv(i) = snr(recordWavData, epsilon1);
   
   % second compute snr_Rec_origin
   snr_O_Rec(i) = attenuatedSNR(originWavData, recordWavData);
   
   fprintf('compute %d sample\n', i);
   
end

fprintf('mean of snr_Record_Adversary: %f\n', mean(snr_Rec_Adv));
fprintf('mean of snr_Origin_Record: %f\n', mean(snr_O_Rec));
