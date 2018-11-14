% preprocess the text of A tale of two cities.
clear all;
clc;
originText = fileread('../data/TaleTwoCities.txt');
text1 = replace(originText, newline, ' ');
text2 = replace(text1, '.', newline);
text3 = replace(text2, ',', newline);
text4 = replace(text3, ';', newline);
text5 = replace(text4, '"', '');
text6 = replace(text5, '!', '');
fid = fopen('../data/TaleTwoCities_format.txt', 'w');
fprintf(fid,'%s', text6);
fclose(fid);