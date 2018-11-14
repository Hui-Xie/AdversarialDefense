% read original T*.wav file, generate specific adversarial example, and print original generated text
% commandline examples:
% python3 attack.py --in data/T1.wav --target "he travels the fastest who travels alone" --out data/T1-Ad.wav
% deepspeech models/output_graph.pb  data/T1-Ad.wav models/alphabet.txt
% deepspeech models/output_graph.pb  data/T1.wav models/alphabet.txt



N=3; % T1.wav to TN.wav, total N file
targetText = 'he travels the fastest who travels alone';
deepSpeechDir = '/Users/hxie1/Projects/DeepSpeech';
dataDir= strcat(deepSpeechDir, '/data');

c = clock;
timeStr = sprintf('%4d%02d%02d-%02d%02d',c(1),c(2),c(3),c(4),c(5));
gpuAdvCsvFile = strcat(dataDir,'/gpuAdv', timeStr, '.csv');
gpuAdvCsvFileID = fopen(gpuAdvCsvFile, 'w');
% print csv file table header
fprintf(gpuAdvCsvFileID, ['Text#, Origin_Text_Wave, Target_Text, DeepSpeech_Recog_OriginText, DeepSpeech_Recog_Advesarial_Text, \n\r']);

for i=1:10
    T1WavFile = sprintf('%s/T%d.wav', dataDir,i);
    T1AdvFile = sprintf('%s/T%d-Ad.wav', dataDir,i);
    attackScript = sprintf('%s/attack.py', deepSpeechDir);
    
    % generate attack adversarial samples
    fprintf("start to generate adversarial sample for T%d.wav, which needs about 5 mins for one file. \n", i);
    attackCmdStr = sprintf('python3 %s --in %s --target "%s" --out %s',attackScript, T1WavFile, targetText, T1AdvFile);
    [s, cmdoutAttack] = system(attackCmdStr);
    if 0 ~= s
        disp(cmdoutAttack);
        fprintf("python attack script error at generating output: %s \n", T1AdvFile);
        break;
    end
    
    % use deepSpeech to verify the original wave 
    modelGraphFile = strcat(deepSpeechDir, '/models/output_graph.pb');
    modelAlphaFile = strcat(deepSpeechDir, '/models/alphabet.txt');
    verifyOriginWaveStr = sprintf('deepspeech %s %s %s', modelGraphFile, T1WavFile, modelAlphaFile);
    [s, cmdoutVerify] = system(verifyOriginWaveStr);
    if 0 ~= s
        disp(cmdoutVerify);
        fprintf("DeepSpeech error at the %dth textArray and %s feeding file\n", i, T1WavFile);
        break;
    end
    cmdoutDPCell = strsplit(cmdoutVerify,newline);
    dpRecogOriginText = strtrim(string(cmdoutDPCell(5)));
        
    % use deepSpeech to verify adversarial wave
    verifyAdvWaveStr = sprintf('deepspeech %s %s %s', modelGraphFile, T1AdvFile, modelAlphaFile);
    [s, cmdoutVerify] = system(verifyAdvWaveStr);
    if 0 ~= s
        disp(cmdoutVerify);
        fprintf("DeepSpeech error at the %dth textArray and %s feeding file\n", i, T1AdvFile);
        break;
    end
    cmdoutDPCell = strsplit(cmdoutVerify,newline);
    dpRecogAdvText = strtrim(string(cmdoutDPCell(5)));
    
    % ['Text#, Origin_Text_Wave, Target_Text, DeepSpeech_Recog_OriginText, DeepSpeech_Recog_Advesarial_Text, \n\r']
    fprintf(gpuAdvCsvFileID, ['%d, %s, %s, %s, %s \n\r'], i, T1WavFile, targetText, dpRecogOriginText, dpRecogAdvText);
    
    fprintf("...... end of output T%d.wav \n", i);
    
end

fclose(gpuAdvCsvFileID);
fprintf('The GPU Adversarial Examples ouput at %s\n', gpuAdvCsvFile);

disp('=========End of Program==========');