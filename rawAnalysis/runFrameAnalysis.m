function  runFrameAnalysis(thisFileImName, mainDir, analysisParameters, toSave)
% function runFrameAnalysis(thisFileImName, mainDir, analysisParameters, toSave);
% takes a single frame "thisFileImName" from "mainDir" and analyzes it
% using the function "ridgeorient_withCoherence"
% The image file is loaded from mainDir\Raw Images and a corresponding mask from
% mainDir\Masks.
% The function calculates a smoothed orientation field, reliability and coherence at each pixel.
% If toSave=1, then the function saves these fields into folders in mainDir
% INPUT
%   thisFileImName
%   mainDir
%   analysisParameters - contains all the analysis parameters 
%   toSave - =1 for saving =0 for not saving
% SAVES
%  1) file in [mainDir,'\Orientation'] containing "orientation"
%  2) file in [mainDir,'\Reliability'] containing "reliability"
%  3) file in [mainDir,'\Coherence'] containing "coherence"

%% define folder names and analysis parameters
% define the relevant folders
dirRawImages=[mainDir,'\Raw Images']; % original images
dirImages=[mainDir,'\AdjustedImages']; %  images after image histogram adjustment
dirMasks=[mainDir,'\Masks']; % masks
dirOrientation=[mainDir,'\Orientation']; % masked orientation field
dirReliability=[mainDir,'\Reliability']; % masked relaibility field
dirCoherence = [mainDir,'\Coherence']; % masked coherence field

% define all parameters from analysisParameters
gradientsigma = analysisParameters(1); % Sigma of the derivative of Gaussian used to compute image gradients.
blocksigma = analysisParameters(2); % Sigma of the Gaussian weighting used to average the image gradients before defining the raw orientaion and reliability; 
orientsmoothsigma = analysisParameters(3);  %  Sigma of the Gaussian used to further smooth orientation field
coherenceWinSize = analysisParameters(4);  %  Window size for the coherence calculation on the the raw orientation field  
relTH = analysisParameters(5);  % this is the threshold for determining if the graident is relaible in a particular region. This is defined from the gradient field determiing if the gradient is strong enough
cohTH = analysisParameters(6);  % this is the threshold for the coherence in a region. This is determined from the local alignment of the raw orientation field (before the additional smoothing orientation field) and is used to define if there are ordered fibers in a given region

%% load image and mask from file

% Save file name without .tiff ending
endName=strfind(thisFileImName,'.tif');
thisFile = thisFileImName (1:endName-1);

try % load the image
    cd (dirRawImages); thisIm=importdata([thisFile,'.tiff']); 
catch
    try
         cd (dirRawImages); thisIm=importdata([thisFile,'.tif']); 
    catch
            thisIm=[];  disp (['no image found ',thisFileImName]); % if no image is found
    end
end

try % load the corresponding mask
    cd (dirMasks); thisMask=importdata([thisFile,'.tiff']); 
catch
    try
         cd (dirMasks); thisMask=importdata([thisFile,'.tif']); 
    catch
            thisMask=[];  disp (['no image found ',thisFileImName]); % if no image is found
    end
end

imSize2=size(thisIm,2); imSize1=size(thisIm,1); % size of input image

%% normalize image intensity using "adapthisteq" (CLAHE filter)
% adapthisteq parameters for CLAHE analysis of incoming image
% this seems to be better for generating nicer gradient over larger
% portions of the image by equalizing the intensity locally over regions of
% 4*blocksigma
NumTiles = [ round(imSize1/blocksigma/4), round(imSize2/blocksigma/4)]; % split the image into blocks of size 4*blocksigma where the histograms will be equalized 
Distribution = 'Rayleigh'; % this is a peaked distribution
nIm = adapthisteq(thisIm, 'NumTiles', NumTiles, 'Distribution',Distribution,'Alpha',0.4, 'ClipLimit', 0.01); % Alpha and ClipLimit are taken at defualt calues
% figure; imshow(nIm,[])
%% calculate smoothed orientation field, reliability and coherence over entire image
[origOrientaion, origReliability,origCoherence]= ridgeorient_withCoherence(nIm, gradientsigma,blocksigma,orientsmoothsigma,coherenceWinSize);
%% Erode mask to remove edges, smooth the mask and remove results outside masked region

se = strel('disk',round(3*blocksigma));
smallMask = imerode(thisMask,se);
smoothMask = simplifyMask (smallMask>0, blocksigma); % smooth input mask on scale of blocksigma 
orientation = origOrientaion; orientation(smoothMask==0)=NaN;
reliability = origReliability;  reliability(smoothMask==0)=NaN;
coherence = origCoherence; coherence(smoothMask==0)=NaN;
%% save the masked orientation, reliability and coherence into mat files
if toSave==1,
    endName=strfind(thisFileImName,'.tif');
    thisFileImNameSave = thisFileImName (1:endName-1);
    cd(dirImages); imwrite(nIm,[thisFileImNameSave,'.png']) % save adjusted image
    cd (dirOrientation);save( [thisFileImNameSave,'.mat'], 'orientation');
    cd (dirReliability);save([thisFileImNameSave,'.mat'], 'reliability');
    cd (dirCoherence);save( [thisFileImNameSave,'.mat'], 'coherence');
end

end