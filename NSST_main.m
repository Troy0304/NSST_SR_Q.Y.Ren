clear;
clc;
close all;

addpath(genpath('nsst_toolbox'));

[imagename1,imagepath1]=uigetfile('source_images\*.jpg;*.bmp;*.png;*.tif;*.tiff;*.pgm;*.gif','Please choose the first input image');
image_input1=imread(strcat(imagepath1,imagename1));    
[imagename2,imagepath2]=uigetfile('source_images\*.jpg;*.bmp;*.png;*.tif;*.tiff;*.pgm;*.gif','Please choose the second input image');
image_input2=imread(strcat(imagepath2,imagename2)); 

Imr = image_input1;
Ipe = image_input2;

%设置可见光边缘融合比例(0-1)
c_total = 0.5;

I1 = im2double(Imr);
I1 = rgb2gray(I1);
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

% EA strategy
mB1 = mean(X1_1(:));
mB2 = mean(X1_2(:));
MB1 = median(X1_1(:));
MB2 = median(X1_2(:));
G1 = (mB1+MB1)/2;
G2 = (mB2+MB2)/2;

w1 = zeros(m,n);
w2 = zeros(m,n);
a = 4;
t = 3;
for i = 1:m
    for j = 1:n
        w1(i,j) = exp(a*abs(X1_1(i,j)-G1));
        w2(i,j) = exp(a*abs(X1_2(i,j)-G2));
        WB1(i,j) = w1(i,j)/(w1(i,j)+w2(i,j));
        WB2(i,j) = w2(i,j)/(w1(i,j)+w2(i,j));
    end
end

X1 = zeros(l,l);
for i = 1:m
    for j = 1:n
        X1(i,j) = WB1(i,j)*X1_1(i,j)+WB2(i,j)*X1_2(i,j);
    end
end

dst{1} = X1;

% Bandpass subbands

for i = 1:16
    X2_1{i} = dst1{2}(:,:,i);
    X2_2{i} = dst2{2}(:,:,i);
end

for i = 1:16
    X2(:,:,i) = nsst_fuse_noVSC(X2_1{i},X2_2{i},c_total);
end
for i = 1:16
    X3_1{i} = dst1{3}(:,:,i);
    X3_2{i} = dst2{3}(:,:,i);
end

for i = 1:16
    X3(:,:,i) = nsst_fuse_noVSC(X3_1{i},X3_2{i},c_total);
end

for i = 1:8
    X4_1{i} = dst1{4}(:,:,i);
    X4_2{i} = dst2{4}(:,:,i);
end

for i = 1:8
    X4(:,:,i) = nsst_fuse_noVSC(X4_1{i},X4_2{i},c_total);
end

for i = 1:8
    X5_1{i} = dst1{5}(:,:,i);
    X5_2{i} = dst2{5}(:,:,i);
end

for i = 1:8
    X5(:,:,i) = nsst_fuse_noVSC(X5_1{i},X5_2{i},c_total);
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