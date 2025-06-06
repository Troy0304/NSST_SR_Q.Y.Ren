clear;
clc;
close all;

addpath(genpath('nsst_toolbox'));
addpath(genpath('sparsefusion'));

load('sparsefusion/Dictionary/D_100000_256_8.mat');

[imagename1,imagepath1]=uigetfile('source_images\*.jpg;*.bmp;*.png;*.tif;*.tiff;*.pgm;*.gif','Please choose the first input image');
image_input1=imread(strcat(imagepath1,imagename1));    
[imagename2,imagepath2]=uigetfile('source_images\*.jpg;*.bmp;*.png;*.tif;*.tiff;*.pgm;*.gif','Please choose the second input image');
image_input2=imread(strcat(imagepath2,imagename2)); 

Imr = image_input1;
Ipe = image_input2;
%设置可见光边缘融合比例(0-1)
c_total = 0.5;

I1 = im2double(Imr);
I1 = im2gray(I1);
IpeRGB = im2double(Ipe);
I3 = rgb2hsv(IpeRGB);
I2 = I3(:,:,3);
[m,n] = size(I1);
l = max(m,n);
J1 = zeros(l,l);
J2 = zeros(l,l);
J1(1:m,1:n) = I1;
J2(1:m,1:n) = I2;

%% Parameters for NSST
lpfilt = 'maxflat';
shear_parameters.dcomp =[ 4  4  3  3];
shear_parameters.dsize =[32 32 16 16];

%% NSST分解
[dst1,shear_f1]=nsst_dec2(J1,shear_parameters,lpfilt);
[dst2,shear_f2]=nsst_dec2(J2,shear_parameters,lpfilt);

% Lowpass subband

X1_1= dst1{1};
X1_2 =dst2{1};

overlap = 6;                    
epsilon=0.1;

X1=sparse_fusion_0317(X1_1,X1_2,D,overlap,epsilon);
dst{1} = X1;

% Bandpass subbands

for i = 1:16
    X2_1{i} = dst1{2}(:,:,i);
    X2_2{i} = dst2{2}(:,:,i);
end

for i = 1:16
    X2(:,:,i) = nsst_fuse(X2_1{i},X2_2{i},c_total,X1_1,X1_2);
end

for i = 1:16
    X3_1{i} = dst1{3}(:,:,i);
    X3_2{i} = dst2{3}(:,:,i);
end

for i = 1:16
    X3(:,:,i) = nsst_fuse(X3_1{i},X3_2{i},c_total,X1_1,X1_2);
end

for i = 1:8
    X4_1{i} = dst1{4}(:,:,i);
    X4_2{i} = dst2{4}(:,:,i);
end

for i = 1:8
    X4(:,:,i) = nsst_fuse(X4_1{i},X4_2{i},c_total,X1_1,X1_2);
end

for i = 1:8
    X5_1{i} = dst1{5}(:,:,i);
    X5_2{i} = dst2{5}(:,:,i);
end

for i = 1:8
    X5(:,:,i) = nsst_fuse(X5_1{i},X5_2{i},c_total,X1_1,X1_2);
end

dst{2} = X2;
dst{3} = X3;
dst{4} = X4;
dst{5} = X5;

% Reconstruction
Ir=nsst_rec2(dst,shear_f1,lpfilt);

Fi = Ir(1:m,1:n);
I3(:,:,3)=Fi;
FF = hsv2rgb(I3);

figure;
imshow(FF);