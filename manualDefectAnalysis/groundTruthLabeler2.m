function groundTruthLabeler2(varargin)
%groundTruthLabeler Label ground truth data in video, image sequence or
%custom data source.
%
%   groundTruthLabeler invokes the Ground Truth Labeler app for labeling
%   ground truth data in a video, an image sequence  or custom data source.
%   This app is used to interactively specify rectangular and polyline
%   Regions of Interest (ROIs), and Scene labels, which together define
%   ground truth data that can be used for comparison against an algorithm
%   or training a classifier.
%
%   groundTruthLabeler(videoFileName) invokes the app and loads the video
%   videoFileName.
%
%   groundTruthLabeler(imageSeq) invokes the app and loads the image
%   sequence imageSeq. imageSeq can be one of the following:
%       - a string or cell array of character vectors specifying image
%         file names (image files must be in the same directory)
%       - a scalar string or character vector specifying folder
%         containing image files (image files must have extensions
%         supported by imformats and are loaded in the order returned by
%         DIR)
%
%   groundTruthLabeler(imageSeq, timeStamps) invokes the app and loads each
%   image specified in imageSeq associated with a timestamp from
%   timeStamps. timeStamps is a duration vector of the same length as the
%   number of images in the sequence. If timeStamps is not specified, a
%   default of seconds(0 : numel(imageNames)-1) is used.
%
%   groundTruthLabeler(gtSource) invokes the app and loads data from the
%   data source gtSource. gtSource must be a groundTruthDataSource object
%   created from a video file, image sequence or custom reader.
%
%   groundTruthLabeler(sessionFile) invokes the app and loads a saved
%   Ground Truth Labeling session. sessionFile is the path to the MAT file
%   containing the saved session.
%
%   groundTruthLabeler(..., Name, Value) specifies additional name-value
%   pair arguments as described below:
%
%   'ConnectorTargetHandle'   Handle to a <a href="matlab:help('driving.connector.Connector')">Connector</a> class that implements a
%                             custom analysis or visualization tool time
%                             synchronized with the Ground Truth Labeler.
%                             For example, to associate a connector target
%                             defined in class MyConnectorClass, specify
%                             the handle as @MyConnectorClass.
%
%
%   Notes
%   -----
%   - Define and execute custom algorithms within the Ground Truth Labeler
%     app by creating an <a href="matlab:help('vision.labeler.AutomationAlgorithm')">AutomationAlgorithm</a>.
%
%   - Load data from a custom image or video data source by creating a
%     <a href="matlab:help('groundTruthDataSource')">groundTruthDataSource</a> object.
%
%
%   Example 1: Open Ground Truth Labeler with an image sequence
%   ---------------------------------------------------------
%   % This example shows how to open the Ground Truth Labeler app with a
%   % sequence of images located in a folder.
%
%   % Specify path for the image sequence directory.
%   imageDir = fullfile(toolboxdir('driving'), 'drivingdata', ...
%       'roadSequence');
%
%   % Load time stamps corresponding to the image sequence
%   load(fullfile(imageDir,'timeStamps.mat'))
%
%   % Open Ground Truth Labeler with image sequence
%   groundTruthLabeler(imageDir, timeStamps)
%
%
%   Example 2: Open Ground Truth labeler with a custom reader
%   -------------------------------------------------------
%   % This example shows how to open the Ground Truth Labeler app with a
%   % custom reader. A custom reader can be used to read image sequence
%   % data in a custom format that cannot be opened using imread or
%   % VideoReader. In this example, a custom reader is created using an
%   % image data store.
%
%   % Specify path for the image sequence directory.
%   imageDir = fullfile(toolboxdir('driving'), 'drivingdata', ...
%       'roadSequence');
%
%   % Load time stamps corresponding to the image sequence
%   load(fullfile(imageDir,'timeStamps.mat'))
%
%   % Use an image data store as a custom data source
%   imds = imageDatastore(imageDir);
%
%   % Write a reader function to read images from the data source. The
%   % first input argument to readerFcn, sourceName is not used. The
%   % 2nd input, currentTimeStamp is converted from a duration scalar
%   % to a 1-based index suitable for the data source.
%   frameInterval = seconds(timeStamps(2)-timeStamps(1));
%   readerFcn = @(~,idx)readimage(imds,floor(seconds(idx)/frameInterval)+1);
%
%   % Create data source for images in imageDir using readerFcn
%   gtSource = groundTruthDataSource(imageDir, readerFcn, timeStamps);
%
%   % Open Ground Truth Labeler with created data source
%   groundTruthLabeler(gtSource)
%
%
%   Example 3: Displaying Lidar data synchronized with video
%   ------------------------------------------------------
%   % This example shows how to use 'ConnectorTargetHandle' name-value
%   % pair and custom connector code in order to display Lidar
%   % data synchronized with the input video.
%
%   groundTruthLabeler('01_city_c2s_fcw_10s.mp4','ConnectorTargetHandle',@LidarDisplay);
%
%   % The connector LidarDisplay.m was written specifically for this example
%   % and needs to be modified to process and display any other data.
%
%   See also imageLabeler, groundTruth, groundTruthDataSource,
%   objectDetectorTrainingData, pixelLabelTrainingData,
%   vision.labeler.AutomationAlgorithm, driving.connector.Connector.

%   Copyright 2015-2017 The MathWorks, Inc.
% KK CHANGED THIS FUNCTION 
% NOW GETS THE SESSION MAT FILE WITH THE LABEL
% DEFINITIONS AS FIRST INPUT AND THE FOLDER FOR THE IMAGE SEQUENCE AS THE
% SECOND INPUT AND OPENS THEM IN THE SAME GROUNDTRUTHAPP

narginchk(0,4)

[hasCustomDisplay, connectorTargetHandle] = parseCustomDisplay(varargin{:});


firstArg = varargin{1};
fileName = validateName(firstArg);

[sessionPath,sessionFileName] = loadSessionFile(fileName);

tool = openApp;
tool.doLoadSession(sessionPath, sessionFileName, ...
    hasCustomDisplay, connectorTargetHandle);

secondArg = varargin{2};
fileName2 = validateName(secondArg);

if isImageDir(fileName2)
    
    imds = loadImageSequence(fileName2);
    numFiles = numel(imds.Files);
    timestamps = 1:numFiles;
    
    driving.internal.videoLabeler.validation.validateImageSequenceAndTimestamps(imds, timestamps);
    
    %     tool = openApp;
    %     addCustomDisplayIfAny(tool, connectorTargetHandle);
    tool.doLoadVideo(imds, timestamps, false);
end
%
%         % Load groundTruthDataSource object
%         if isGroundTruthDataSource(firstArg)
%             if iscell(firstArg.Source)
%                 sourceName = fileparts(firstArg.Source{1});
%             else
%                 sourceName = firstArg.Source;
%             end
%             timestamps = firstArg.TimeStamps;
%
%             if isVideoFileSource(firstArg)
%                 processDataSourceInputs(connectorTargetHandle,sourceName);
%             elseif isImageSequenceSource(firstArg)
%                 processDataSourceInputs(connectorTargetHandle,sourceName, timestamps);
%             else
%                 readerFunction = firstArg.Reader.Reader;
%                 % Custom data source
%                 processDataSourceInputs(connectorTargetHandle,sourceName, readerFunction, timestamps);
%             end
%
%             return;
%         end
%     end
%
%     % If we get here, the user provided video, image sequence. Custom data
%     % source must be specified using the groundTruthDataSource syntax.
%     processDataSourceInputs(connectorTargetHandle, varargin{:});
%
% end
end
%
% %--------------------------------------------------------------------------
function processDataSourceInputs(connectorTargetHandle, varargin)

fileName = validateName(varargin{1});

if isCustomDataSource(varargin{:})
    readerFunction = varargin{2};
    timestamps = validateTimes(varargin{3});
    
    % Invoke custom reader function on 1st timestamp to
    % validate the reader.
    vision.internal.labeler.validation.validateCustomReaderFunction(readerFunction, fileName, timestamps)
    
    tool = openApp;
    addCustomDisplayIfAny(tool, connectorTargetHandle);
    tool.doLoadVideo(readerFunction, fileName, timestamps, false);
    
    % Load image sequence
elseif isImageDir(fileName)
    
    imds = loadImageSequence(fileName);
    numFiles = numel(imds.Files);
    timestamps = getTimestamps(connectorTargetHandle,numFiles,varargin{:});
    
    driving.internal.videoLabeler.validation.validateImageSequenceAndTimestamps(imds, timestamps);
    
    tool = openApp;
    addCustomDisplayIfAny(tool, connectorTargetHandle);
    tool.doLoadVideo(imds, timestamps, false);
    
    % Load video file
elseif isVideoFile(fileName)
    tool = openApp;
    addCustomDisplayIfAny(tool, connectorTargetHandle);
    tool.doLoadVideo(fileName);
    
    hasCustomDisp = ~isempty(connectorTargetHandle);
    if (~hasCustomDisp && nargin>2) || (hasCustomDisp && nargin>4)
        warning(message('driving:groundTruthLabeler:noTimestampsWithVideo'))
    end
    
    % We don't know what this is...
else
    error(message('driving:groundTruthLabeler:InvalidFile', fileName))
end
end

function timestamps = getTimestamps(connectorTargetHandle,numFiles,varargin)
hasCustomDisplay = ~isempty(connectorTargetHandle);
numVarArgs = length(varargin);

% inputs are:
% varargin =
% Without custom display
% -----------------------
% {folderName,durations}
% {folderName}

% With custom display
% --------------------
% {folderName,durations,  ConnectorTargetHandle,@ClassHandle}
% {folderName,            ConnectorTargetHandle,@ClassHandle}

if (hasCustomDisplay && (numVarArgs == 4)) || ...
        (~hasCustomDisplay && (numVarArgs == 2))
    timestamps = validateTimes(varargin{2});
else
    timestamps = seconds(0 : numFiles-1);
end
end
%--------------------------------------------------------------------------
function [hasCustomDisplay, connectorTargetHandle] = parseCustomDisplay(varargin)

connectorTargetHandle = [];
hasCustomDisplay = false;
if nargin >=2
    isValidFcnHandle = isa(varargin{end},'function_handle');
    isValidName = strcmpi(varargin{end-1}, 'ConnectorTargetHandle');
    
    if isValidName && isValidFcnHandle
        connectorTargetHandle = varargin{end};
        validateConnectorClassHandle(connectorTargetHandle);
        hasCustomDisplay = true;
    elseif isValidName && ~isValidFcnHandle
        error(message('driving:groundTruthLabeler:NotAFunctionHandle'));
    elseif ~isValidName && isValidFcnHandle
        error(message('driving:groundTruthLabeler:InvalidName'));
    end
end
end

%--------------------------------------------------------------------------
function validateConnectorClassHandle(funcHandle)
funcName = func2str(funcHandle);

% Does the class exist?
isOnPath = exist(funcName, 'class')==8;
if ~isOnPath
    error(message('driving:groundTruthLabeler:connectorNotOnPath', funcName))
end

% Is the class inherited from a Connector.
metaClass = meta.class.fromName(funcName);
if ~isempty(metaClass)
    baseClassList = metaClass.SuperclassList;
    if ~isempty(baseClassList)
        isAConnector = any( strcmp({baseClassList.Name}, 'driving.connector.Connector') );
    else
        isAConnector = false;
    end
else
    isAConnector = false;
end

if ~isAConnector
    error(message('driving:groundTruthLabeler:notAConnector', funcName));
end

end

%--------------------------------------------------------------------------
function fileName = validateName(fileName)
% Name must be scalar text.
validateattributes(fileName, {'string','char'}, {'scalartext','nonempty'});

% Convert to char.
fileName = char(fileName);
end

%--------------------------------------------------------------------------
function timestamps = validateTimes(timestamps)
validateattributes(timestamps, {'double', 'duration'}, ...
    {'nonempty','vector'}, mfilename, 'Timestamps');

if ~isduration(timestamps)
    timestamps = seconds(timestamps);
end

if ~iscolumn(timestamps)
    timestamps = reshape(timestamps, numel(timestamps), 1);
end

end

%--------------------------------------------------------------------------
function addCustomDisplayIfAny(tool, connectorTargetHandle)
if ~isempty(connectorTargetHandle)
    tool.addCustomDisplay(connectorTargetHandle);
end
end

%--------------------------------------------------------------------------
function tool = openApp()
tool = driving.internal.videoLabeler.tool.VideoLabelingTool;
tool.show();
end

%--------------------------------------------------------------------------
function closeAllApps()
driving.internal.videoLabeler.tool.VideoLabelingTool.deleteAllTools;
end

%--------------------------------------------------------------------------
function TF = isSessionFile(fileName)
[~,~,ext] = fileparts(fileName);
TF = strcmpi(ext,'.mat') || exist([fileName,'.mat'],'file');
end

%--------------------------------------------------------------------------
function TF = isImageDir(fileName)
TF = isdir(fileName);
end

%--------------------------------------------------------------------------
function TF = isGroundTruthDataSource(fileName)
TF = isa(fileName,'groundTruthDataSource');
end

%--------------------------------------------------------------------------
function TF = isVideoFile(fileName)
TF = exist(fileName, 'file')==2;
end

%--------------------------------------------------------------------------
function TF = isCustomDataSource(varargin)
TF = nargin>1 && isa(varargin{2},'function_handle');
end

%--------------------------------------------------------------------------
function [sessionPath,sessionFileName] = loadSessionFile(fileName)
try
    [sessionPath, sessionFileName] = vision.internal.calibration.tool.parseSessionFileName(fileName);
catch ME
    error(message('driving:groundTruthLabeler:FileNotFound', fileName));
end
end

%--------------------------------------------------------------------------
function imds = loadImageSequence(fileName)
try
    imds = imageDatastore(fileName);
catch
    error(message('vision:groundTruthDataSource:InvalidFolderContent'))
end
end
