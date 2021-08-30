% This script defines a project shortcut. 
%
% To get a handle to the current project use the following function:
%
% project = simulinkproject();
%
% You can use the fields of project to get information about the currently 
% loaded project. 
%
% See: help simulinkproject
%% Load PROJECT 
project     = simulinkproject();
projectRoot = project.RootFolder;
%% Open Root Model:
% open('modelname');
%% Setting explicit folder for project generated code instead of being generated to "current folder" (which is default):
myCacheFolder = fullfile(projectRoot, 'Cash');
myCodeFolder  = fullfile(projectRoot, 'Code');

Simulink.fileGenControl('set',...
    'CacheFolder', myCacheFolder,...
    'CodeGenFolder', myCodeFolder,...
    'createDir', true);
%% Add project root to dictionary
% myDictionaryObj = Simulink.data.dictionary.open('Dictionary.sldd');
% dDataSectObj = getSection(myDictionaryObj,'Design Data');
% addEntry(dDataSectObj,'ProjRoot',projectRoot);
% myDictionaryObj.saveChanges();
%% clear variables from workspace
clear project projectRoot myCacheFolder myCodeFolder;