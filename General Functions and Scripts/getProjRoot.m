function projectRoot=getProjRoot()
project     = simulinkproject();
projectRoot = project.RootFolder;
end