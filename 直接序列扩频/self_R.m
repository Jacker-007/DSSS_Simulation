function R = self_R(m)
    L = length(m);
    m_bip = 1 - 2*m;
    R = zeros(1, L);
    for shift = 0:L-1
        m_shifted = circshift(m_bip, shift);
        R(shift + 1) = sum(m_bip .* m_shifted);
    end
end