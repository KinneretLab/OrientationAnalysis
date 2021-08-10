function initializeMovie (mainDir);
% function initializeMovie (mainDir)
% get all the parameters for analysis of the movie in mainDir

%% check if there is already a movieDetails file
cd(mainDir);
movieDetailsExist = 0;
if isfile('movieDetails.mat'), % if file already exist can skip the rest
    movieDetailsExist = 1;
end
%% if not ask user for input
if movieDetailsExist==0, % if the movieDetails file already  skip the rest
    startName = strfind(mainDir,'\');
    movieName = mainDir(startName(end)+1:end);
    dlgtitle =[ 'Input for movie: ',movieName];
    definput = {'1','1','1.28','','10','2',''}; % put here DEFAULT values for the movie info
    dims = [ 1.5  100];
    prompt = {...
        'Sample type [1=fragment, 2=ring, 3=strip 4=open ring]', ...
        'Environment [1= gel, 2= solution, 3=methyl cellulose]', ...
        'Calibration [in um/pix]', ...
        'Start time in minutes (after excision)', ...
        'Time interval in minutes (=0 for entering file)' , ...
        'Projection type [1=max projection, 2=layer separation]', ...
        'Frames to analyze (optional; in matlab format)'};
    
    answer = inputdlg(prompt,dlgtitle,dims,definput);
    sampleTypeDir = {'fragment', 'ring', 'strip', 'open ring'};
    sampleType = sampleTypeDir{str2num(answer{1})};
    environmentDir = {'gel', 'solution', 'methyl Celluluse'};
    environment = environmentDir{str2num(answer{2})};
    calibration = str2num(answer{3}); % in um/pix
    startTime = str2num(answer{4}); % time movie started after exxcision in minutes
    timeInterval = str2num(answer{5}); % time interval in minutes; if ==0 time stamp file will be entered
    if timeInterval == 0, % time stamps will be entered as file
        'will enter time in future'
    end
    projectionTypeDir = {'max','layer separation'};
    projectionType = projectionTypeDir{str2num(answer{6})};
    if size (answer{7})>0,
        frames  = str2num(answer{7});
    else
        frames = [];
    end
    cd(mainDir)
    save ('movieDetails','answer','sampleType','environment','calibration','startTime','timeInterval','projectionType','frames')
end
end




