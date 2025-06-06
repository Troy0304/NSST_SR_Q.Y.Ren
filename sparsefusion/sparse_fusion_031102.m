function F = sparse_fusion_031102(X1,X2,D,overlap,epsilon)
    % 参数初始化
    A = X1;
    B = X2;
    
    % 字典归一化（保持双精度计算）
    norm_D = sqrt(sum(D.^2, 1)); 
    D = D./repmat(norm_D, size(D, 1), 1);

    % 图像参数
    patch_size = sqrt(size(D, 1));
    [h,w] = size(A);
    F = zeros(h,w);
    cntMat = zeros(h,w);
    
    % 网格划分
    gridx = 1:patch_size - overlap : w-patch_size+1;
    gridy = 1:patch_size - overlap : h-patch_size+1;
    
    % Gram矩阵预计算
    G = D'*D;

    % 新增1：引导滤波器参数
    filter_radius = 3;      % 引导滤波半径
    filter_epsilon = 0.1;   % 正则化参数
    
    % 主循环处理每个patch
    for ii = 1:length(gridx)
        for jj = 1:length(gridy)
            xx = gridx(ii);
            yy = gridy(jj);
            
            % 提取双模态patch
            patch_1 = A(yy:yy+patch_size-1, xx:xx+patch_size-1);
            mean1 = mean(patch_1(:));
            patch1 = patch_1(:) - mean1;
            
            patch_2 = B(yy:yy+patch_size-1, xx:xx+patch_size-1);
            mean2 = mean(patch_2(:));
            patch2 = patch_2(:) - mean2;
            
            % OMP稀疏编码
            w1 = omp2(D, patch1, G, epsilon);
            w2 = omp2(D, patch2, G, epsilon);
            
            % 基础融合策略
            w = w1 * 0.7 + w2 * 0.3;
            mean_f = mean1;
            if sum(abs(w1)) < sum(abs(w2))
                w = w2 * 0.7 + w1 * 0.3;
                mean_f = mean2;
            end
            
            % 稀疏重构
            patch_f = D * w;
            Patch_f = reshape(patch_f, [patch_size, patch_size]) + mean_f;
            
            % 新增2：多维度异常检测
            [is_artifacts, ~] = check_artifacts(Patch_f, patch_1, patch_2);
            
            % 新增3：动态融合处理
            if is_artifacts
                % 质量评估获取权重
                w1 = dynamic_weight(patch_1, patch_2);
                w2 = 1 - w1;
                
                % 边缘保持融合
                Patch_f = edge_preserving_fusion(patch_1, patch_2, w1, w2);
            end
            
            % 新增4：局部一致性优化
            Patch_f = guided_filter(Patch_f, mean2gray(patch_1, patch_2), filter_radius, filter_epsilon);
            
            % 累加融合结果
            F(yy:yy+patch_size-1, xx:xx+patch_size-1) = ...
                F(yy:yy+patch_size-1, xx:xx+patch_size-1) + Patch_f;
            cntMat(yy:yy+patch_size-1, xx:xx+patch_size-1) = ...
                cntMat(yy:yy+patch_size-1, xx:xx+patch_size-1) + 1;
        end
    end

    % 后处理
    idx = (cntMat < 1);
    F(idx) = (A(idx) + B(idx)) ./ 2;
    cntMat(idx) = 1;
    F = F ./ cntMat;
end

%% 新增辅助函数 - 多维度异常检测
function [is_artifacts, confidence] = check_artifacts(Patch_f, patch1, patch2)
    % 维度1：直方图检测
    [counts, ~] = imhist(Patch_f);
    hist_ratio = max(counts) / sum(counts);
    
    % 维度2：局部方差检测
    local_var = 0.5*var(patch1(:)) + 0.5*var(patch2(:));
    
    % 维度3：梯度一致性检测
    [grad_x, grad_y] = gradient(Patch_f);
    grad_magnitude = mean(abs(grad_x(:)) + abs(grad_y(:)));
    
    % 动态阈值设置
    if local_var < 50
        hist_threshold = 0.6;
    elseif local_var > 100
        hist_threshold = 0.85;
    else
        hist_threshold = 0.75;
    end
    
    % 综合决策
    is_artifacts = (hist_ratio > hist_threshold) || (grad_magnitude < 5);
    confidence = hist_ratio*0.6 + (1 - local_var/100)*0.4;
end

%% 新增辅助函数 - 动态权重分配
function w = dynamic_weight(patch1, patch2)
    % 质量评估指标
    q1 = 0.7*var(patch1(:)) + 0.3*mean(edge(patch1,'canny'),'all');
    q2 = 0.7*var(patch2(:)) + 0.3*mean(edge(patch2,'canny'),'all');
    
    % 非线性权重映射
    w = 1 ./ (1 + exp(-5*(q1-q2)/(q1+q2+eps)));
end

%% 新增辅助函数 - 边缘保持融合
function fused = edge_preserving_fusion(p1, p2, w1, w2)
    % 边缘检测
    edge_mask = edge(p1,'canny') | edge(p2,'canny');
    
    % 基础融合
    fused_base = w1*p1 + w2*p2;
    
    % 边缘增强
    fused_edge = 0.5*p1 + 0.5*p2;
    
    % 合并结果
    fused = fused_base;
    fused(edge_mask) = fused_edge(edge_mask);
end

%% 新增辅助函数 - 引导滤波
function q = guided_filter(I, p, r, eps)
    % I: 引导图像, p: 输入图像, r: 窗口半径, eps: 正则化参数
    mean_I = imboxfilt(I, [r r]);
    mean_p = imboxfilt(p, [r r]);
    corr_I = imboxfilt(I.*I, [r r]);
    cov_Ip = imboxfilt(I.*p, [r r]);
    
    var_I = corr_I - mean_I.*mean_I;
    cov_Ip = cov_Ip - mean_I.*mean_p;
    
    a = cov_Ip ./ (var_I + eps);
    b = mean_p - a.*mean_I;
    
    mean_a = imboxfilt(a, [r r]);
    mean_b = imboxfilt(b, [r r]);
    
    q = mean_a.*I + mean_b;
end

%% 新增辅助函数 - 灰度引导图生成
function gray = mean2gray(p1, p2)
    % 生成加权灰度引导图
    gray = 0.5*im2gray(p1) + 0.5*im2gray(p2);
    if size(p1,3) == 1  % 单通道图像处理
        gray = 0.5*p1 + 0.5*p2;
    end
end