clear; clc; close all;

%% 参数配置
ir_dir = 'D:\Q.Y.Ren\毕业论文\MATLAB程序\source_images\红外光图像\';
vis_dir = 'D:\Q.Y.Ren\毕业论文\MATLAB程序\source_images\可见光图像\';

% 定义需要评估的算法目录和名称 (7种算法)
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

%% 计算互信息
num_algorithms = length(algorithm_dirs);
num_images = length(dir(strcat(ir_dir, '*.png')));

% 初始化结果表格
mi_table = cell(num_images+2, num_algorithms+1);
mi_table{1,1} = '图像序号';
mi_table(end,:) = {'算法平均'}; 

% 填充算法名称到表头
for algo_idx = 1:num_algorithms
    mi_table{1, algo_idx+1} = algorithm_names{algo_idx};
end

% 主计算循环
for algo_idx = 1:num_algorithms
    algo_mi = zeros(num_images, 1); % 存储当前算法所有图像的MI值
    
    for img_idx = 1:num_images
        % 读取源图像
        ir_img = imread([ir_dir, num2str(img_idx), '.png']);
        vis_img = imread([vis_dir, num2str(img_idx), '.png']);
        
        % 读取融合图像
        fused_img = imread([algorithm_dirs{algo_idx}, num2str(img_idx), '.png']);
        
        % 计算互信息
        current_mi = MI_calculate(fused_img, ir_img, vis_img);
        
        % 存储到表格
        mi_table{img_idx+1, 1} = sprintf('图像%02d', img_idx);
        mi_table{img_idx+1, algo_idx+1} = current_mi;
        
        % 累加计算算法平均
        algo_mi(img_idx) = current_mi;
    end
    
    % 计算算法平均
    mi_table{end, algo_idx+1} = mean(algo_mi);
end

%% 格式化输出表格
% 计算列宽
col_width = 14; % 固定列宽保证对齐

% 打印表头
fprintf('\n\n%*s', col_width, ' ')
for algo_idx = 1:num_algorithms
    fprintf('%*s', col_width, algorithm_names{algo_idx})
end
fprintf('\n%s\n', repmat('-', (num_algorithms+1)*col_width, 1))

% 打印数据行
for row = 2:size(mi_table,1)
    fprintf('%-*s', col_width, mi_table{row,1})
    for col = 2:size(mi_table,2)
        if isfloat(mi_table{row,col})
            fprintf('%*.3f bits', col_width-6, mi_table{row,col})
        else
            fprintf('%*s', col_width, mi_table{row,col})
        end
    end
    fprintf('\n')
end

disp('======== 表格输出完成 ========');