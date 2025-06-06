function sml = SML(I)
%改进的拉普拉斯能量

[M, N] = size(I);
ML = zeros(M, N);
for i = 2:M-1
    for j = 2:N-1
       ML(i,j) = 2*I(i,j) - I(i-1,j) - I(i+1,j) + 2*I(i,j) - I(i,j-1) - I(i,j+1); 
    end
end

sml = zeros(M,N);

for i = 1:M
    for j = 1:N
        sml(i,j) = sum(sum(ML(max(1,i-1):min(M,i+1),max(1,j-1):min(N,j+1))));
    end
end

end


