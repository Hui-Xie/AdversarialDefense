% draw correletion change from normal sample to adversarial sample
% file format: SampleIndex, Normal_Reconstruc, Adv_Reconstruction;
clc;
clear all;
csvFile  = '/home/hxie1/Projects/DeepSpeech/data/Index_NormCorr_AdvCorr.csv'
data = csvread(csvFile);
x = data(:,1);
y = data(:,2);
y2 = data(:,3);
u = zeros(size(x));
v = data(:,3)- data(:,2);

figure;
quiver(x,y,u,v,0,'o', 'ShowArrowHead', 'off', 'MaxHeadSize', 0.1, 'LineWidth', 2);
hold on;
plot(x, y2, 'v','LineWidth', 2 );
xlabel('Sample', 'FontSize', 15, 'FontWeight','bold');
ylabel('$$\mathbf{\rho(\hat{x},y)}$$','Interpreter','Latex', 'FontSize', 20);








