function m_seq = M_Sequence(poly)
    % poly: 这里的 poly 是本原多项式的系数向量
    % 例如对于 n=5, 常用多项式 [1 0 0 1 0 1] 代表 x^5 + x^2 + 1
    
    n = length(poly) - 1;       % 寄存器级数
    N = 2^n - 1;                % M 序列的周期
    m_seq = zeros(1, N);        % 预分配内存
    
    % 初始化寄存器状态（不能全为0，通常初始化为全1）
    register = ones(1, n);      
    
    % 提取反馈抽头位置（排除最高次项）
    % 比如 poly = [1 0 0 1 0 1], 我们需要 [0 0 1 0 1] 对应的位置
    taps = poly(2:end); 
    
    for i = 1:N
        m_seq(i) = register(n); % 输出寄存器最后一级的结果
        
        % 计算反馈位：将抽头位置对应的寄存器值进行模2加（异或）
        feedback = mod(sum(register .* taps(1:n)), 2);
        
        % 移位操作
        register = [feedback, register(1:n-1)];
    end
end