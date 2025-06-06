function VSC = VSC(Z, Z0)
    % 计算区域平均值
    K = 5;
    [M, N] = size(Z0);
    Z0_avg = zeros(M, N);
    for x = 1:M
        for y = 1:N
            Z0_avg(x, y) = mean(mean(Z0(max(1, x-K):min(M, x+K), max(1, y-K):min(N, y+K))));
        end
    end

    % 计算视觉敏感度系数
    VSC = abs(Z) ./ Z0_avg;
end