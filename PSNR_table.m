clear; clc; close all;

%% 参数配置
ir_dir = 'D:\Q.Y.Ren\毕业论文\MATLAB程序\source_images\红外光图像\';
vis_dir = 'D:\Q.Y.Ren\毕业论文\MATLAB程序\source_images\可见光图像\';

% 定义需要评估的算法目录和名称
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

%% 计算PSNR
num_algorithms = length(algorithm_dirs);
num_images = length(dir(strcat(ir_dir, '*.png')));
MAX = 255;  % 8-bit图像最大值

% 初始化结果矩阵
psnr_table = cell(num_images+2, num_algorithms+1);
psnr_table{1,1} = '图像序号';
psnr_table(end,:) = {'算法平均'}; 

% 填充算法名称到表头
for algo_idx = 1:num_algorithms
    psnr_table{1, algo_idx+1} = algorithm_names{algo_idx};
end

% 主计算循环
for algo_idx = 1:num_algorithms
    algo_psnr = zeros(num_images, 1);
    
    for img_idx = 1:num_images
        % 读取源图像
        ir_img = im2double(imread([ir_dir, num2str(img_idx), '.png']));
        vis_img = im2double(imread([vis_dir, num2str(img_idx), '.png']));
        
        % 转换为灰度图
        ir_gray = im2gray(ir_img);
        vis_gray = im2gray(vis_img);
        
        % 读取融合图像
        fused_img = im2double(imread([algorithm_dirs{algo_idx}, num2str(img_idx), '.png']));
        fused_gray = im2gray(fused_img);
        
        % 计算PSNR
        mse_ir = mean((ir_gray(:) - fused_gray(:)).^2);
        psnr_ir = 10*log10(MAX^2 / mse_ir);
        
        mse_vis = mean((vis_gray(:) - fused_gray(:)).^2);
        psnr_vis = 10*log10(MAX^2 / mse_vis);
        
        % 存储到表格
        psnr_table{img_idx+1, 1} = sprintf('图像%02d', img_idx);
        psnr_table{img_idx+1, algo_idx+1} = (psnr_ir + psnr_vis)/2;
        
        % 累加计算算法平均
        algo_psnr(img_idx) = (psnr_ir + psnr_vis)/2;
    end
    
    % 计算算法平均
    psnr_table{end, algo_idx+1} = mean(algo_psnr);
end

%% 格式化输出表格
% 计算列宽
col_width = max(cellfun(@(x) length(char(x)), psnr_table(1,:))) + 5;

% 打印表头
fprintf('\n\n%*s', col_width, ' ')
for algo_idx = 1:num_algorithms
    fprintf('%*s', col_width, algorithm_names{algo_idx})
end
fprintf('\n%s\n', repmat('-', (num_algorithms+1)*col_width, 1))

% 打印数据行
for row = 2:size(psnr_table,1)
    fprintf('%-*s', col_width, psnr_table{row,1})
    for col = 2:size(psnr_table,2)
        if isfloat(psnr_table{row,col})
            fprintf('%*.2f dB', col_width-3, psnr_table{row,col})
        else
            fprintf('%*s', col_width, psnr_table{row,col})
        end
    end
    fprintf('\n')
end

disp('======== 表格输出完成 ========');