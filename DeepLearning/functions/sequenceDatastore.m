classdef sequenceDatastore < matlab.io.Datastore & ...
        matlab.io.datastore.MiniBatchable & ...
        matlab.io.datastore.Shuffleable
    
    properties
        Datastore
        SequenceDimension
        MiniBatchSize
        imageNetBackBone;
        angles;
        frameAmount;
        acceleration;
    end
    
    properties(SetAccess = protected)
        NumObservations
    end
    
    properties(Access = private)
        CurrentFileIndex
    end
    
    methods
        function ds = sequenceDatastore(folder)
            % ds = sequenceDatastore(folder) creates a sequence datastore
            % from the data in folder.
            
            % Create file datastore.
            fds = fileDatastore(folder, ...
                'ReadFcn',@readSequence, ...
                'IncludeSubfolders',false);
            ds.Datastore = fds;
            
            numObservations = numel(fds.Files);
            
            % Determine sequence dimension.
            X = preview(fds);
            ds.SequenceDimension = size(X,3);
            
            % Initialize datastore properties.
            ds.MiniBatchSize = 1;
            ds.NumObservations = numObservations;
            ds.CurrentFileIndex = 1;
            ds.imageNetBackBone = false;
            ds.angles=[1,2,3]; %pitch,roll,yaw - all as default
            ds.frameAmount=31;
            ds.acceleration=false;
        end
        
        function tf = hasdata(ds)
            % tf = hasdata(ds) returns true if more data is available.

            tf = hasdata(ds.Datastore);
        end
        
        function [data,info] = read(ds)
            % [data,info] = read(ds) read one mini-batch of data.
            
            miniBatchSize = ds.MiniBatchSize;
            info = struct;
            
            i = 0;
            while i < miniBatchSize && hasdata(ds.Datastore)
                %change size while iterating instead of prealocating
                %because need to check "hasdata" prior...
                i = i + 1;
                data=read(ds.Datastore);
                predictors{i,1} = data.sequence(:,:,1:ds.frameAmount);
                if ds.acceleration
                    rep=data.response(4:6); %acceleration
                else
                    rep=data.response(1:3); %omega
                end
                responses{i,1} = rep(ds.angles);
                ds.CurrentFileIndex = ds.CurrentFileIndex + 1;
            end
            
            data = preprocessData(predictors,responses,ds.imageNetBackBone);
        end
        
        function reset(ds)
            % reset(ds) resets the datastore to the start of the data.
            
            reset(ds.Datastore);
            ds.CurrentFileIndex = 1;
        end
        
        function dsNew = shuffle(ds)
            % dsNew = shuffle(ds) shuffles the files and the corresponding
            % labels in the datastore.
            
            % Create copy of datastore.
            dsNew = copy(ds);
            dsNew.Datastore = copy(ds.Datastore);
            fds = dsNew.Datastore;
            
            % Shuffle files and corresponding labels.
            numObservations = dsNew.NumObservations;
            idx = randperm(numObservations);
            fds.Files = fds.Files(idx);
        end
    end
    
    methods (Hidden = true)
        function frac = progress(ds)
            % frac = progress(ds) returns the percentage of observations
            % read in the datastore.
            
            frac = (ds.CurrentFileIndex - 1) / ds.NumObservations;
        end
    end
end
function data = preprocessData(predictors,responses,imageNetBackBone)
% data = preprocessData(predictors,responses) preprocesses
% the data in predictors and responses and returns the table
% data

miniBatchSize = size(predictors,1);

% Pad data to length of longest sequence.
sequenceLengths = cellfun(@(X) size(X,3),predictors);
maxSequenceLength = max(sequenceLengths);
for i = 1:miniBatchSize
    X = predictors{i};
    
    % Pad sequence with zeros.
    if size(X,3) < maxSequenceLength
        X(:,:,maxSequenceLength) = 0;
    end

    if imageNetBackBone
        X=fTransform4imageNet(X);
    else
        %extend dimension
        imageSize=[size(X,[1,2]),1];
        frameAmount=size(X,3);
        X=reshape(X,[imageSize,frameAmount]);
    end
    
    predictors{i} = X;
end

% Return data as a table.
data = table(predictors,responses);
end
function data = readSequence(folder)
% data = readSequence(filename) reads the sequence X from the MAT file
% filename
LoadData=load(folder);
data.sequence=LoadData.data.eventMask.Data;
data.response=LoadData.data.orientation.Data(end,4:end);
end
function newSequence=fTransform4imageNet(sequence)
imageSize=[244 244 3]; %imageNet data size
frameAmount=size(sequence,3);
sequence=imresize(sequence,imageSize(1:2));
newSequence=zeros([imageSize,frameAmount]);
for jj=1:frameAmount
    newSequence(:,:,:,jj)=cat(3,sequence(:,:,jj),sequence(:,:,jj),sequence(:,:,jj));
end
end