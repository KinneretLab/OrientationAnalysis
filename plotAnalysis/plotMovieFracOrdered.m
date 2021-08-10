function plotMovieFracOrdered (mainDir, thisCohTH, thisCohDiskSize)
% plotMovieFracOrdered (mainDir, thisCohTH, thisCohDiskSize)
% this function generates a graph of the fraction ordered in the movie
% mainDir, with optional input for coherence threshold and diskSize 
%% load data and calculate fraction ordered
cd(mainDir)
load ('movieDetails');  load ('AnalysisSummary');
% define coherence threshold paramters from analysisParameters 
cohTH=analysisParameters(6); cohDiskSize=analysisParameters(4);
% or from input data if given
if exist('thisCohTH'), cohTH=thisCohTH; end
if exist('thisCohDiskSize'), cohDiskSize=thisCohDiskSize; end

% [fracOrdered,rawFracOrdered] = runMovieFracOrdered (mainDir, 0, 1, cohTH, cohDiskSize, frames); % toSave = 0 (don't save), toPlot = 0 (don't plot movies of coherent area)
[fracOrdered,rawFracOrdered] = runMovieFracOrdered (mainDir, 0, 0, cohTH, cohDiskSize, frames); % toSave = 0 (don't save), toPlot = 1 (plot movies of coherent area)
useRawOrder = 0; % =1 for using the raw fraction ordered based on coherence >cohTH; use =0 for using additional filtereing with cohDiskSize (better I think)
if useRawOrder,
    fracOrdered = rawFracOrdered; % in this case use the raw fraction of coherece > cohTH
end

%% plot
if timeInterval == 0,
    % load time from movie - NEED TO KNOW INPUT FILE FORMAT
    % time = 
elseif timeInterval>0,
    time = 1:length(fracOrdered);
    time = time.* timeInterval +startTime ; %time in minutes
end
time = time/60; % time in hours
figure
f = smoothdata(fracOrdered,'gaussian',10);
plot(time,f,'k-','linewidth',1.5);
hold on

plot(time,fracOrdered,'ko','MarkerFaceColor',[0.7 0.7 0.7]);
ylabel('Fraction ordered','fontsize',12)
xlabel('Time [hours]','fontsize',12)
ylim([0.4 1]);
xlim([0  max(time)])
set(gcf,'units','centimeter','position', [5 14 9 6])
box off

for i=1:length(fracOrdered),
end
end

