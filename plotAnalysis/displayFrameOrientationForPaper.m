function  displayFrameOrientationForPaper(thisFileImName, mainDir,mainDisplayDir, numImages)
% function  displayFrameOrientation(thisFileImName, mainDir, mainDisplayDir, is4Images)
% this function makes a display with the adjuted image + full mask outline
% and the localOP + quiver + highlighted region for non-ordered region
%
% INPUT
%   thisFileImName
%   mainDir
%   mainDisplayDir - output directory
%   is4Images =0 for a single image, =1 from 4 images
% SAVES
%   side by side images: orignial image and localOP + quiver + ordered region
%   in mainDisplayDir
%% define folders
analysisMainDir= [mainDir,'\Orientation_Analysis'];
dirImages=[analysisMainDir,'\AdjustedImages']; %  images after image histogram adjustment
dirMasks=[analysisMainDir,'\Masks']; % masks
dirOrientation=[analysisMainDir,'\Orientation']; % masked orientation field
dirReliability=[analysisMainDir,'\Reliability']; % masked relaibility field
dirCoherence = [analysisMainDir,'\Coherence']; % masked coherence field
dirLocalOP = [analysisMainDir,'\LocalOP']; % masked local order parameter field

%% load images and parameters
cd(analysisMainDir); load('AnalysisSummary'); % load analysis parameters
cd (dirImages); thisIm=importdata(thisFileImName);
%     endName=strfind(thisFileImName,'.tif');
endName=strfind(thisFileImName,'.png');
thisFileImNameSave = thisFileImName (1:endName-1);
cd (dirLocalOP); load(thisFileImNameSave);

try % load the corresponding mask
    cd (dirMasks); thisMask=importdata([thisFileImNameSave,'.tif']); 
catch
   cd (dirMasks); thisMask=importdata([thisFileImNameSave,'.tiff']); 
end

% these are the parameters defining how bright the non-ordered regions are
opacityOP = 0.66; % this detemines how bright the regions outside where filtLocalOP is defined will be (the more relaxed condition that takes into accout the size used to define the localOP)
opacityMaskOverlay =0.33; % this detemines the opacity of the mask overlaying regions which are defined as ordered

imSize2=size(thisIm,2); imSize1=size(thisIm,1); % size of input image
blocksigma = analysisParameters(2); % Sigma of the Gaussian weighting used to average the image gradients before defining the raw orientaion and reliability;
coherenceWinSize = analysisParameters(4);  %  Window size for the coherence calculation on the the raw orientation field
%% make mask region more smooth and make full mask (dilate and then smooth)
 isInMask = ~isnan(localOP); % this is original mask wihtout dilating
% % dilate the mask to get roughly the outline of the fluor image; value of
% % 20 seemed reasonble for spinning disk images
% SE = strel('disk',20);
% isInMaskDilate = imdilate (isInMask,SE); % this is original mask after dilating
% isInMaskFull = simplifyMask (isInMaskDilate,coherenceWinSize); % this is the full mask after smoothing the dilated mask with scale coherenceWinSize
isInMaskFull = thisMask>0;
%% prepare the RGB image of the localOP with indication of masked region and highlighting the regions where filtOP is not defined
% make localOP into RGB image
localOP_RGB= ind2rgb(im2uint8(localOP)+1,jet(256));
% make the localOP in regions where filtLocalOP is not defined (which are
% typically the boundaries) be brighter (and hence less visible)
maskOP = isnan(filtLocalOP); % this is the region where filtLocalOP is not defined
mask2OP = cat(3, maskOP, maskOP, maskOP);
localOP_RGB (mask2OP) = min(localOP_RGB (mask2OP) + opacityOP,1);
% define the localOP from regions outside the mask as black
mask2RGB = cat(3, ~isInMask, ~isInMask, ~isInMask);
% localOP_RGB(mask2RGB)=0.5; %
localOP_RGB(mask2RGB)=0;
%% make a nice figure of the local OP which shows the ordered regions and disordered regions (with a mask) and overlays the quiver
%% For normal version with one image

ntot = numImages;

blocksigmaRnd= round(blocksigma); % make blocksigma an integer for the window averaging
fullImSize2=size(thisIm,2); fullImSize1=size(thisIm,1); % size of input image
imSize2 = fullImSize2/ntot; imSize1 = fullImSize1;
theta=DSorientation(1:2:end,1:2:end); % this is the downsampled angle on the grid points
Dx=cos(theta);  % define the angle of the orientation
Dy=sin(theta); %
xVal=(1:blocksigmaRnd:fullImSize2)+(blocksigmaRnd/2-1); yVal=(1:blocksigmaRnd:fullImSize1)+(blocksigmaRnd/2-1); % generate  x and y values to map back to original image


%% FOR PAPER - TO REDUCE FILE SIZE WE USE SMALLER IMAGES
shrinkFactor = 0.25; % the factor by which to reduce the images


%%
for j=1:ntot,
    %% plot of quiver field (down sampled to 2*blocksigma) with local order parameter and original image with indication of region used for showing localOP
    quiverFig(j) = figure (j); clf; % quiver
    thisLocalOP_RGB = variableSubimage(localOP_RGB, 2 ,ntot ,j); % take the jth subimage
    imshow(thisLocalOP_RGB,[0 1]); colormap(jet); hold on;  % show order parameter
%     imshow(thisLocalOP_RGB,[0 1],'initialMagnification',100*shrinkFactor); colormap(jet); hold on;  % show order parameter ; define desired zoom
    q=quiver(xVal(1:2:end)-(j-1)*imSize2, yVal(1:2:end), Dx(1:2:end,1:2:end),Dy(1:2:end,1:2:end)); % plot the quiver with an additional factor 2 downsampling for better visualization
    q.LineWidth=1; % width of quiver lines
    q.ShowArrowHead = 'off'; % line with no arrowhead
    q.Color = [0 0 0]; % black quiver lines
    set(quiverFig(j),'Position',[50 50 imSize1 imSize2]); set(gca,'units','pixels'); % make the figure in original pixel size
    set(gca,'units','normalized','position',[0 0 1 1]);
    thisFOcoherence =  variableSubimage(FOcoherence, 2 ,ntot ,j); % take the jth subimage    
    overlayFO = showMaskAsOverlay (opacityMaskOverlay, ~thisFOcoherence,[1 1 1]); % FOcoherence is the places defined as fraction ordered
    % overlayFO = showMaskAsOverlay (opacityMaskOverlay, and(~FOcoherence,isInMaskFull),[1 1 1]);
    contour = bwboundaries(isInMaskFull); % define outline of the full mask 
    plot(contour{j}(:,2)-(j-1)*imSize2,contour{j}(:,1),'w--','LineWidth',1); % plot the full mask contour on the image
%     set(gca,'units','normalized','position',[0 0 1 1]);
set(gca,'units','normalized','position',[0 0 2*shrinkFactor 2*shrinkFactor]);
%     axis off;  axis image ij; % get rid of region around image
    quiverImage = getframe(gca); quiverImage2{j} = imresize(quiverImage.cdata,round([imSize1,imSize2]*shrinkFactor));% this gets the quiver into an image variable of teh same size as the original image
%     quiverImage = getframe(gca); quiverImage2{j} = imresize(quiverImage.cdata,[imSize1,imSize2]);% this gets the quiver into an image variable of teh same size as the original image
    
    % plot original image after adaptive histogram with analysis region indicated
    nIm = variableSubimage(thisIm, 2 ,ntot ,j); % take the jth subimage along the 2 dimension
    figure (j+ntot); clf;
    imshow(cat(3,zeros(size(nIm)),nIm, zeros(size(nIm)))); hold on
    linecolor = [0.8 0.8 0.8];
    plot(contour{j}(:,2)-(j-1)*imSize2,contour{j}(:,1),'--','color', linecolor,'LineWidth',1); % plot the full mask contour on the image
    % plot(contour{j}(:,2),contour{j}(:,1),'--','color', 'w','LineWidth',1); % plot the full mask contour on the image
    set(gca,'units','normalized','position',[0 0 1 1]);
%     frameImage = getframe(gca); frameImage2{j} = imresize(frameImage.cdata,[imSize1,imSize2]);
    frameImage = getframe(gca); frameImage2{j} = imresize(frameImage.cdata,round([imSize1,imSize2]*shrinkFactor));
end

%% now make the composite images - option for 1 image (side by side composite)
if ntot==1,
%     finalDisplay = cat(2, frameImage2{1}, quiverImage2{1}); % image of the quiver side by side with original image
    finalDisplay = cat(1, frameImageAll2{1}, quiverImageAll2{1}); % image of the quiver side by side with original image with analysis regions
end
%% now make the composite images - option for 2 images (all 2 on top and bottom)
if ntot==2,
    % now plot quiver with original image after adaptive histogram with analysis region indicated
    quiverImageAll = cat(2, quiverImage2 {1}, quiverImage2 {2}); % image of the all quivers side by side
    frameImageAll = cat(2, frameImage2{1},frameImage2{2}); % image of the original image with outline
%     finalDisplay = cat(1, quiverImageAll, frameImageAll); % image of the quiver one below the other with original image with analysis regions
    finalDisplay = cat(1, frameImageAll, quiverImageAll); % image of the quiver side by side with original image with analysis regions
%     finalDisplay(:,imSize2:imSize2+1,:)=1;finalDisplay(:,2*imSize2:2*imSize2+1,:)=1;
end
%% now make the composite images - option for 4 images (all 4 on top and bottom)
if ntot==4,
    % now plot quiver with original image after adaptive histogram with analysis region indicated
    quiverImageAll = cat(2, quiverImage2 {1}, quiverImage2 {2},quiverImage2 {3},quiverImage2 {4}); % image of the all quivers side by side
    frameImageAll = cat(2, frameImage2{1},frameImage2{2},frameImage2{3},frameImage2{4}); % image of the original image with outline
%     finalDisplay = cat(1, quiverImageAll, frameImageAll); % image of the quiver side by side with original image with analysis regions
    finalDisplay = cat(1, frameImageAll, quiverImageAll); % image of the quiver side by side with original image with analysis regions
%     finalDisplay(:,imSize2:imSize2+1,:)=1;finalDisplay(:,2*imSize2:2*imSize2+1,:)=1;finalDisplay(:,3*imSize2:3*imSize2+1,:)=1;
end

%% save the images as one combined image
cd(mainDisplayDir); imwrite(finalDisplay,[thisFileImNameSave,'.png']) % %

end