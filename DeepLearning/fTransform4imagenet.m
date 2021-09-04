function sequence_jj=fTransform4imagenet(sequence,imageSize)
sequence=imresize(sequence,imageSize(1:2));
sequence_jj=zeros([imageSize,frameAmount]);
for jj=1:frameAmount
    sequence_jj(:,:,:,jj)=cat(3,sequence(:,:,jj),sequence(:,:,jj),sequence(:,:,jj));
end