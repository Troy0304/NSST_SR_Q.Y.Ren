function F = nsst_fuse_noVSC(X1, X2,c)
% X1,X2:两幅子带图像 
[M, N] = size(X1);
F = zeros(M,N);

SML1 = SML(X1);
SML2 = SML(X2);

CA = SML1.*X1;
CB = SML2.*X2;

for i = 1:M
    for j = 1:N
        if CA(i,j)>=CB(i,j)
            F(i,j)=X1(i,j)*0.8+X2(i,j)*0.2;
        else 
            F(i,j)=X1(i,j)*0.2+X2(i,j)*0.8;
        end
        F(i,j)=F(i,j)+c*X2(i,j);
    end
end

end