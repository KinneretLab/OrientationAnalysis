function  displayMovieOrientationForPaper(mainDir, numImages, outputMainDir, frames)
% function  displayMovieOrientation(mainDir, , is4Images, frames)
%   is4Images =0 for a single image, =1 from 4 images

analysisMainDir= [mainDir,'\Orientation_Analysis'];
% analysisMainDir= [mainDir];
dirImages=[analysisMainDir,'\AdjustedImages']; %  images after image histogram adjustment
dirMasks=[analysisMainDir,'\Masks']; %  images after image histogram adjustment


% outputMainDir= [mainDir,'\Display'];
mainDisplayDir= [outputMainDir,'\mainDisplay'];
maskDisplayDir= [outputMainDir,'\Masks'];


mkdir(outputMainDir);mkdir(mainDisplayDir);

% Copy masks from Orientation_Analysis folder to Display folder:
copyfile(dirMasks, maskDisplayDir) ;

cd(dirImages); fileNames=dir ('*.png');
% if no frames variable is indicated run on the entire movie
if ~exist('frames'),
    frames=[1:length(fileNames)];
end
% loop on all frames and do the analysis
for k=frames,
%     k % show the frame being analyzed
    thisFileImName=fileNames(k).name;
    displayFrameOrientationForPaper(thisFileImName, mainDir, mainDisplayDir, numImages);
end