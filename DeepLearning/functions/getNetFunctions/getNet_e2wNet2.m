function lgraph=getNet_e2wNet2()
imageSize=[144,256,1];

layers = [...
    %block0
    sequenceInputLayer(imageSize,'Name','input')
    sequenceFoldingLayer('Name','fold')
    
    %block1
    convolution2dLayer([3 3],96,"Name","b1_conv","Padding","same")
    
    %block2
    convolution2dLayer([3 3],96,"Name","b2_conv","Padding","same")
    reluLayer("Name","b2_relu")
    maxPooling2dLayer([3,3],"Stride",[2,2],"Name","b2_maxpooling");
    
    %block3
    convolution2dLayer([3 3],48,"Name","b3_conv","Padding","same")
    reluLayer("Name","b3_relu")
    
    %block4
    convolution2dLayer([3 3],24,"Name","b4_conv","Padding","same")
    reluLayer("Name","b4_relu")
    
    %block5
    sequenceUnfoldingLayer('Name','unfold')
    flattenLayer('Name','flatten')
    
    %block6
    dropoutLayer(0.4,'Name','drop')
    lstmLayer(32,'OutputMode','last','Name','lstm') %inside sequence
    
    %block7
    fullyConnectedLayer(10,"Name","fc10");
    fullyConnectedLayer(3,"Name","fc") %[roll,pitch,yaw]
    regressionLayer("Name","regressionoutput")];

lgraph = layerGraph(layers);
lgraph = connectLayers(lgraph,'fold/miniBatchSize','unfold/miniBatchSize');