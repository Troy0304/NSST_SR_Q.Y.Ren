function F=sparse_fusion_0317(X1,X2,D,overlap,epsilon)
%    SR
%    Input:
%    A - input image A
%    B - input image B
%    D  - Dictionary for sparse representation
%    overlap - the overlapped pixels between two neighbor patches
%    epsilon - sparse reconstuction error
%    Output:
%    F  - fused image

% normalize the dictionary
A = X1;
B = X2;

norm_D = sqrt(sum(D.^2, 1)); 
D = D./repmat(norm_D, size(D, 1), 1);

patch_size = sqrt(size(D, 1));
[h,w]=size(A);
F=zeros(h,w);
cntMat=zeros(h,w);
epsilon = epsilon + 0.05*(patch_size/8); % 自适应误差阈值
% 在循环前定义窗口函数
window = hann(patch_size)*hann(patch_size)'; 

gridx = 1:patch_size - overlap : w-patch_size+1;
gridy = 1:patch_size - overlap : h-patch_size+1;

G=D'*D;
for ii = 1:length(gridx)
    for jj = 1:length(gridy)
        xx = gridx(ii);
        yy = gridy(jj);
        
        patch_1 = A(yy:yy+patch_size-1, xx:xx+patch_size-1);
        mean1 = mean(patch_1(:));
        patch1 = patch_1(:) - mean1;
        patch_2 = B(yy:yy+patch_size-1, xx:xx+patch_size-1);
        mean2 = mean(patch_2(:));
        patch2 = patch_2(:) - mean2;
        w1=omp2(D,patch1,G,epsilon);
        w2=omp2(D,patch2,G,epsilon);
        
        % 计算稀疏性比例
        sum_w1 = sum(abs(w1));
        sum_w2 = sum(abs(w2));
        alpha = sum_w1 / (sum_w1 + sum_w2 + 0.01);

        % 动态融合稀疏系数和均值
        w = alpha * w1 + (1 - alpha) * w2;
        mean_f = alpha * mean1 + (1 - alpha) * mean2;

        patch_f=D*w;
        Patch_f = reshape(patch_f, [patch_size, patch_size]);
        Patch_f = Patch_f + mean_f;
       
        F(yy:yy+patch_size-1, xx:xx+patch_size-1) = F(yy:yy+patch_size-1, xx:xx+patch_size-1) + Patch_f.*window;
        cntMat(yy:yy+patch_size-1, xx:xx+patch_size-1) = cntMat(yy:yy+patch_size-1, xx:xx+patch_size-1) + window;        
    end
end


idx = (cntMat < 1);
F(idx) = (A(idx)+B(idx))./2;
cntMat(idx) = 1;

F = F./cntMat;

end