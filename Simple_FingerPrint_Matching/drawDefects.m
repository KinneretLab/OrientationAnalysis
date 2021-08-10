    clear all;

grid=8;% the grid used for the calcauluting the director field

cd('Z:\analysis\users\Yonit\Nematic Topological Defects')
imageDir='Rawimages8b';
dataDir='Matlab_data';
maskDir='Masks';
outputDirMask='OutputMasks2'; mkdir(outputDirMask);
outputDir='Output2';mkdir(outputDir);

imageList=dir(imageDir); % list the images for looping on all images

erodePixAll=[7 24 24 7 24 9 12 7 9]; % this sets the erode for each image manually
for j=3:length(imageList), % loop on images
    imageName=imageList(j).name;
    cd(dataDir)
    load(imageName(1:end-4));
    cd ..
    Xval=oriMap(:,1);
    Yval=oriMap(:,2);
    Xdir=oriMap(:,4);
    Ydir=oriMap(:,5);
    Energy=oriMap(:,8);
    Coherence=oriMap(:,7);
    
    co_t=0.2*max(Coherence);
    en_t=0.02*max(Energy);
    
    co_mask = (Coherence >=co_t);
    en_mask = (Energy >=en_t);
    
    cd('Masks')
    % mask=imread([imageName,'.tif']);
    mask=imread(imageName);
    cd ..
    
    %make mask for image by eroding saved mask 
%     erodePix=7; % fixed num of pixels for away from mask boundary
    erodePix=erodePixAll(j-2); % rakes value for manual list tailored for each image
    se = strel('ball',erodePix,erodePix);
    erodedMask = imerode(mask,se);
    
    %determine director field to plot
    plotPos=find(co_mask&en_mask); % check energy and coherence thresholds
    
    figure; %plot directors that pass threshold with mask
    imshow(erodedMask); hold on;
    for i=1:length(plotPos),
        
        if erodedMask( Yval(plotPos(i)),Xval(plotPos(i)))> 0, %if inside the image based mask plot black director
            plot([Xval(plotPos(i)), Xval(plotPos(i))+grid*Xdir(plotPos(i))], [Yval(plotPos(i)), Yval(plotPos(i))+grid*Ydir(plotPos(i))],'k-')
        else  %if outside the image based mask plot red director
            plot([Xval(plotPos(i)), Xval(plotPos(i))+grid*Xdir(plotPos(i))], [Yval(plotPos(i)), Yval(plotPos(i))+grid*Ydir(plotPos(i))],'r-')
        end
    end
    axis equal; axis ij;
    
    cd(outputDirMask)
    saveas(gcf,imageName);
    cd ..
    
    figure; %plot directors that pass threshold and are inside image mask without plotting the mask
    hold on;
    for i=1:length(plotPos),
        
        if erodedMask( Yval(plotPos(i)),Xval(plotPos(i)))> 0, %if inside the image based mask
            plot([Xval(plotPos(i)), Xval(plotPos(i))+grid*Xdir(plotPos(i))], [Yval(plotPos(i)), Yval(plotPos(i))+grid*Ydir(plotPos(i))],'k-')
        else
%             plot([Xval(plotPos(i)), Xval(plotPos(i))+grid*Xdir(plotPos(i))], [Yval(plotPos(i)), Yval(plotPos(i))+grid*Ydir(plotPos(i))],'r-')
        en    saveas(gcf,[imageName(1:end-3),'eps']);
    cd ..
end

