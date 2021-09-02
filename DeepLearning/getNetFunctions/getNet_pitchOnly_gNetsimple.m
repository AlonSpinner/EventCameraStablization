function lgraph=getNet_pitchOnly_gNetsimple()
%% gNet
gNet=googlenet;
imageSize=[244,244,3];
gNetLayers=gNet.Layers;
gNetConnections=gNet.Connections;
%% Blocks
block1Layers=[... %block to add infront of gNet
    sequenceInputLayer(imageSize,'Name','data')
    sequenceFoldingLayer('Name','fold')
    ];
block2Layers=[... %block to add behind gNet
    flattenLayer('Name','flatten')
    sequenceUnfoldingLayer('Name','unfold')
    lstmLayer(8,'OutputMode','last','Name','lstm') %sequence to sequence regression
    
    fullyConnectedLayer(1,"Name","fcToPitch") %pitch
    regressionLayer("Name","regressionoutput")];
%% Join
lgraph = createLgraphUsingConnections(gNetLayers,gNetConnections);

layer2Replace=lgraph.Layers(1).Name;
lgraph=replaceLayer(lgraph,layer2Replace,block1Layers);

layers2Remove=lgraph.Layers(end-1:end);
lgraph=removeLayers(lgraph,...
    {layers2Remove(1).Name,layers2Remove(2).Name});

lgraph=addLayers(lgraph,block2Layers);

lgraph = connectLayers(lgraph,gNetLayers(end-2).Name,'flatten');
lgraph = connectLayers(lgraph,'fold/miniBatchSize','unfold/miniBatchSize');