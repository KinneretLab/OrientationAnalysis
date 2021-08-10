function runMovieAnalysis_par (mainDir, toSave, calibration, numImages, isLS, par_num, manual_mask, frames)
% function runMovieAnalysis (mainDir, toSave, calibration, is4Images, frames);
% this function runs the raw analysis of orientation on the movie defined
% in "mainDir"; "toSave"=1 for saving the results in "mainDir". "frames" is
% an optional input is only part of the frames are to be analyzed.
%
% All the analysis parameters are defined in pixels here based on the
% "calibration" and default parameters defined in microns (analysisParameters =
% [gradientsigma,blocksigma,orientsmoothsigma,coherenceWinSize, relTH, cohTH,localOPwinSize];)
% This function calls the function "runFrameAnalysis", "plotFrameAnalysis" to actually do the
% analysis for each frame in the movie, and then "runMovieFracOrdered" to
% caclulate fraction ordered
%
% INPUT
%   mainDir
%   toSave - =1 for saving =0 for not saving
%   calibration - in um/pix
%   is4Images =0 for a single image, =1 from 4 images
%   frames - optional input if only partial analysis is desired; should
%            include frame numbers to be analyzed

%% define folder names and analysis parameters
dirRawImages=[mainDir,'\Raw Images']; % original images
dirImages=[mainDir,'\AdjustedImages']; %  images after image histogram adjustment
dirMasks=[mainDir,'\Masks']; % masks
dirOrientation=[mainDir,'\Orientation']; % masked orientation field
dirReliability=[mainDir,'\Reliability']; % masked relaibility field
dirCoherence = [mainDir,'\Coherence']; % masked coherence field

% make all the needed new directories
cd(mainDir); mkdir(dirImages); mkdir(dirOrientation); mkdir(dirReliability); mkdir(dirCoherence); 

%define all parameters
gradientsigma=0.5*1.28/calibration; % Sigma of the derivative of Gaussian used to compute image gradients.
blocksigma=5*1.28/calibration;  % Sigma of the Gaussian weighting used to average the image gradients before defining the raw orientaion and reliability; 
orientsmoothsigma=3*1.28/calibration;  %  Sigma of the Gaussian used to smooth the raw orientation field and generate the orientation field
coherenceWinSize=10*1.28/calibration;  %  Window size for the coherence calculation based on the  raw orientation field 
relTH=0.3; % this is the threshold for determining if the gradient is reliable in a particular region. This is defined from the gradient field determiing if the gradient is strong enough
cohTH=0.92; % this is the threshold for the coherence in a region. This is determined from the local alignment of the raw orientation field (before the additional smoothing orientation field) and is used to define if there are ordered fibers in a given region
localOPwinSize = 32*1.28/calibration ; % this is the window size used to calculate the local order parameter

analysisParameters = [gradientsigma,blocksigma,orientsmoothsigma,coherenceWinSize, relTH, cohTH, localOPwinSize]; % all the analysis parameters together, used to pass on the parameters to subfunctions

%% run analysis on all frames and save

% get images names
cd(dirRawImages); fileNames=dir ('*.tif*');
% if no frames variable is indicated run on the entire movie
if ~exist('frames'),
    frames=[1:length(fileNames)];
end

if ~exist('par_num'),
    par_num = 8;
end


% save analysis parameteres for this movie
cd(mainDir); save('AnalysisSummary','mainDir','calibration','analysisParameters','frames') % saves the variables including the analysis parameters used

% loop on all frames and do the analysis

task_num = floor(length(frames)/par_num);
rem_num = rem(length(frames),par_num);
tasks = ones(par_num,1)*task_num;
tasks(length(tasks)) = tasks(length(tasks))+rem_num;
split_frames = mat2cell(frames,1,tasks);

for j = 1:par_num
    theseFrames = split_frames{j};
    cd(mainDir); save(['ParallelParameters',num2str(j)],'theseFrames','mainDir','analysisParameters','toSave','fileNames','isLS','numImages','manual_mask');
    % cd('\\phhydra\data-new\phhydra\Analysis\users\Yonit\MatlabCodes');
    str = ['!matlab -r " run_parallel_frames(' num2str(j) ')" &'];
    eval(str)
end

