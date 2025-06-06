function F=sparse_fusion_new(X1,X2,D,overlap,epsilon)
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
        w=w1*0.7+w2*0.3;
        mean_f=mean1;
        if (sum(abs(w1)))<(sum(abs(w2)))
            w=w2*0.7+w1*0.3;
            mean_f=mean2;
        end
        
        patch_f=D*w;
        Patch_f = reshape(patch_f, [patch_size, patch_size]);
        Patch_f = Patch_f + mean_f;
        
         % calculate the histogram of the sparse fusion result
        [counts, ~] = imhist(Patch_f);
        
        % if the proportion of the most common value is greater than 70%, use the weighted fusion result
        if max(counts) / sum(counts) > 0.8
            Patch_f = patch_1 * 0.2 + patch_2 * 0.8;
        end
        
        F(yy:yy+patch_size-1, xx:xx+patch_size-1) = F(yy:yy+patch_size-1, xx:xx+patch_size-1) + Patch_f;
        cntMat(yy:yy+patch_size-1, xx:xx+patch_size-1) = cntMat(yy:yy+patch_size-1, xx:xx+patch_size-1) + 1;
        
    end
end


idx = (cntMat < 1);
F(idx) = (A(idx)+B(idx))./2;
cntMat(idx) = 1;

F = F./cntMat;