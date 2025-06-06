function F = nsst_fuse(X1, X2,c,X0_1,X0_2)
% X1,X2:两幅子带图像 
[M, N] = size(X1);
F = zeros(M,N);

VSC1 = VSC(X1,X0_1);
VSC2 = VSC(X2,X0_2);

for i = 1:M
    for j = 1:N
        if VSC1(i,j)>=VSC2(i,j)
            F(i,j)=X1(i,j)*0.8+X2(i,j)*0.2;
        else 
            F(i,j)=X1(i,j)*0.2+X2(i,j)*0.8;
        end
        F(i,j)=F(i,j)+c*X2(i,j);
    end
end
end
