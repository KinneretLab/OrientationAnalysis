function [] = run_parallel_frames(j)

% Switch off warnings for existing directories
warning('off', 'MATLAB:MKDIR:DirectoryExists');% this supresses warning of existing directory

addpath(genpath('\\phhydra\phhydraB\Analysis\users\Yonit\MatlabCodes\GroupCodes\'));

currentFolder = pwd;
%thesePars = load([currentFolder,'\ParallelParameters',num2str(j)]); 
load([currentFolder,'\ParallelParameters',num2str(j)]); 

for k=theseFrames
    k % show the frame being analyzed
    thisFile=fileNames(k).name;
    runFrameAnalysis(thisFile, mainDir, analysisParameters, toSave); % this calculates the orientation field, reliability and coherence and saves the adjusted image
    endName=strfind(thisFile,'.tif'); thisFilePng=[thisFile(1:endName-1),'.png'];
    plotFrameAnalysis(thisFilePng, mainDir, analysisParameters, toSave,numImages); % this calculates the local order parameter and plots the quiver with the local order parameter and original image
end

toPlot= 0; % put 0 to not plat the coherence movie; =1 if to plot coherence movies
runMovieFracOrdered (mainDir, toSave, toPlot, theseFrames); % this calculates the fraction ordered

cd(currentFolder);
delete([currentFolder,'\ParallelParameters',num2str(j),'.mat']); 

close all;

quit
end

