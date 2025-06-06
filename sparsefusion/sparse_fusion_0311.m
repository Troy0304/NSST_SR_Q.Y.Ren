function F=sparse_fusion_0311(X1,X2,D,overlap,epsilon)
%    SR
%    Input:
%    A - input image A
%    B - input image B
%    D  - Dictionary for sparse representation
%    overlap - the overlapped pixels between two neighbor patches
%    epsilon - sparse reconstuction error
%    Output:
%    F  - fused image   
%
%    The code is edited by Yu Liu, 01-09-2014.

% normalize the dictionary
A = X1;
B = X2;

norm_D = sqrt(sum(D.^2, 1)); 
D = D./repmat(norm_D, size(D, 1), 1);

patch_size = sqrt(size(D, 1));
[h,w]=size(A);
F=zeros(h,w);
cntMat=zeros(h,w);

gridx = 1:patch_size - overlap : w-patch_size+1;
gridy = 1:patch_size - overlap : h-patch_size+1;

%cnt=0;  
G=D'*D;
for ii = 1:length(gridx)
    for jj = 1:length(gridy)
        %cnt = cnt+1;
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
        % 动态字典更新 (ADR核心)

        %w=w1;
        %mean_f=mean1;
        %if sum(abs(w1))<sum(abs(w2))
        %    w=w2;
        %    mean_f=mean2;
        %end
        w=w1*0.7+w2*0.3;
        %w=w1;
        mean_f=mean1;
        if (sum(abs(w1)))<(sum(abs(w2)))
            w=w2*0.7+w1*0.3;
            mean_f=mean2;
        end
        
        [D, G] = adr_update(D, patch1,w); % 更新字典
        [D, G] = adr_update(D, patch2,w); % 可同时更新两个源

        patch_f=D*w;
        Patch_f = reshape(patch_f, [patch_size, patch_size]);
        Patch_f = Patch_f + mean_f;
        
        F(yy:yy+patch_size-1, xx:xx+patch_size-1) = F(yy:yy+patch_size-1, xx:xx+patch_size-1) + Patch_f;
        cntMat(yy:yy+patch_size-1, xx:xx+patch_size-1) = cntMat(yy:yy+patch_size-1, xx:xx+patch_size-1) + 1;
        
    end
    %cnt
end

idx = (cntMat < 1);
F(idx) = (A(idx)+B(idx))./2;
cntMat(idx) = 1;

F = F./cntMat;
end

function [D_new, G_new] = adr_update(D, patch,w)

    % 根据稀疏编码误差自适应调整α
    alpha = 0.9;  % 残差越大，更新越激进

    % 精确投影计算
    A = softmax(D' * patch);
    
    % 正确Sherman-Morrison应用
    numerator = patch * A';
    denominator = (A' * A) + eps('double');
    update = numerator / denominator;
    
    D_new = alpha * D + (1 - alpha) * update;
    
    norms = sqrt(sum(D_new.^2, 1));
    D_new = double(D_new ./ norms);  
    G_new = double(D_new' * D_new);
end

%% Softmax函数 (按行处理)
function s = softmax(x)
    s = exp(x - max(x)) ./ sum(exp(x - max(x)), 1);
end
