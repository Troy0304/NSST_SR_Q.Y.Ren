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

%% 计算空间频率
num_algorithms = length(algorithm_dirs);
num_images = length(dir(strcat(ir_dir, '*.png')));

% 初始化结果表格
sf_table = cell(num_images+2, num_algorithms+1);
sf_table{1,1} = '图像序号';
sf_table(end,:) = {'算法平均'};

% 填充算法名称到表头
for algo_idx = 1:num_algorithms
    sf_table{1, algo_idx+1} = algorithm_names{algo_idx};
end

%% 主计算循环
for algo_idx = 1:num_algorithms
    algo_sf = zeros(num_images, 1); % 存储当前算法所有图像的SF值
    
    for img_idx = 1:num_images
        % 读取融合图像
        fused_img = im2double(imread([algorithm_dirs{algo_idx}, num2str(img_idx), '.png']));
        
        % 转换为灰度图（若为彩色）
        if size(fused_img, 3) == 3
            fused_gray = rgb2gray(fused_img);
        else
            fused_gray = fused_img;
        end
        
        % 计算空间频率
        current_sf = space_frequency(fused_gray);
        
        % 存储到表格
        sf_table{img_idx+1, 1} = sprintf('图像%02d', img_idx);
        sf_table{img_idx+1, algo_idx+1} = current_sf;
        
        % 累加计算算法平均
        algo_sf(img_idx) = current_sf;
    end
    
    % 计算算法平均
    sf_table{end, algo_idx+1} = mean(algo_sf);
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
for row = 2:size(sf_table,1)
    fprintf('%-*s', col_width, sf_table{row,1})
    for col = 2:size(sf_table,2)
        if isfloat(sf_table{row,col})
            fprintf('%*.3f', col_width-3, sf_table{row,col}) % 保留3位小数
        else
            fprintf('%*s', col_width, sf_table{row,col})
        end
    end
    fprintf('\n')
end

disp('======== 表格输出完成 ========');