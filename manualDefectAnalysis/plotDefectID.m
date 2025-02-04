function [thisImWithDefect, defPosition, defAngle] = plotDefectID (thisIm, localOP, thisDefect, typeDefect)
% [thisImWithDefect, defPosition, defAngle] = plotDefect (thisIm, localOP, thisDefect, typeDefect)
% This function gets an image, the localOP, and the defect structure for this
% defect (which is of the format generated by ground truth app) of type
% typeDefect. The output is the exact position of the defect (determined as
% the position of the minima of the localOP in the rectangle defined by
% thisDefect), orientation of the defect in degrees based on the line
% direction in thisDefect, and an thisIm overlayed with an annotation of
% this defect added.
% IN THIS VERSION COLOR OF ANNOTATION IS BASED ON DEFECT ID
%
% INPUT
%   thisIM - the images that the defects indicators will be overlaid on
%   localOP - the local parameter matrix which is used for detetemining the
%   exact position of the defects in the rectangle
%   thisDefect - the defect structure that is output from the groundTruth app
%   typeDefect - "one", "half", "mhalf" indicates the type of defects and
%   generate appropriate defect indication on image
% OUTPUT
%   thisImWithDefect - image with defect plotted on it according to type
%   defPosition - [x,y]=[col,row] position of defect in image
%   defAngle - angle in degrees of 
%% find the exact defect position within the rectangle
defRectPosition = round(thisDefect.Position); % input defect rectangle and round
end1=defRectPosition(2)+defRectPosition(4); end2=defRectPosition(1)+defRectPosition(3); % find outer sides of defect
if end1>size(localOP,1), end1=size(localOP,1),end % prevent crashes if the rectangle ends outside the image by defining the end as the image boundary
if end2>size(localOP,2), end2=size(localOP,2),end
localOPRegion =  localOP (defRectPosition(2):end1, defRectPosition(1):end2); % define the localOP matrix within the rectangle
[minval,idx]=min(localOPRegion(:)); % find minima in localOP within the rectangle
[row,col]=ind2sub(size(localOPRegion), idx); row = row + defRectPosition(2); col = col + defRectPosition(1); % find index location of minima in original pixel values
defPosition = [col row]; % this contains the row and column for the position of the defect
%% find defect orientation; for now we're not doing anything with it; but for later
if or(strcmp(typeDefect,'half'),strcmp(typeDefect,'mhalf')), % defect types which have an orientation
try
defLine=thisDefect.dir.Position; % now determine defect orientation
slope = -(defLine(2,2) - defLine(1,2)) ./ (defLine(2,1) - defLine(1,1)); % slope = - deltay/deltax; the minus sign is because the axis image reflect the y-axis
defAngle = atand(slope); if defAngle<0, defAngle=defAngle+180; end % map the defect in degrees to be between 0 and 180
catch
   defAngle=NaN; % no dir was associated with this defect 
end
else
    defAngle=NaN; % one defect have no orientation so put as NaN
end
   
%% now add an annotation of the defect on image; use different shapes for different defect types
label = thisDefect.ID; % this puts a label with the defect ID on the movie
markerSize = 32; % size of marked area around defects
colorList= {'cyan','green','yellow','red','blue','magenta', 'black', 'white'}; % this defines the color of defects 
if strcmp(typeDefect,'one') % one defects
    position = [defPosition,markerSize ]; % draws a circle of radius markerSize around the defect position
    thisImWithDefect = insertObjectAnnotation(thisIm,'circle',position,label,'LineWidth',3,'Color',colorList{label},'TextColor','black');
end

if strcmp(typeDefect,'half') % half defects
    rectCorner=defPosition-0.5*[markerSize,2*markerSize];  % draws a rectangle of sides markerSize, 2* markersize
    position = [rectCorner,markerSize,2*markerSize ];
    thisImWithDefect = insertObjectAnnotation(thisIm,'rectangle',position,label,'LineWidth',3,'Color',colorList{label},'TextColor','black');
end

if strcmp(typeDefect,'mhalf') % minus half defects
    rectCorner=defPosition-0.5*[2*markerSize,markerSize];   % draws a rectangle of sides 2* markersize,  markerSize
    position = [rectCorner,2*markerSize,markerSize ];
    thisImWithDefect = insertObjectAnnotation(thisIm,'rectangle',position,label,'LineWidth',3,'Color',colorList{label},'TextColor','black');
end
%     figure; imshow(thisImWithDefect)
end
