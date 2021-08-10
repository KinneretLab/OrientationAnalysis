function [] = extractAllDefects(k, dirLocalOP, thisFileImNameBase,gTruth,dirDataDefect)
% Runs over all types of defects and extracts information from Ground Truth
% Labeler format.
 cd(dirLocalOP); load(thisFileImNameBase); % load the localOP to find the defect location
%     
%     thisImWithDefect = thisIm; % this is the new image we will add annotations on
%     % check if the image is a side by side image or single image
%     if size(thisIm,2)> size(localOP,2),
%         duplicateImages=1; % side by side image- defects need to be duplicated
%     else
%         duplicateImages=0; % single image- defects defects plotted once
%     end
    
    numDefects(k)=0; % initialize numdefects
    fields = {'type','position','angle','ID','distance'}; c = cell(length(fields),1); c = cell2struct(c,fields); defect = c([]); defectList = c([]);  % initialize defectList and defect as empty structures
    
    ind = find(contains(gTruth.DataSource.Source,thisFileImNameBase));
    
    if or(or( size(gTruth.LabelData.h{ind})>0, size(gTruth.LabelData.mh{ind})>0),size(gTruth.LabelData.o{ind})>0) % if we have any defects in thisFrame defects
        if size(gTruth.LabelData.h{ind})>0 % read in all the half defects
            for j=1: length(gTruth.LabelData.h{ind}),
                numDefects(k) = numDefects(k)+1;
                thisDefect=gTruth.LabelData.h{ind}(j); typeDefect = 'half';
                [defPosition , defAngle] = extractDefectInfo (localOP, thisDefect, typeDefect);
                defectList(numDefects(k)).type=1/2; % now Insert the relevant information for this defect
                defectList(numDefects(k)).position= defPosition;
                defectList(numDefects(k)).angle= defAngle;
                defectList(numDefects(k)).ID=thisDefect.ID;
                
            end
        end
        if size(gTruth.LabelData.mh{ind})>0
            for j=1: length(gTruth.LabelData.mh{ind}),% read in all the minus half defects
                numDefects(k) = numDefects(k)+1;
                thisDefect=gTruth.LabelData.mh{ind}(j); typeDefect = 'mhalf';
                [defPosition , defAngle] = extractDefectInfo (localOP, thisDefect, typeDefect);
                defectList(numDefects(k)).type=-1/2; % now Insert the relevant information for this defect
                defectList(numDefects(k)).position= defPosition;
                defectList(numDefects(k)).angle= defAngle;
                defectList(numDefects(k)).ID=thisDefect.ID;
                
            end
        end
        if size(gTruth.LabelData.o{ind})>0
            for j=1: length(gTruth.LabelData.o{ind}),% read in all the one defects
                numDefects(k) = numDefects(k)+1;
                thisDefect=gTruth.LabelData.o{ind}(j); typeDefect = 'one';
                [defPosition , defAngle] = extractDefectInfo (localOP, thisDefect, typeDefect);
                defectList(numDefects(k)).type=1; % now Insert the relevant information for this defect
                defectList(numDefects(k)).position= defPosition;
                defectList(numDefects(k)).angle= defAngle;
                defectList(numDefects(k)).ID=thisDefect.ID;
                
            end
        end
    end
    %     figure; imshow (thisImWithDefect); title(num2str(k));
    
    %% 
    % now reorganize the defect strutcture for this frame according to
    % defectID and save it as a structure "defect"
    defectIDs = [defectList.ID]; % this contains the ID of all the defects found in this frame
    defectTypes = [defectList.type];
    for i=1:length(defectList),
        if length(unique(defectIDs))<length(defectIDs)&&length(unique(defectTypes))<length(defectTypes) % if there are multiple defects with the same ID- display warning
            display (['Defects in frame ',num2str(k), 'do not have unique IDs'])
            defect(defectIDs(i))=defectList(i); % the structure defect now contains all the defect information so that defect(n) is the defect with ID n
        end
        defect(i)=defectList(i); % the structure defect now contains all the defect information so that defect(n) is the defect with ID n
    end
    cd(dirDataDefect); save(thisFileImNameBase, 'defect'); % save the organizaed defect structure for this frame
end

