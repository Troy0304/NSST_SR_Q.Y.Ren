clear; clc; close all;
addpath(genpath('nsst_toolbox'));
addpath(genpath('sparsefusion'));
addpath(genpath('dtcwt_toolbox'));
addpath(genpath('fdct_wrapping_matlab'));
addpath(genpath('nsct_toolbox'));
load('sparsefusion/Dictionary/D_100000_256_8.mat');

%% 参数配置
ir_dir = 'D:\Q.Y.Ren\毕业论文\MATLAB程序\source_images\红外光图像\';
vis_dir = 'D:\Q.Y.Ren\毕业论文\MATLAB程序\source_images\可见光图像\';
output_dir = 'D:\Q.Y.Ren\毕业论文\MATLAB程序\source_images\融合图像\CVT结果\';
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
    A=double(Ipe);
    B=double(Imr);
    level=4;
    tic;
    if size(A,3)==1    %for gray images
        %F = lp_fuse(A, B, level, 3, 3);       %LP
        %F = rp_fuse(A, B, level, 3, 3);      %RP
        %F = dwt_fuse(A, B, level);           %DWT
        %F = dtcwt_fuse(A,B,level);           %DTCWT
        F = curvelet_fuse(A,B,level+1);      %CVT
        %F = nsct_fuse(A,B,[2,3,3,4]);        %NSCT
    else               %for color images
        F=zeros(size(A));
        for i=1:3
            %F(:,:,i) = lp_fuse(A(:,:,i), B(:,:,1), level, 3, 3);       %LP
            %F(:,:,i) = rp_fuse(A(:,:,i), B(:,:,1), level, 3, 3);      %RP
            %F(:,:,i) = dwt_fuse(A(:,:,i), B(:,:,1), level);           %DWT
            %F(:,:,i) = dtcwt_fuse(A(:,:,i),B(:,:,1),level);           %DTCWT
            F(:,:,i) = curvelet_fuse(A(:,:,i),B(:,:,1),level+1);      %CVT
            %F(:,:,i) = nsct_fuse(A(:,:,i),B(:,:,1),[2,3,3,4]);        %NSCT
        end
    end
    toc;
    FF = uint8(F); % 转换回uint8格式

    %% 保存结果
    imwrite(FF, [output_dir,int2str(turn), '.png']);
end
disp('======== 批量融合完成 ========');