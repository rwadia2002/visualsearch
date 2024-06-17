%% EEE3032 - Computer Vision and Pattern Recognition (ee3.cvpr)
%%
%% cvpr_visualsearch.m
%% Skeleton code provided as part of the coursework assessment
%%
%% This code will load in all descriptors pre-computed (by the
%% function cvpr_computedescriptors) from the images in the MSRCv2 dataset.
%%
%% It will pick a descriptor at random and compare all other descriptors to
%% it - by calling cvpr_compare.  In doing so it will rank the images by
%% similarity to the randomly picked descriptor.  Note that initially the
%% function cvpr_compare returns a random number - you need to code it
%% so that it returns the Euclidean distance or some other distance metric
%% between the two descriptors it is passed.
%%
%% (c) John Collomosse 2010  (J.Collomosse@surrey.ac.uk)
%% Centre for Vision Speech and Signal Processing (CVSSP)
%% University of Surrey, United Kingdom

close all;
clear all;

%% Edit the following line to the folder you unzipped the MSRCv2 dataset to
DATASET_FOLDER = '/Users/rahulwadia/Desktop/cvprassignment/MSRC_ObjCategImageDatabase_v2';

%% Folder that holds the results...
DESCRIPTOR_FOLDER = '/Users/rahulwadia/Desktop/cvprassignment/descriptors';
%% and within that folder, another folder to hold the descriptors
%% we are interested in working with
DESCRIPTOR_SUBFOLDER='globalRGBhisto';


%% 1) Load all the descriptors into "ALLFEAT"
%% each row of ALLFEAT is a descriptor (is an image)

ALLFEAT=[];
ALLFILES=cell(1,0);
ctr=1;
allfiles=dir (fullfile([DATASET_FOLDER,'/Images/*.bmp']));
for filenum=1:length(allfiles)
    fname=allfiles(filenum).name;
    imgfname_full=([DATASET_FOLDER,'/Images/',fname]);

    
    img=double(imread(imgfname_full))./255;

    thesefeat=[];

    featfile=[DESCRIPTOR_FOLDER,'/',DESCRIPTOR_SUBFOLDER,'/',fname(1:end-4),'.mat'];%replace .bmp with .mat
%%somewhere here is the issue 
    load(featfile,'F');

    ALLFILES{ctr}=imgfname_full;

   ALLFEAT=[ALLFEAT ; F];
  % load(featfile,'G');
  % ALLFEAT=[ALLFEAT ; G];

    ctr=ctr+1;
end

%% 2) Pick an image at random to be the query
NIMG=size(ALLFEAT,1);           % number of images in collection
queryimg=250;% index of a random image


%% 3) Compute the distance of image to the query
dst=[];
myarr=[];
groundtrutharr=[];
scorearr=[];
minkowskiarr=[];
standardFEAT=zscore(ALLFEAT);
pcatrans=pca(standardFEAT);
standardFEATpca= standardFEAT * pcatrans(:,1:4);
mahalarr=[];
mahalscorearr=[];

tester=standardFEATpca(3,:);

%%% 44 getting 95 % cumvar

miu = mean(standardFEATpca); % Mean of the projected data
covariance_matrix = cov(standardFEATpca); % Covariance matrix of the projected data

covariance_matrix= cov(standardFEATpca);

[eigenvec,eigenval]=eig(covariance_matrix);


diageigen=diag(eigenval);

[diageigen,indices]=sort(diageigen,'descend');

cum_var = cumsum(diageigen) / sum(diageigen);
mahalanobis = sqrt((tester - miu) * inv(covariance_matrix) * (tester - miu)');
mahalfunc=sqrt(mahal(tester,standardFEATpca));
% Plot cumulative explained variance
figure;
plot(cum_var, 'bo-');
title('Cumulative Explained Variance');
xlabel('Number of Principal Components');
ylabel('Cumulative Explained Variance');

for i=1:NIMG
    candidate=ALLFEAT(i,:);
    query=ALLFEAT(queryimg,:);
    thedst=norm(query - candidate);
    mahaladst=mahalsearch(queryimg,i,standardFEATpca);
    score=(1./(1+thedst));
    disp('score');
    disp(score);
    minkowskiarr=[minkowskiarr;1/1+(pdist([query; candidate], 'minkowski', 1))]
       

    
    myarr=[myarr;score,thedst];
    mahalarr=[mahalarr ; mahaladst,i];
    mahalscorearr=[mahalscorearr ; (1/(1+mahaladst)),i];

    dst=[dst ; [thedst i],score];
    
  
end
dst=sortrows(dst,3,'descend');  % sort the results
mahalarr=sortrows(mahalarr,1,'ascend');
mahalscorearr=sortrows(mahalscorearr,1,'descend');
minkowskiarr=sortrows(minkowskiarr,1,'descend')

%% 4) Visualise the results
%% These may be a little hard to see using imgshow
%% If you have access, try using imshow(outdisplay) or imagesc(outdisplay)




SHOW=30; % Show top 15 results
topdst=dst(1:SHOW,:);
%topmahal=mahalarr(1:SHOW,:);
outdisplay=[];

similarcount=0;

for i=1:size(dst,1)
%for i=1:size(topmahal,1)
 scorearr=[scorearr,dst(i,3)];
 %scorearr=[scorearr,topmahal(i,1)];
   
% if allfiles(mahalarr(i,2)).name(1:2)== allfiles(queryimg).name(1:2)
 if allfiles(dst(i,2)).name(1:2)== allfiles(queryimg).name(1:2)
        
        
     groundtrutharr=[groundtrutharr true];
  %%      disp(allfiles(topdst(i,2)).name);
    %%    disp(allfiles(queryimg).name);
    

    similarcount=similarcount+1
    disp('similarcount');
    disp(similarcount);

    

    else
        groundtrutharr=[groundtrutharr false];

        

    
    end

    myarr=[myarr;score,thedst];
    
    
     
    dst=[dst ; [thedst i],score];
    
  
end

    disp(sum(groundtrutharr,1));


thresholdarray=0:0.05:1;

precisionarr =[];
recallarr=[];







for i = 1:length(thresholdarray)

 predict= double(scorearr>=thresholdarray(i));
 %% cutoff the scores for a threshold of 0.05, then 0.1 , then 0.15 ex
   

   predictconfuse = confusionmat(groundtrutharr,predict);

 truepos = predictconfuse(2,2);
 %%bottom right is true pos

 falsepos=predictconfuse(1,2);
 %%bottom right is falsepos

 falseneg = predictconfuse(2,1);

 %% top right is false neg

    recallarr(i)= (truepos/(truepos+falsepos));
    precisionarr(i)= (truepos/(truepos+falseneg));



%% now count the instances where it coughs up tp fp fn 




end
figure(2);
plot(recallarr, precisionarr,'r');
xlabel('Recall');
ylabel('Precision');
title('Precision-Recall Curve');
grid on;

    
axis([0 1 0 1]); % Adjust the axis limits as needed





predict=[];

for i = 1:length(thresholdarray)

 predict= double(mahalscorearr(:,1)>=thresholdarray(i));
 %% cutoff the scores for a threshold of 0.05, then 0.1 , then 0.15 ex
   

   predictconfuse = confusionmat(groundtrutharr,predict);

 truepos = predictconfuse(2,2);
 %%bottom right is true pos

 falsepos=predictconfuse(1,2);
 %%bottom right is falsepos

 falseneg = predictconfuse(2,1);

 %% top right is false neg

    recallarr(i)= (truepos/(truepos+falsepos));
    precisionarr(i)= (truepos/(truepos+falseneg));



%% now count the instances where it coughs up tp fp fn 




end
figure(1);
plot(recallarr, precisionarr,'r');
xlabel('Recall');
ylabel('Precision');
title('MAHAL Precision-Recall Curve');
grid on;

    
axis([0 1 0 1]); % Adjust the axis limits as needed










for i=1:size(topdst,1)



%for i=1:size(topmahal,1)
    
    tpnum=0;
    fpnum=0;
    tn=0;
    fn=0;
%%is it a true positive? so have we matched them correctly?



%%% so now rank up all the images and give them a score which is 1/1+x
%%% where x is the distance 



  % img=imread(ALLFILES{topmahal(i,2)});
 
img=imread(ALLFILES{topdst(i,2)});


    



   


%% is it a false positive? so are there ones in there that we think should be 
      
   
   figure(1);
   img=img(1:2:end,1:2:end,:); % make image a quarter size
   img=img(1:81,:,:); % crop image to uniform size vertically (some MSVC images are different heights)
   outdisplay=[outdisplay img];
end





imshow(outdisplay);
axis off;
