clear all;
close all;
clc;

addpath(genpath('sparsefusion'));
load('Dictionary/D_100000_256_8.mat');

[imagename1, imagepath1]=uigetfile('source_images\*.jpg;*.bmp;*.png;*.tif;*.tiff;*.pgm;*.gif','Please choose the first input image');
image_input1=imread(strcat(imagepath1,imagename1));    
[imagename2, imagepath2]=uigetfile('source_images\*.jpg;*.bmp;*.png;*.tif;*.tiff;*.pgm;*.gif','Please choose the second input image');
image_input2=imread(strcat(imagepath2,imagename2));    


img2=double(image_input1);
img1=double(image_input2);

overlap = 6;                    
epsilon=0.1;

if size(img1,3)==1   %for gray images
    imgf=sparse_fusion(img1,img2,D,overlap,epsilon);
else                 %for color images
    imgf=zeros(size(img1));
    for i=1:3
        imgf(:,:,i)=sparse_fusion(img1(:,:,i),img2(:,:,1),D,overlap,epsilon);
    end
end

imgf = uint8(imgf);
figure;
imshow(imgf);
