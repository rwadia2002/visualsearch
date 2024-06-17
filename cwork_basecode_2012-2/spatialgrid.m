function G = spatilagrid(image,B)
%SPATIALGRID Summary of this function goes here
%   Detailed explanation goes here
%B=8;
%image = imread('your_image.jpg');
%% need a 4x4 grid so define that first

rowcount=4;
columncount=4;
redimage = image(:,:,1);   % Red 
greenimage = image(:,:,2); % Green 
blueimage = image(:,:,3);  % Blue 
meanarr=[]
%% autoconverts to grayscale so you split earlier on 
%% get dimensions from the size of the image 

imsize=size(image);
imheight=imsize(1);
imwidth=imsize(2);
currentcellrowstart=0;
currentcellrowend=0;

%%%height/row is the cellheight

%%width/column is the cellwidth
colourhist =zeros(16,768)
%% 256x3 by all the squares, 16 squares

%% after that you can effectively just index the picture using a coordinate range from the chunks here

cellheight= floor(imheight/rowcount);
cellwidth=floor(imwidth/columncount);

colourhist=zeros(768,16);
cellcount=0;
lbparray=zeros(59,16);
sumhisto=[];

histosum=zeros(1,16);
%%now just loop the image based on the multiples of the cell
for i=1:rowcount

for j=1:columncount
    cellcount=cellcount+1;
   currentcellrowstart = 1+((i-1)*cellheight);
   currentcellrowend=((i*cellheight));
   currentcellcolend=(j*cellwidth);
   currentcellcolstart=(((j-1)*cellwidth)+1);
  imcell= image(currentcellrowstart:currentcellrowend,currentcellcolstart :currentcellcolend)
  imcellred=imhist(redimage(currentcellrowstart:currentcellrowend,currentcellcolstart :currentcellcolend),256);
  imcellblue=imhist(blueimage(currentcellrowstart:currentcellrowend,currentcellcolstart :currentcellcolend),256);
  imcellgreen=imhist(greenimage(currentcellrowstart:currentcellrowend,currentcellcolstart :currentcellcolend),256); 
  
  %%redHist = imhist(imcell(:,:,1), 256);
  colourhist(:,cellcount)=[imcellred;imcellgreen;imcellblue];
  %% you now have joined up your reds greens and blues for each line

bins=36;
%%lbpfeatures = extractLBPFeatures(im2gray(imcell),bins);
lbpfeatures = extractLBPFeatures(im2gray(imcell), 'Radius', 1, 'NumNeighbors', 8, 'Normalization', 'L2');
%%lbp you need 59 
lbparray(:,cellcount)=lbpfeatures;


[Gmag,Gdir]=imgradient(imcell, 'Sobel');


%imshowpair(Gmag,Gdir,'montage')
%title('Gradient Magnitude (Left) and Gradient Direction (Right)')

bins=B;

bin_edges = linspace(-180, 180, bins + 1);
quantangles= discretize(Gdir,bin_edges);
meanarr=[meanarr ;mean(quantangles,'all')];

%%need to discretize the angles into bins from a certain range

 % figure;
% quanthisto= histogram(quantangles, 1:bins, 'norm', 'probability', 'FaceColor', 'b');
        
% Customize the plot
%title(['Quantized Angles in Cell(', num2str(i), ',', num2str(j), ')']);
%xlabel('Bins');
%ylabel('Probability');
%xlim([1, bins]);



end 




end
texturearr=(meanarr')./(max(meanarr'));
colourarr=(colourhist(end,:)./(max(colourhist(end,:))));
title(['colour histogram']);
%colourhistgraphical=histogram(colourhist,1:256, 'norm', 'probability', 'FaceColor', 'b');
histographical=histogram(sumhisto, 1:bins, 'norm', 'probability', 'FaceColor', 'b');
fulldesc=horzcat(colourarr,texturearr);


G=fulldesc;
%% now get the details and 



%%concatenate the two

%outputArg1 = inputArg1;
%outputArg2 = inputArg2;
%%end

