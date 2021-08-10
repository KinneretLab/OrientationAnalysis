 %% add the neededs path for the analysis
clear all
addpath(genpath('\\phhydra\data-new\phkinnerets\Lab\CODE\Hydra\'));
codeDir='\\phhydra\data-new\phkinnerets\Lab\CODE\Hydra\OrientationAnalysis\';

warning('off', 'MATLAB:MKDIR:DirectoryExists');% this supresses warning of existing directory
%% define mainDirList
% mainDir = '\\phhydra\data-new\phhydra\Analysis\users\Yonit\Nematic Topological Defects\Movie Analysis\2018_10_22_pos11_test2';
 topMainDir='\\phhydra\data-new\phkinnerets\home\lab\CODE\Hydra\';
; % main folder for movie analysis
mainDirList= { ... % enter in the following line all the all the movie dirs to be analyzed
'2019_02_18_pos3_EXAMPLE\', ...

};
for i=1:length(mainDirList),mainDirList{i}=[topMainDir,mainDirList{i}];end

toSave=1; % If zero, doesn't save images and doesn't overwrite existing images.
numImages = 4; % can be 1,2 or 4
 
 
%% intialize movie analysis to get movie info input
for i=1:length(mainDirList)
    mainDir=[mainDirList{i},'\Orientation_Analysis'];
    initializeMovie (mainDir);
    cd(mainDir); load ('movieDetails');
    calibrationList(i)=calibration;
    framesList{i} = frames;
    
end
%% Prepare images for manual analysis - combine quiver+OP with adjusted images
for i=1:length(mainDirList)
    mainDir=[mainDirList{i},'\Orientation_Analysis'];
    frames=framesList{i};     calibration=calibrationList(i);
    if length (framesList{i}) == 0 % run on all frames
        runMovieGTLformat (mainDir, toSave, calibration, numImages);
    else % run on frames indicated
        runMovieGTLformat (mainDir, toSave, calibration, numImages, frames);
    end
    close all
end
 
%% run manual analysis 
% this will open the groundTruthLabeler after uploading the label
% definitions from the mat file and the movie as an image sequence from
i=1; % place i to choose movie for manual analysis
mainDir=[mainDirList{i},'\Orientation_Analysis'];
dirQuiver = [mainDir,'\QuiverGTL']; % figures showing plots of quiver 
cd(codeDir); cd('manualDefectAnalysis');
groundTruthLabeler2('groundTruthLabelingSession_New.mat',dirQuiver); 
%IMPORTANT: IF YOU WANT TO SAVE THE LABELS, EXPORT LABELS INSIDE THE APP
%UNDER THE NAME "ResultsGroundTruth.mat" AND SAVE IN THE MAIN ANALYSIS FOLDER.
%The session should be saved with the relevant date in the main analysis
%fodler.

% fileattrib('groundTruthLabelingSession_2019_08_28.mat', '-w') % this will
% make the file readonly and prevent writing over it
%% plot manual analysis - once manual defect labelling is complete (saved ground truth labelling results)
i=1;
mainDir=[mainDirList{i},'\Orientation_Analysis'];
dirQuiver = [mainDir,'\Quiver']; % figures showing plots of quiver 
dirImagesToPlotOn = dirQuiver; fileType='png'; % this is the directory of images we want to overlay the defect annotation on, and the filetype of these images
dirOutput = [mainDir,'\Defects'];
% frames = 10:30; % for testing on a limitted number of frames
% plotDefectMovie (mainDir, dirImagesToPlotOn, 'png',dirOutput, frames); % loads data from manual defect tracking from mainDir\resultsGroundTruth.mat and images from dirImagesToPlotOn and makes images with overliad defects into dirOutput 
plotDefectMovie (mainDir, dirImagesToPlotOn, 'png', dirOutput); % loads data from manual defect tracking from mainDir\resultsGroundTruth.mat and images from dirImagesToPlotOn and makes images with overliad defects into dirOutput 

dirImages=[mainDir,'\AdjustedImages']; %  images after image histogram adjustment
dirImagesToPlotOn = dirImages; fileType='png'; % this is the directory of images we want to overlay the defect annotation on, and the filetype of these images
dirOutput = [mainDir,'\DefectsIm'];
% frames = 10:30; % for testing on a limitted number of frames
% plotDefectMovie (mainDir, dirImagesToPlotOn, 'png',dirOutput, frames); % loads data from manual defect tracking from mainDir\resultsGroundTruth.mat and images from dirImagesToPlotOn and makes images with overliad defects into dirOutput 
plotDefectMovie (mainDir, dirImagesToPlotOn, 'png', dirOutput); % loads data from manual defect tracking from mainDir\resultsGroundTruth.mat and images from dirImagesToPlotOn and makes images with overliad defects into dirOutput 
