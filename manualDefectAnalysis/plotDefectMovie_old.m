function plotDefectMovie (mainDir, dirImagesToPlotOn, fileType, dirOutput, frames);
% function plotDefectMovie (mainDir, dirImagesToPlotOn, fileType, dirOutput, frames);
% This function takes the results of the maunal tracking of defects using the groundTruth app, 
% and calculates exact defect positions and plots them.
% It automatically detects if the inupt images contain side-by-side images
% (in which case the defects are plotted on both sides) or single images
% 
% Works on the movie in mainDir
% loading resultsGroundTruth.mat that contains gTruth
% overlays the defect on the images in "dirImagesToPlotOn" of "fileType" and saves them in "dirOutput" 
% INPUT
%   mainDir
%   dirImagesToPlotOn - contains the directory of images that the defect
%   annotation will be overlaid on
%   fileType - the fileType of files in dirImagesToPlotOn
%   dirOutput - the directory where the output images are saved
%   frames - optional input if only partial analysis is desired; should
%            include frame numbers to be analyzed
% SAVES
%   1) png images in dirOutput. Each image contain the corresponding image from dirImagesToPlotOn
%   overlaid with all defect anotations

%%
%% define folder names and analysis parameters
% define the relevant folders
dirLocalOP = [mainDir,'\LocalOP']; % masked local order parameter field

cd(mainDir); mkdir(dirOutput)
cd(mainDir); load('resultsGroundTruth');

cd(dirImagesToPlotOn); fileNames=dir (['*.',fileType]);
if ~exist('frames'),
    frames=[1:length(fileNames)];
    % frames=[1:length(fileNames)-1]; % NEED TO CHECK WHY GTRUTH HAS ONE LESS IMAGE
end
%% loop on all frames and look for defects
for k=frames,  % loop on all frames
    thisFile=fileNames(k).name; % find this frame's file name
    endName=strfind(thisFile,'.');
    thisFileImNameBase = thisFile (1:endName-1); %without the .filetype
    cd (dirImagesToPlotOn); thisIm=importdata([thisFileImNameBase,'.',fileType]);
    cd(dirLocalOP); load(thisFileImNameBase); % load the localOP to find the defect location
    
    thisImWithDefect = thisIm; % this is the new image we will add annotations on
    % check if the image is a side by side image or single image
    if size(thisIm,2)> size(localOP,2),
        duplicateImages=1; % side by side image- defects need to be duplicated
    else
        duplicateImages=0; % single image- defects defects plotted once
    end
    numDefects(k)=0;
    if or(or( size(gTruth.LabelData.h{k})>0, size(gTruth.LabelData.mh{k})>0),size(gTruth.LabelData.o{k})>0) % if we have any defects in thisFrame defects
        if size(gTruth.LabelData.h{k})>0
            for j=1: length(gTruth.LabelData.h{k}),
                numDefects(k) = numDefects(k)+1;
                thisDefect=gTruth.LabelData.h{k}(j); typeDefect = 'half';
                [thisImWithDefect, defPosition , defAngle] = plotDefect (thisImWithDefect, localOP, thisDefect, typeDefect, duplicateImages);
            end
        end
        if size(gTruth.LabelData.mh{k})>0
            for j=1: length(gTruth.LabelData.mh{k}),
                numDefects(k) = numDefects(k)+1;
                thisDefect=gTruth.LabelData.mh{k}(j); typeDefect = 'mhalf';
                [thisImWithDefect, defPosition , defAngle] = plotDefect (thisImWithDefect, localOP, thisDefect, typeDefect, duplicateImages);
            end
        end
        if size(gTruth.LabelData.o{k})>0
            for j=1: length(gTruth.LabelData.o{k}),
                numDefects(k) = numDefects(k)+1;
                thisDefect=gTruth.LabelData.o{k}(j); typeDefect = 'one';
                [thisImWithDefect, defPosition , defAngle] = plotDefect (thisImWithDefect, localOP, thisDefect, typeDefect, duplicateImages);
            end
        end
    end
    %     figure; imshow (thisImWithDefect); title(num2str(k));
    cd(dirOutput); imwrite(convert2RGB(thisImWithDefect),[thisFileImNameBase,'.png']) % %enforce the image as RGB even when no defect was plotted
end
end

function rgb = convert2RGB(I)

if ismatrix(I)
    rgb = cat(3, I , I, I);
else
    rgb = I;
end

end