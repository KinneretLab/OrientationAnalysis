function  plotFrameGTL_V2(thisFileImName, mainDir, analysisParameters, toSave, numImages);
% function  plotFrameAnalysis(thisFileImName, mainDir, analysisParameters, toSave, is4Images);
% This function takes a single frame thisFileImName from mainDir and determines the local
% order parameter and plots the quiver with the localOP and original image
% The image file is loaded from mainDir\Raw Images
% The function calculates the localOP at every pixel:
% Q = sqrt( <cos(2 theta)>^2+<sin(2 theta)>^2) averaged over localOPwinSize pixels
% from a downsampled orientation field with round(blocksigma)
% There is also a calculation of the filtered localOP which is defined over
% an area where the coherence is OK.
% This is defined by taking the area of coherence > cohTH and further doing imclose with a disk region of diameter 2*localOPwinSize
% to include non-coherent region sorrounded by coherent regions (i.e. defects....)
%
% The quiverplot+localOP is plotted side by side by the original
% image(after adapthisteq) with the region with the filtered localOP
% defined indicated. This is used as the images for further manual anlysis
% of defects using the groundTruth app.
% INPUT
%   thisFileImName (assumes a png file)
%   mainDir
%   analysisParameters - contains all the analysis parameters
%   toSave - =1 for saving =0 for not saving
%   is4Images (optional) =0 (default), =1 if we have 4 images
% SAVES
%  1) file in [mainDir,'\LocalOP'] containing "localOP" (defined in mask) and
%   "filtLocalOP" (defined in regions with coherence>cohTH after imclose)
%  2) png image in [mainDir,'\Quiver'] of filtLocalOP overlaid with quiver with original Image with analysis region indicated

%% define folder names and analysis parameters
% define the relevant folders
dirRawImages=[mainDir,'\Raw Images']; % original images
dirImages=[mainDir,'\AdjustedImages']; %  images after image histogram adjustment
dirMasks=[mainDir,'\Masks']; % masks
dirOrientation=[mainDir,'\Orientation']; % masked orientation field
dirCoherence = [mainDir,'\Coherence']; % masked coherence field
dirQuiverGTL = [mainDir,'\QuiverGTL']; % figures showing plots of quiver
dirLocalOP = [mainDir,'\LocalOP']; % masked local order parameter field

cd(mainDir); mkdir(dirQuiverGTL); % make quiver folders

% define all parameters from analysisParameters
gradientsigma = analysisParameters(1); % Sigma of the derivative of Gaussian used to compute image gradients.
blocksigma = analysisParameters(2); % Sigma of the Gaussian weighting used to average the image gradients before defining the raw orientaion and reliability;
orientsmoothsigma = analysisParameters(3);  %  Sigma of the Gaussian used to further smooth orientation field
coherenceWinSize = analysisParameters(4);  %  Window size for the coherence calculation on the the raw orientation field
relTH = analysisParameters(5);  % this is the threshold for determining if the graident is relaible in a particular region. This is defined from the gradient field determiing if the gradient is strong enough
cohTH = analysisParameters(6);  % this is the threshold for the coherence in a region. This is determined from the local alignment of the raw orientation field (before the additional smoothing orientation field) and is used to define if there are ordered fibers in a given region
localOPwinSize = analysisParameters(7); % this is the window size used to calculate the local order parameter

%% load image from file and raw analysis output
try % load the image and raw analysis
    cd (dirImages); thisIm=importdata(thisFileImName);
    %     endName=strfind(thisFileImName,'.tif');
    endName=strfind(thisFileImName,'.png');
    thisFileImNameSave = thisFileImName (1:endName-1);
    cd (dirOrientation); load(thisFileImNameSave);
    cd (dirCoherence); load(thisFileImNameSave);
catch
    thisIm=[]; disp (['no image found ',thisFileImName]); % if no image is found
end
%% calculate downsampled orientation field, reliability and coherence by averaging over blocks of size blocksigma
meanFilterFunction = @(theBlockStructure) nanmean(theBlockStructure.data(:)) * ones(2,2, class(theBlockStructure.data)); % this version makes each values at grid point into 2x2 block; makes the  localOP  smoother
blocksigmaRnd= round(blocksigma); % make blocksigma an integer for the window averaging
% for the orientation the averaging has to be done carefully because of the phase jump:
%  <meantheta> = 0.5* atan( <sin(2*theta)>/<cos(2*theta)>)
blockyOI1 = blockproc(cos(2*orientation), [blocksigmaRnd,blocksigmaRnd], meanFilterFunction); % <cos(2*theta)>
blockyOI2 = blockproc(sin(2*orientation), [blocksigmaRnd,blocksigmaRnd], meanFilterFunction); % <sin(2*theta)>
blockyOI = atan2(blockyOI2,blockyOI1); blockyOI(blockyOI<0) = blockyOI(blockyOI<0)+2*pi; % this makes sure atan is beteween 0 and 2pi
DSorientation   =   0.5*blockyOI;
% for the coherence and reliability we simply use the window averaging
% DSreliability = blockproc(reliability, [blocksigmaRnd,blocksigmaRnd], meanFilterFunction); % this does averaging of reliability on block
DScoherence = blockproc(coherence, [blocksigmaRnd,blocksigmaRnd], meanFilterFunction); % this does averaging of coherence on block

%% calculate local order parameter
% now calculate the local order parameter on a bigger window size defined
% by localOPwinSize
winSize = round(2*localOPwinSize/blocksigmaRnd); % Define the winSize for local order parameter on dowsampled grid; we need a factor 2 since the block structure has a 2x2 structure
kernel = double(ones(winSize)/winSize^2); % Create averaging kernel for convolution which is a window of size winSize
% kernel = fspecial('gaussian',4*winSize,4); % Create averaging kernel for convolution
blockyOI11 = nanconv(blockyOI1, kernel); blockyOI22 = nanconv(blockyOI2, kernel); % Get means; here I use nanconv, to get more regions with non-NaN values; filtering will be done later
DSlocalOP = sqrt( blockyOI11.^2+ blockyOI22.^2); % Q = sqrt( <cos(2 theta)>^2+<sin(2 theta)>^2) averaged over winSize pixels
localOP = imresize(DSlocalOP, size(orientation)); % resize the local order parameter to the original image size
localOP(isnan(coherence))= NaN;% replace with NaNs outside mask
%% Define filtered local order parameter over relevant region
% 1st step (like used to determine coherent region for defining ordered region) First we define the region where the coherehce matrix is larger than cohTH and performs imopen, imclose to make
% it a simpler region  using the length scale from coherenceWinSize.
% 2nd step (to increase the region to include defect regions) - Dilates with scale winSize (that
% is used to define the local order paramter) to include regions in which
% the coherence is not high enough which will be defects and the imerode to
% remove not real defects near edges
% se1 = strel('disk',coherenceWinSize); se2 = strel('disk',localOPwinSize/2); % this generates a disk of diameter 2*coherenceWinSize for the first step and localOPwinSize for the second step
se1 = strel('disk',round(coherenceWinSize)); se2 = strel('disk',round(localOPwinSize)); % this generates a disk of diameter 2*coherenceWinSize for the first step and 2*localOPwinSize for the second step
coherence_map_NoNaN=coherence>cohTH; coherence_map_NoNaN(isnan(coherence))=0;
Scoherence=imopen (coherence_map_NoNaN,se1); Scoherence=imclose (Scoherence,se1); % simplify coherence>cohTH region as in FracOrdered analysis
Scoherence = simplifyMask (Scoherence, coherenceWinSize); % smooth the boundary of the mask with windowSize = coherenceWinSize
FOcoherence = Scoherence; % this includes regions which is defined as ordered in **** fracOrdered****
Scoherence=imclose (Scoherence,se2);  % imclose= dilate and erode the region with a disk of diameter localOPwinSize to include defects within the image but not include defects near the boundary
Scoherence = simplifyMask (Scoherence, coherenceWinSize); % smooth the boundary of the mask with windowSize = coherenceWinSize
filtLocalOP = localOP; filtLocalOP (~Scoherence) = NaN;  % the filtered localOP is defined only where the Scoherence is 1

%% For normal version with one image

ntot = numImages;

fullImSize2=size(thisIm,2); fullImSize1=size(thisIm,1); % size of input image
imSize2 = fullImSize2/ntot; imSize1 = fullImSize1;
theta=DSorientation(1:2:end,1:2:end); % this is the downsampled angle on the grid points
Dx=cos(theta);  % define the angle of the orientation
Dy=sin(theta); %
xVal=(1:blocksigmaRnd:fullImSize2)+(blocksigmaRnd/2-1); yVal=(1:blocksigmaRnd:fullImSize1)+(blocksigmaRnd/2-1); % generate  x and y values to map back to original image

for j=1:ntot,
    %% plot of quiver field (down sampled to 2*blocksigma) with local order parameter and original image with indication of region used for showing localOP
    quiverFig(j) = figure (j); clf; % quiver
    thisFiltLocalOP = variableSubimage(filtLocalOP, 2 ,ntot ,j); % take the jth subimage
    imshow(thisFiltLocalOP,[0 1]); colormap(jet); hold on;  % show order parameter
    q=quiver(xVal(1:2:end)-(j-1)*imSize2, yVal(1:2:end), Dx(1:2:end,1:2:end),Dy(1:2:end,1:2:end)); % plot the quiver with an additional factor 2 downsampling for better visualization
    q.LineWidth=1; % width of quiver lines
    q.ShowArrowHead = 'off'; % line with no arrowhead
    q.Color = [0 0 0]; % black quiver lines
    set(quiverFig,'Position',[50 400 imSize1 imSize2]); set(gca,'units','pixels'); % make the figure in original pixel size
    set(gca,'units','normalized','position',[0 0 1 1]);
    quiverImage = getframe(gca); quiverImage2 {j}= imresize(quiverImage.cdata,[imSize1,imSize2]); % this gets the quiver into an image variable of teh same size as the original image
    
    % plot original image after adaptive histogram with analysis region indicated
    nIm = variableSubimage(thisIm, 2 ,ntot ,j); % take the jth subimage along the 2 dimension
    minI =  min(min(nIm));
    maxI = max(max(nIm));
    nIm = round((nIm - minI)*(double(2^16-1)/double(maxI-minI)));
    thisScoherence =  variableSubimage(Scoherence, 2 ,ntot ,j); % take the jth subimage along the 2 dimension
    thisCoherence =  variableSubimage(coherence, 2 ,ntot ,j); % take the jth subimage
    
    % define analysis regions for RGB image
    maskedRegion = zeros(size(nIm)); maskedRegion (isnan(thisCoherence))= 20000 ; % in regions outside mask region show red highlight
    rgbImageWithAnalysisRegion {j}=  cat(3, nIm, nIm, nIm); % make rgb image r=in mask, g=original image, b=in analysis region
end

%% now make the composite images - option for 1 image (side by side composite)
if ntot==1,
    % now plot quiver with original image after adaptive histogram with analysis region indicated
    quiverPlot = cat(2, quiverImage2{1}, im2uint8(rgbImageWithAnalysisRegion{1})); % image of the quiver side by side with original image with analysis regions
end


%% now make the composite images - option for 1 image (side by side composite)
if ntot==2,
    % now plot quiver with original image after adaptive histogram with analysis region indicated
    quiverImageAll = cat(2, quiverImage2 {1}, quiverImage2 {2}); % image of the all quivers side by side 
    rgbImageWithAnalysisAll = cat(2, im2uint8(rgbImageWithAnalysisRegion{1}),im2uint8(rgbImageWithAnalysisRegion{2})); % image of the quiver side by side with original image with analysis regions
     quiverPlot = cat(1, quiverImageAll, rgbImageWithAnalysisAll); % image of the quiver side by side with original image with analysis regions
  end



%% now make the composite images - option for 1 image (all 4 on top and bottom)
if ntot==4,
    % now plot quiver with original image after adaptive histogram with analysis region indicated
    quiverImageAll = cat(2, quiverImage2 {1}, quiverImage2 {2},quiverImage2 {3},quiverImage2 {4}); % image of the all quivers side by side 
    rgbImageWithAnalysisAll = cat(2, im2uint8(rgbImageWithAnalysisRegion{1}),im2uint8(rgbImageWithAnalysisRegion{2}),im2uint8(rgbImageWithAnalysisRegion{3}),im2uint8(rgbImageWithAnalysisRegion{4})); % image of the quiver side by side with original image with analysis regions
     quiverPlot = cat(1, quiverImageAll, rgbImageWithAnalysisAll); % image of the quiver side by side with original image with analysis regions
  end

%% save the localOP and quiver plot
if toSave==1,
    endName=strfind(thisFileImName,'.png');
    thisFileImNameSave = thisFileImName (1:endName-1);
    cd(dirQuiverGTL); imwrite(quiverPlot,[thisFileImNameSave,'.png']) % %
    
end

end