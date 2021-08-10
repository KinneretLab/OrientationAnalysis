function [] = createTotalMask_lightsheet(thisFileImName, mainDir, analysisParameters, toSave)

%% Read raw masks created in ImageJ
dirRawMasks=[mainDir,'\RawMasks']; % raw masks
dirMasks=[mainDir,'\Masks']; % Directory for total masks
mkdir(dirMasks);

% Save file name without .tiff ending
endName=strfind(thisFileImName,'.tif');
thisFile = thisFileImName (1:endName-1);

% define all parameters from analysisParameters
gradientsigma = analysisParameters(1); % Sigma of the derivative of Gaussian used to compute image gradients.
blocksigma = analysisParameters(2); % Sigma of the Gaussian weighting used to average the image gradients before defining the raw orientaion and reliability;
orientsmoothsigma = analysisParameters(3);  %  Sigma of the Gaussian used to further smooth orientation field
coherenceWinSize = analysisParameters(4);  %  Window size for the coherence calculation on the the raw orientation field
relTH = analysisParameters(5);  % this is the threshold for determining if the graident is relaible in a particular region. This is defined from the gradient field determiing if the gradient is strong enough
cohTH = analysisParameters(6);  % this is the threshold for the coherence in a region. This is determined from the local alignment of the raw orientation field (before the additional smoothing orientation field) and is used to define if there are ordered fibers in a given region

%% load image and mask from file
try % load the image and corresponding mask
    cd (dirRawMasks); thisMask=importdata([thisFile,'.tiff']);
catch
    try
        cd (dirRawMasks); thisMask=importdata([thisFile,'.tif']);
    catch
        thisMask=[] ; disp(['no mask found ',thisFileImName]); % if no image is found
    end
end

imSize2=size(thisMask,2); imSize1=size(thisMask,1); % size of raw mask

modMask = thisMask>0; % Turn the mask into binary

% Smooth mask (using convolution with gaussian kernel and selection of
% isosurface = 0.5):
smoothMask = simplifyMask (modMask,3*blocksigma); % smooth input mask on scale of blocksigma

%% save the total mask
if toSave==1
    smoothMask = double(smoothMask);
    cd(dirMasks); imwrite(smoothMask,[thisFile,'.tiff']) % save adjusted image
end

end

