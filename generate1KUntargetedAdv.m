% generate 1040 untargeted adversarial voice examples for DeepSpeech v0.2.0
clear all;
clc;
disp('Generate 1000 untargeted adversarial voice examples for DeepSpeech v0.2.0');
disp('From text file, read 1000+ sentences, convert to wave file, add noise, then test DeepSpeech:');
disp('1 In Linux, you must install espeak or pico2wav software for text to speech;');
disp('2 In Linux, you need to install DeepSpeech deep lerning software V0.2.0;');
disp('3 make sure the input novel text without any punctuation marks;');
disp('4 make sure deepspeech is at correct directory in the dpStrBasic string');

strBasicDir = '/home/hxie1/Projects/DeepSpeech';

dpStrBasic= ['deepspeech --model /home/hxie1/Projects/DeepSpeech/models/output_graph.pbmm '...
    '--alphabet /home/hxie1/Projects/DeepSpeech/models/alphabet.txt '...
    '--lm /home/hxie1/Projects/DeepSpeech/models/lm.binary '...
    '--trie /home/hxie1/Projects/DeepSpeech/models/trie '...
    '--audio '];

% load N texts
originText = fileread('/home/hxie1/Projects/DeepSpeech/data/TaleTwoCities_Format.txt');
textCell = strsplit(originText, newline);
textArray = string(textCell);
textN = length(textArray);
% trim white space
for i=1:textN
    textArray(i) = strtrim(textArray(i));
end

% open statistics csv file
c = clock;
timeStr = sprintf('%4d%02d%02d-%02d%02d',c(1),c(2),c(3),c(4),c(5));
statisCsvFile = strcat(strBasicDir, '/data/statisFile', timeStr, '.csv');
csvFileID = fopen(statisCsvFile, 'w');
% print csv file table header
fprintf(csvFileID, ['Text#, Origin_Text, Adversarial_Text, Origin_Mean, Origin_std, NoiseCoeff, L1NormNoise, L2NormNoise, LInfNormNoise, SNR(db),' ... 
                      'Corr_O_A, Corr_O_R, Corr_A_R, ConsistentByText, ConsistentByCorr_A_R, \n\r']);

%textN = 5; %debug try
for i= 1:1% textN
    % generate wave file
    textWaveName = sprintf('%s/data/T%d.wav',strBasicDir, i);
    %[s, cmdout] = system(sprintf('espeak "%s" -w %s -s 140', textArray(i),textWaveName)); % sythesis voice
    [s, cmdoutT2S] = system(sprintf('pico2wave --wave=%s  "%s"',  textWaveName, textArray(i))); % natural voice
    if 0 ~= s
        disp(cmdoutT2S);
        fprintf("text 2 speech error at output %s, with the %dth textArray\n", textWaveName, i);
        break;
    end
    % load wave file
    [originWavData,sRate] = audioread(textWaveName);
    Norigin = length(originWavData);
    originStd = std(originWavData);
    originMean = mean(originWavData);
    
    t = 630; %150; % numuber of scale down factor of the std of originData;
    consistentByCorr_A_R = 1;
    while (consistentByCorr_A_R)
        t = t-20;
        if t<=0
            t = 0.5;
        end
        % add noise
        % disp('method1: add small gaussian noise:');
        method = 'M1-';
        noiseG = normrnd(0,originStd/t, Norigin,1);
        advData = originWavData + noiseG;
        
        % write wave back
        [filepath,name,ext] = fileparts(textWaveName);
        advWaveFile = char(strcat(filepath, '/', name,'-Ad-',method, string(t),ext));
        audiowrite(advWaveFile, advData,sRate);
        
        % feed to DeepSpeech
        dpStr = char(strcat(dpStrBasic,{' '}, advWaveFile));
        [s, cmdoutDP] = system(dpStr);
        if 0 ~= s
            disp(cmdoutDP);
            fprintf("DeepSpeech error at the %dth textArray and %s feeding file\n", i, advWaveFile);
            break;
        end
        % Extract label text
        cmdoutDPCell = strsplit(cmdoutDP,newline);
        labelText = strtrim(string(cmdoutDPCell(8)));
        % generate label wave
        [filepath,name,ext] = fileparts(advWaveFile);
        advLabelWaveFile = char(strcat(filepath, '/', name,'-Label',ext));
        [s, cmdoutT2S] = system(sprintf('pico2wave --wave=%s  "%s"',  advLabelWaveFile, labelText)); % natural voice
        if 0 ~= s
            disp(cmdoutT2S);
            fprintf("text 2 speech error at output: %s with label: %s \n", advLabelWaveFile, labelText);
            break;
        end
        
        % load adversarial label wave
        [advLabelWavData,sRate] = audioread(advLabelWaveFile);
        Nreconstr = length(advLabelWavData);
        reconstrDataResample= resample(advLabelWavData, Norigin, Nreconstr);
        
        % compute correlation coefficient
        corrO_A = corrcoef(originWavData,advData);
        corrO_R = corrcoef(originWavData,reconstrDataResample);
        corrA_R = corrcoef(advData,reconstrDataResample);
        
        epsilon = advData - originWavData;
        l1norm = norm(epsilon, 1);
        l2norm = norm(epsilon, 2);
        lInfnorm = norm(epsilon, Inf);
        snrData = snr(originWavData, epsilon);
        
        if (abs(corrA_R(1,2)) < 0.5 )
            consistentByCorr_A_R = 0;
        else
            [s, cmdoutRm] = system(sprintf('rm %s %s', advWaveFile, advLabelWaveFile));
            if 0 ~= s
                disp(cmdoutRm);
                fprintf("error in deleting files: %s, %s \n", advWaveFile, advLabelWaveFile);
                
            end
        end
        
    end
    
    consistentByText = 0;
    if strcmpi(textArray(i), labelText)
        consistentByText = 1;
    end
    
    % output Statistic data
    % Header: ['Text#, Origin_Text, Adversarial_Text, Origin_Mean, Origin_std, NoiseCoeff, L1NormNoise, L2NormNoise, LInfNormNoise, SNR(db),' ... 
    %           'Corr_O_A, Corr_O_R, Corr_A_R, ConsistentByText, ConsistentByCorr_A_R, \n\r']
    
    fprintf(csvFileID,['%d, %s, %s, %5.2f, %5.2f, %d, %9.6f, %9.6f, %9.6f, %5.2f, '...
                       '%9.6f, %5.2f, %5.2f, %d, %d, \n\r'],...
                       i, textArray(i), labelText, originMean, originStd, t, l1norm, l2norm, lInfnorm, snrData,... 
                       corrO_A(1,2), corrO_R(1,2),corrA_R(1,2), consistentByText, consistentByCorr_A_R);
    fprintf("...... output text: %d\n", i);
    
end
fclose(csvFileID);
fprintf('The final statistic data file ouput at %s\n', statisCsvFile);

disp('=========End of Program==========');