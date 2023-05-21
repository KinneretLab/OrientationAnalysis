 %% add the needed path for the analysis
clear all
addpath(genpath('\\phhydra\phhydraB\Analysis\users\Yonit\MatlabCodes\GroupCodes\'));
codeDir='\\phhydra\phhydraB\Analysis\users\Yonit\MatlabCodes\GroupCodes\OrientationAnalysis\';

warning('off', 'MATLAB:MKDIR:DirectoryExists');% this supresses warning of existing directory
%% define mainDirList

topMainDir='\\PHHYDRA\phhydraB\Analysis\users\Yonit\Movie_Analysis\Labeled_cells\'; % main folder for movie analysis
mainDirList= { ... % enter in the following line all the all the movie dirs to be analyzed

'2021_06_21_pos3\', ...


};

for i=1:length(mainDirList),mainDirList{i}=[topMainDir,mainDirList{i}];end
toSave=1; % If zero, doesn't save images and doesn't overwrite existing images.
numImages = 1; % Number of images for montage - can be 1,2, or 4.
manual_mask = 0; % Default: 0 if using automatically generated raw masks or refined masks that are saved in the "Display" folder. If the refined masks don't exist, they will be created, and if they exist they will be copied to the orientation analysis folder.
% Set to 1 if using manual masks, which need to be saved in the Orientation_Analysis folder, under "Masks". 
isLS = 0; % FOR LIGHTSHEET MOVIES THAT NEED TUNING OF THE MASKS. Setting to 1 means the "create total masks" function only smooths the raw masks without performing other operations. Relevant only if you don't have refined masks yet.
par_num = 1; % Set number of parallel processes for parallel computation. NOTE THAT IF YOU ARE RUNNING MULTIPLE MOVIES, EACH WILL BE RUN IN PARALLEL
%% intialize movie analysis to get movie info input
for i=1:length(mainDirList)
    mainDir=[mainDirList{i},'\Orientation_Analysis'];
    initializeMovie (mainDir);
    cd(mainDir); load ('movieDetails');
    calibrationList(i)=calibration;
    framesList{i} = frames;
    
end
%% Check if refined masks exist. Copy them to orientation analysis folder if exist, create them if not.
if manual_mask ==0
    for i=1:length(mainDirList)
        displayDir=[mainDirList{i},'\Display'];
        mainDir=[mainDirList{i},'\Orientation_Analysis'];
        mkdir([mainDirList{i},'\Orientation_Analysis','\Masks']);
        cd(displayDir); folderList = dir;
        if ~exist([displayDir,'\Masks'])
            if  IsLS==0 
                if length (framesList{i}) == 0 % run on all frames
                    createMaskMovie (displayDir, toSave, calibration);
                else % run on frames indicated
                    createMaskMovie (displayDir, toSave, calibration, framesList{i});
                end
                
            else 
                if length (framesList{i}) == 0 % run on all frames
                    createMaskMovie_lightsheet (displayDir, toSave, calibration);
                else % run on frames indicated
                    createMaskMovie_lightsheet (displayDir, toSave, calibration, framesList{i});
                end
            end
        end
        copyfile ([displayDir,'\Masks'], [mainDir,'\Masks']);   
    end
end
%% run raw analysis to get orientation, reliability and coherence fields,local OP, fraction ordered and plot quiver  
% IF YOU WANT TO USE PARALLEL COMPUTATION, ADD THE RELEVANT PATH TO YOUR
% MATLAB SEARCH (SEE MANUAL IN MAIN ANALYSIS FOLDER)
for i=1:length(mainDirList)
    mainDir=[mainDirList{i},'\Orientation_Analysis'];
    frames=framesList{i};     calibration=calibrationList(i);
    if length (framesList{i}) == 0 % run on all frames
         runMovieAnalysis_par (mainDir, toSave, calibration, numImages, isLS, par_num, manual_mask); % For parallel computation
        % runMovieAnalysis (mainDir, toSave, calibration, numImages, isLS, manual_mask); % For normal (not parallel) computation
    else % run on frames indicated
        runMovieAnalysis_par (mainDir, toSave, calibration, numImages, isLS, par_num, manual_mask, frames );% For parallel computation
        % runMovieAnalysis (mainDir, toSave, calibration, numImages, isLS, manual_mask, frames);% For normal (not parallel) computation

    end
end

%% display the analysis for movies we want to have a nice version of - RUN ONLY AFTER PREVIOUS STEP IS FINISHED! 
% for i=1:length(mainDirList)
%     mainDir=mainDirList{i};
%     frames=framesList{i};    calibration=calibrationList(i);
%     if length (framesList{i}) == 0 % run on all frames
%         displayMovieOrientation(mainDir, numImages),
%     else % run on frames indicated
%         displayMovieOrientation(mainDir, numImages, frames), %NOTICE UPDATE HERE, ADDED "is4Images"
%     end
% end

close all