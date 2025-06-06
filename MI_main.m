clear; clc; close all;

%% 参数配置
ir_dir = 'D:\Q.Y.Ren\毕业论文\MATLAB程序\source_images\红外光图像\';
vis_dir = 'D:\Q.Y.Ren\毕业论文\MATLAB程序\source_images\可见光图像\';

% 定义所有算法结果目录
algorithm_dirs = {
    'D:\Q.Y.Ren\毕业论文\MATLAB程序\source_images\融合图像\CVT结果\';
    'D:\Q.Y.Ren\毕业论文\MATLAB程序\source_images\融合图像\DTCWT结果\';
    'D:\Q.Y.Ren\毕业论文\MATLAB程序\source_images\融合图像\DWT结果\';
    'D:\Q.Y.Ren\毕业论文\MATLAB程序\source_images\融合图像\LP结果\';
    'D:\Q.Y.Ren\毕业论文\MATLAB程序\source_images\融合图像\NSCT结果\';
    'D:\Q.Y.Ren\毕业论文\MATLAB程序\source_images\融合图像\NSST_SR结果\';
    'D:\Q.Y.Ren\毕业论文\MATLAB程序\source_images\融合图像\NSST结果\';
    'D:\Q.Y.Ren\毕业论文\MATLAB程序\source_images\融合图像\RP结果\';
    'D:\Q.Y.Ren\毕业论文\MATLAB程序\source_images\融合图像\SR结果\';
};
algorithm_names = {'CVT', 'DTCWT', 'DWT', 'LP', 'NSCT', 'NSST-SR', 'NSST', 'RP', 'SR'};

%% 计算互信息
num_algorithms = length(algorithm_dirs);
num_images = length(dir(strcat(ir_dir, '*.png')));
mi_results = zeros(num_images, num_algorithms);

for img_idx = 1:num_images
    % 读取源图像
    ir_img = imread([ir_dir, num2str(img_idx), '.png']);
    vis_img = imread([vis_dir, num2str(img_idx), '.png']);
    
    for algo_idx = 1:num_algorithms
        % 读取融合图像
        fused_img = imread([algorithm_dirs{algo_idx}, num2str(img_idx), '.png']);
        
        % 计算互信息
        mi_results(img_idx, algo_idx) = MI_calculate(fused_img, ir_img, vis_img);
    end
end

%% 绘制折线图
figure('Position', [100, 100, 1200, 600]);
colors = lines(num_algorithms); % 使用PSNR同款颜色
markers = {'o', 's', 'd', '^', 'v', '>', '<', 'p', 'h'}; % 保持标记一致性

hold on;
for algo_idx = 1:num_algorithms
    plot(1:num_images, mi_results(:, algo_idx),...
        'Color', colors(algo_idx,:),...
        'Marker', markers{algo_idx},...
        'LineWidth', 1.5,...
        'MarkerSize', 8,...
        'DisplayName', algorithm_names{algo_idx});
end

% 图形美化
xlabel('图像序号', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('互信息 (MI)', 'FontSize', 12, 'FontWeight', 'bold');
title('不同融合算法的互信息对比', 'FontSize', 14, 'FontWeight', 'bold');
legend('show', 'Location', 'eastoutside', 'FontSize', 10);
grid on;
set(gca, 'FontSize', 10, 'LineWidth', 1.2, 'XTick', 1:num_images);
xlim([0.5, num_images+0.5]);

disp('======== 绘图完成 ========');