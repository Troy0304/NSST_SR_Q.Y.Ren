clear; clc; close all;
addpath(genpath('nsst_toolbox'));
addpath(genpath('sparsefusion'));
load('sparsefusion/Dictionary/D_100000_256_8.mat');

%% 参数配置
ir_dir = 'D:\Q.Y.Ren\毕业论文\MATLAB程序\source_images\红外光图像\';
vis_dir = 'D:\Q.Y.Ren\毕业论文\MATLAB程序\source_images\可见光图像\';
output_dir = 'D:\Q.Y.Ren\毕业论文\MATLAB程序\source_images\融合图像\NSST_SR结果\';
c_total = 0.5;  % 可见光边缘融合比例
file_ext = {'*.jpg','*.png','*.bmp','*.tif'}; % 支持扩展名

%% 批量融合处理
ir_files = dir(strcat(ir_dir,'*.png'));
vis_files = dir(strcat(vis_dir,'*.png'));
for i = 1:length(ir_files)
    ir_name = ir_files(i).name;
    vis_name = vis_files(i).name;
    Imr = imread(strcat(ir_dir,ir_name));
    Ipe = imread(strcat(vis_dir,vis_name));
    %% 核心融合算法
    I1 = im2double(im2gray(Imr));
    I3 = rgb2hsv(im2double(Ipe));
    I2 = I3(:,:,3);
    [m,n] = size(I1);
    l = max(m,n);
    
    % NSST分解
    lpfilt = 'maxflat';
    shear_parameters.dcomp = [4 4 3 3];
    shear_parameters.dsize = [32 32 16 16];
    
    J1 = zeros(l,l); J1(1:m,1:n) = I1;
    J2 = zeros(l,l); J2(1:m,1:n) = I2;
    
    [dst1, shear_f1] = nsst_dec2(J1, shear_parameters, lpfilt);
    [dst2, shear_f2] = nsst_dec2(J2, shear_parameters, lpfilt);
    
    %% 低频融合
    X1_1 = dst1{1}; X1_2 = dst2{1};
    overlap = 6; epsilon = 0.1;
    X1 = sparse_fusion_0317(X1_1, X1_2, D, overlap, epsilon);
    dst{1} = X1;
    
    %% 高频融合（保持原算法结构）
    for scale = 2:length(dst1)
        band_num = size(dst1{scale},3);
        fused_band = zeros(size(dst1{scale}));
        for b = 1:band_num
            band_ir = dst1{scale}(:,:,b);
            band_vis = dst2{scale}(:,:,b);
            fused_band(:,:,b) = nsst_fuse(band_ir, band_vis, c_total, X1_1, X1_2);
        end
        dst{scale} = fused_band;
    end
    
    %% 重构与后处理
    Ir = nsst_rec2(dst, shear_f1, lpfilt);
    Fi = Ir(1:m,1:n);
    I3(:,:,3) = Fi;
    FF = hsv2rgb(I3);
    FF = im2uint8(FF); % 转换回uint8格式

    %% 保存结果
    imwrite(FF, [output_dir,int2str(i), '.png']);
end
disp('======== 批量融合完成 ========');