clear; clc; close all;
addpath(genpath('nsst_toolbox'));
addpath(genpath('sparsefusion'));
load('sparsefusion/Dictionary/D_100000_256_8.mat');

%% 参数配置
ir_dir = 'D:\Q.Y.Ren\毕业论文\MATLAB程序\source_images\红外光图像\';
vis_dir = 'D:\Q.Y.Ren\毕业论文\MATLAB程序\source_images\可见光图像\';
output_dir = 'D:\Q.Y.Ren\毕业论文\MATLAB程序\source_images\融合图像\SR结果\';
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
    img2=double(Imr);
    img1=double(Ipe);

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

    %% 保存结果
    imwrite(imgf, [output_dir,int2str(turn), '.png']);
end
disp('======== 批量融合完成 ========');