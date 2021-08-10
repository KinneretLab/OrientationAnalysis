
 %% add the neededs path for the analysis
clear all
addpath(genpath('\\phhydra\data-new\phhydra\Analysis\users\Yonit\MatlabCodes\'));
addpath(genpath('\\phhydra\data-new\phhydra\Analysis\users\Yonit\Nematic Topological Defects\NematicMatlabAnalysis'));
codeDir='\\phhydra\data-new\phhydra\Analysis\users\Yonit\Nematic Topological Defects\NematicMatlabAnalysis';

warning('off', 'MATLAB:MKDIR:DirectoryExists');% this supresses warning of existing directory
%% define mainDirList

topMainDir='\\phhydra\data-new\phhydra\Analysis\users\Yonit\Movie_Analysis\'; % main folder for movie analysis
mainDirList= { ... % enter in the following line all the all the movie dirs to be analyzed
'2019_06_03_FEP_6hr', ...
'2019_06_03_FEP_24hr', ...
'2019_06_03_FEP_48hr', ...

};
for i=1:length(mainDirList),mainDirList{i}=[topMainDir,mainDirList{i}];end

%% run raw analysis to get orientation, reliability and coherence fields,local OP, fraction ordered and plot quiver  
for i=1:length(mainDirList)
    mainDir=[mainDirList{i},'\Orientation_Analysis\'];
    cd(mainDir);
    thisFrac = load('fracOrdered2.mat');
    Create_order_pie_chart(mainDirList{i}, thisFrac.fracOrdered);
end