clear; clc; close all;
addpath(genpath('nsst_toolbox'));
addpath(genpath('sparsefusion'));
load('sparsefusion/Dictionary/D_100000_256_8.mat');

%% 参数配置
ir_dir = 'D:\Q.Y.Ren\毕业论文\MATLAB程序\source_images\红外光图像\';
vis_dir = 'D:\Q.Y.Ren\毕业论文\MATLAB程序\source_images\可见光图像\';
output_dir = 'D:\Q.Y.Ren\毕业论文\MATLAB程序\source_images\融合图像\NSST结果\';
c_total = 0.5;  % 可见光边缘融合比例
file_ext = {'*.jpg','*.png','*.bmp','*.tif'}; % 支持扩展名

%% 批量融合处理
ir_files = dir(strcat(ir_dir,'*.png'));
vis_files = dir(strcat(vis_dir,'*.png'));
for turn = 1:length(ir_files)
    ir_name = ir_files(turn).name;
    vis_name = vis_files(turn).name;
    Imr = imread(strcat(ir_dir,ir_name));
    Ipe = imread(strcat(vis_dir,vis_name));
    %% 核心融合算法
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
    FF = im2uint8(FF); % 转换回uint8格式

    %% 保存结果
    imwrite(FF, [output_dir,int2str(turn), '.png']);
end
disp('======== 批量融合完成 ========');