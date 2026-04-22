function R = cor_R(m1, m2)
    % 计算两个0/1序列的互相关
    L = length(m1);
    m1_bip = 1 - 2*m1;
    m2_bip = 1 - 2*m2;
    
    R = zeros(1, L);
    for shift = 0:L-1
        m2_shifted = circshift(m2_bip, shift);
        R(shift + 1) = sum(m1_bip .* m2_shifted);
    end
end