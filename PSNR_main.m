clear; clc; close all;

%% 参数配置
% ir_dir = 'D:\Q.Y.Ren\毕业论文\MATLAB程序\source_images\红外光图像\';
% vis_dir = 'D:\Q.Y.Ren\毕业论文\MATLAB程序\source_images\可见光图像\';
% CVT_dir = 'D:\Q.Y.Ren\毕业论文\MATLAB程序\source_images\融合图像\CVT结果\';
% DTCWT_dir = 'D:\Q.Y.Ren\毕业论文\MATLAB程序\source_images\融合图像\DTCWT结果\';
% DWT_dir = 'D:\Q.Y.Ren\毕业论文\MATLAB程序\source_images\融合图像\DWT结果\';
% LP_dir = 'D:\Q.Y.Ren\毕业论文\MATLAB程序\source_images\融合图像\LP结果\';
% NSCT_dir = 'D:\Q.Y.Ren\毕业论文\MATLAB程序\source_images\融合图像\NSCT结果\';
% NSST_SR_dir = 'D:\Q.Y.Ren\毕业论文\MATLAB程序\source_images\融合图像\NSST_SR结果\';
% NSST_dir = 'D:\Q.Y.Ren\毕业论文\MATLAB程序\source_images\融合图像\NSST结果\';
% RP_dir = 'D:\Q.Y.Ren\毕业论文\MATLAB程序\source_images\融合图像\RP结果\';
% SR_dir = 'D:\Q.Y.Ren\毕业论文\MATLAB程序\source_images\融合图像\SR结果\';

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

%% 计算PSNR
num_algorithms = length(algorithm_dirs);
num_images = length(dir(strcat(ir_dir, '*.png')));
psnr_results = zeros(num_images, num_algorithms);

for algo_idx = 1:num_algorithms
    output_dir = algorithm_dirs{algo_idx};
    
    for img_idx = 1:num_images
        % 读取源图像
        ir_img = im2double(imread([ir_dir, num2str(img_idx), '.png']));
        vis_img = im2double(imread([vis_dir, num2str(img_idx), '.png']));
        
        % 转换为灰度图
        if size(ir_img, 3) == 3
            ir_gray = rgb2gray(ir_img);
        else
            ir_gray = ir_img;
        end
        
        if size(vis_img, 3) == 3
            vis_gray = rgb2gray(vis_img);
        else
            vis_gray = vis_img;
        end
        
        % 读取融合图像并转灰度
        fused_img = im2double(imread([output_dir, num2str(img_idx), '.png']));
        if size(fused_img, 3) == 3
            fused_gray = rgb2gray(fused_img);
        else
            fused_gray = fused_img;
        end
        
        % 计算PSNR
        MAX = 255;
        
        % 与红外图像比较
        mse_ir = mean((ir_gray(:) - fused_gray(:)).^2);
        psnr_ir = 10*log10(MAX^2 / mse_ir);
        
        % 与可见光图像比较
        mse_vis = mean((vis_gray(:) - fused_gray(:)).^2);
        psnr_vis = 10*log10(MAX^2 / mse_vis);
        
        % 平均PSNR
        psnr_results(img_idx, algo_idx) = (psnr_ir + psnr_vis) / 2;
    end
end

%% 绘制折线图
figure('Position', [100, 100, 1200, 600]);
colors = lines(num_algorithms); % 使用不同颜色
markers = {'o', 's', 'd', '^', 'v', '>', '<', 'p', 'h'}; % 不同标记

hold on;
for algo_idx = 1:num_algorithms
    plot(1:num_images, psnr_results(:, algo_idx),...
        'Color', colors(algo_idx,:),...
        'Marker', markers{algo_idx},...
        'LineWidth', 1.5,...
        'DisplayName', algorithm_names{algo_idx});
end

% 图形美化
xlabel('图像序号', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('PSNR (dB)', 'FontSize', 12, 'FontWeight', 'bold');
title('不同融合算法的PSNR性能对比', 'FontSize', 14, 'FontWeight', 'bold');
legend('show', 'Location', 'eastoutside');
grid on;
set(gca, 'FontSize', 10, 'LineWidth', 1.2);
xticks(1:num_images);
xlim([0.5, num_images+0.5]);

disp('======== 绘图完成 ========');