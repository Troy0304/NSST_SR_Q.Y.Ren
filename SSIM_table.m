clear; clc; close all;

%% 参数配置
ir_dir = 'D:\Q.Y.Ren\毕业论文\MATLAB程序\source_images\红外光图像\';
vis_dir = 'D:\Q.Y.Ren\毕业论文\MATLAB程序\source_images\可见光图像\';

% 定义需要评估的7种算法
algorithm_dirs = {
    'D:\Q.Y.Ren\毕业论文\MATLAB程序\source_images\融合图像\LP结果\';
    'D:\Q.Y.Ren\毕业论文\MATLAB程序\source_images\融合图像\RP结果\';
    'D:\Q.Y.Ren\毕业论文\MATLAB程序\source_images\融合图像\DWT结果\';
    'D:\Q.Y.Ren\毕业论文\MATLAB程序\source_images\融合图像\DTCWT结果\';
    'D:\Q.Y.Ren\毕业论文\MATLAB程序\source_images\融合图像\CVT结果\';
    'D:\Q.Y.Ren\毕业论文\MATLAB程序\source_images\融合图像\NSCT结果\';
    'D:\Q.Y.Ren\毕业论文\MATLAB程序\source_images\融合图像\NSST_SR结果\';
};
algorithm_names = {'LP', 'RP', 'DWT', 'DTCWT', 'CVT', 'NSCT', 'NSST-SR'};

%% 计算结构相似性SSIM
num_algorithms = length(algorithm_dirs);
num_images = length(dir(strcat(ir_dir, '*.png')));

% 初始化结果表格
ssim_table = cell(num_images+2, num_algorithms+1);
ssim_table{1,1} = '图像序号';
ssim_table(end,:) = {'算法平均'};

% 填充算法名称到表头
for algo_idx = 1:num_algorithms
    ssim_table{1, algo_idx+1} = algorithm_names{algo_idx};
end

%% 主计算循环
for algo_idx = 1:num_algorithms
    algo_ssim = zeros(num_images, 1); % 存储当前算法所有图像的SSIM值
    
    for img_idx = 1:num_images
        % 读取源图像
        ir_img = im2double(imread([ir_dir, num2str(img_idx), '.png']));
        vis_img = im2double(imread([vis_dir, num2str(img_idx), '.png']));
        
        % 读取融合图像
        fused_img = im2double(imread([algorithm_dirs{algo_idx}, num2str(img_idx), '.png']));
        
        % 转换为灰度图
        ir_gray = im2gray(ir_img);
        vis_gray = im2gray(vis_img);
        fused_gray = im2gray(fused_img);
        
        % 计算SSIM
        ssim_ir = ssim(fused_gray, ir_gray);
        ssim_vis = ssim(fused_gray, vis_gray);
        avg_ssim = (ssim_ir + ssim_vis);
        
        % 存储到表格
        ssim_table{img_idx+1, 1} = sprintf('图像%02d', img_idx);
        ssim_table{img_idx+1, algo_idx+1} = avg_ssim;
        
        % 累加计算算法平均
        algo_ssim(img_idx) = avg_ssim;
    end
    
    % 计算算法平均
    ssim_table{end, algo_idx+1} = mean(algo_ssim);
end

%% 格式化输出表格
% 设置列宽
col_width = 14;

% 打印表头
fprintf('\n\n%*s', col_width, ' ')
for algo_idx = 1:num_algorithms
    fprintf('%*s', col_width, algorithm_names{algo_idx})
end
fprintf('\n%s\n', repmat('-', (num_algorithms+1)*col_width, 1))

% 打印数据行
for row = 2:size(ssim_table,1)
    fprintf('%-*s', col_width, ssim_table{row,1})
    for col = 2:size(ssim_table,2)
        if isfloat(ssim_table{row,col})
            fprintf('%*.3f', col_width-3, ssim_table{row,col}) % 保留3位小数
        else
            fprintf('%*s', col_width, ssim_table{row,col})
        end
    end
    fprintf('\n')
end

disp('======== 表格输出完成 ========');