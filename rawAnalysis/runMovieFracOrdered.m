function [fracOrdered, rawFracOrdered, maskArea] = runMovieFracOrdered (mainDir, toSave, toPlot, theseFrames, thisCohTH, thisCohDiskSize);
% function [fracOrdered,rawFracOrdered, maskArea] = runMovieFracOrdered (mainDir, toSave, toPlot, , thisCohTH, thisCohDiskSize, frames);
% This function calculates and displays the regions that are defined as
% ordered based on coherence > thisCohTH with and without an extra filtering
% step with a length scale thisCohDiskSize
% INPUT
%   mainDir
%   analysisParameters - contains all the analysis parameters
%   toSave - =1 for saving =0 for not saving
%   toPlot - =1 for plotting =0 for not plotting
%   thisCohTH - optional input; Threshold for coherence value (default value- taken from cohTH in
%               analysis parameters)
%   thisCohDiskSize- optional input; Threshold for coherence disk size for removing holes/spots in coherehce > cohTH (default value- taken from
%                coherenceWinSize in analysis parameters)
%   frames - optional input if only partial analysis is desired; should
%            include frame numbers to be analyzed
% SAVES
%  1) file in mainDir\fracOrdered.mat containing "fracOrdered",
%  "rawFracOrdered" and the "cohTH" and "cohDiskSize" used

%% define folders and parameters
dirCoherence = [mainDir,'\Coherence']; % masked coherence field
cd(mainDir); load ('AnalysisSummary'); cohTH=analysisParameters(6); cohDiskSize=analysisParameters(4);% load analysisParameters of this movie
% define coherence threshold paramters from input if input is given
if exist('thisCohTH'), cohTH=thisCohTH; end
if exist('thisCohDiskSize'), cohDiskSize=thisCohDiskSize; end
%% load the coherence data
cd(dirCoherence); fileNames=dir ('*.mat*'); % find names of files
% if no frames are indicated run on the entire movie
if ~exist('theseframes'),
    theseFrames=[1:length(fileNames)];
end
% loop on all frames and load coherence
for k=theseFrames,
    thisFile=fileNames(k).name;
    cd(dirCoherence);load(thisFile);
    coherence_mat(:,:,k)=coherence;
end
%% Erode the mask so that edges are not counted in the fraction ordered
coh_mask = coherence_mat;
coh_mask(isnan(coherence_mat)) = 0;
coh_mask(coh_mask>0) = 1;
se2 = strel('disk',round(cohDiskSize));
coh_mask = imerode(coh_mask,se2);
coherence_mat(coh_mask ==0)= nan;

%% Make smootheed coherehce region with imopen and imclose
% make a simpler region  using the length scale from coherenceWinSize (that
% is used to define the coherence map) to remove small dots and close
% small holes in the region of the coherence
se = strel('disk',round(cohDiskSize)); % this is the disk region used for the imopen and imclose operators; radius  cohDiskSize [= coherenceWinSize (default)]
coherence_map_NoNaN=coherence_mat>cohTH; coherence_map_NoNaN(isnan(coherence_mat))=0; % get the region with coherence>cohTH and makes all the outside NaN regions = 0 so the imopen and imclose work
Scoherence_mat=imopen (coherence_map_NoNaN,se);
Scoherence_mat=imclose (Scoherence_mat,se);
Scoherence_mat = simplifyMask (Scoherence_mat,cohDiskSize); % smooth the boundary of the mask with default value windowSize
Scoherence_mat(isnan(coherence_mat))=0; % remove everything outside mask

%% display coherence
% show full coherence map
if toPlot== 1,
    hcoherence=implay(coherence_mat,3);
    hcoherence.Visual.ColorMap.Map = jet(256);
    hcoherence.Parent.Position = [0,400,size(coherence_mat,2) size(coherence_mat,1)];
    cd (mainDir);save( 'coherence_mat'); % saves the fraction ordered with the thresholds and disksize used
    
    % show region used for analysis (=coherence>cohTH after imopen and imclose), and original coherent regions
    THregion(:,:,1,:)= coherence_mat > cohTH; THregion(:,:,2,:)=Scoherence_mat; THregion(:,:,3,:)=~isnan(coherence_mat); % r=rawcoherence>TH, g = smoothedcoherence>TH; b = in mask region
    hTH=implay(THregion,3);
    hTH.Parent.Position = [0+size(coherence_mat,1),400,size(coherence_mat,2) size(coherence_mat,1)];
end

%% calculate fraction ordered and save the data
if toSave== 1,
    for k=theseFrames,
        thisFrameMaskArea = sum(sum(~isnan(coherence_mat(:,:,k)))); % calculate the mask area (not NaN coherence)
        thisFrameCoherentArea = sum(sum(~(Scoherence_mat(:,:,k)==0))); % calculate the area of the region with coerence > cohTH after smoothing
        thisFrameRawCoherentArea = sum(sum(coherence_mat(:,:,k) > cohTH)); % calculate the area of the region with coerence > cohTH without smoothing
        maskArea(k) = thisFrameMaskArea; % area of masked region
        fracOrdered(k) = thisFrameCoherentArea / thisFrameMaskArea; % fraction of ordered region based on smoothed coherence (I think this is better)
        rawFracOrdered(k) = thisFrameRawCoherentArea / thisFrameMaskArea; % fraction of ordered region based on raw coherence
    end
    cd (mainDir);save( 'fracOrdered.mat', 'fracOrdered','rawFracOrdered' ,'cohTH','cohDiskSize'); % saves the fraction ordered with the thresholds and disksize used
end
end
