clear; clc; close all;

% 生成Gold序列
m1=[1 0 0 0 0 1 0 0 1 0 1 1 0 0 1 1 1 1 1 0 0 0 1 1 0 1 1 1 0 1 0];
m2=[1 1 1 1 1 0 1 1 1 0 0 0 1 0 1 0 1 1 0 1 0 0 0 0 1 1 0 0 1 0 0];
L = length(m1);
Gold_matrix = zeros(L+1, L);
Gold_matrix(1, :) = m1;
Gold_matrix(2, :) = m2;
Gold_matrix(3, :) = xor(m1, m2);
for k = 1:L-1
    Gold_matrix(3+k, :) = xor(m1, circshift(m2, k));
end


%% 参数
num_bits = 1e5;
sf = 31;
EbN0_dB = 0:1:10;

Rb = 100;
Rchip = sf*Rb;
fc = Rchip;
fs = 2*fc;
sps = fs/Rb;
chip_sps = sps / sf;

ber_bpsk_sim = zeros(size(EbN0_dB));
ber_dsss_sim = zeros(size(EbN0_dB));
ber_bpsk_theory = zeros(size(EbN0_dB));



for idx = 1:length(EbN0_dB)

    EbN0 = 10^(EbN0_dB(idx)/10);

    %% 理论
    ber_bpsk_theory(idx) = 0.5 * erfc(sqrt(EbN0));

    %%
    bits = randi([0 1], 1, num_bits);
    symbols_base = 2*bits - 1;
    symbols = repelem(symbols_base,sps);

    t = (0:length(symbols)-1)/fs;
    carrier = cos(2*pi*fc*t);
    bpsk_tx = symbols.*carrier;

    %% 仿真 BPSK
     mean(abs(bpsk_tx).^2)
     noise = sqrt(1/(2*EbN0)) * randn(1, length(bpsk_tx));
     bpsk_rx = bpsk_tx + noise;

     rx = bpsk_rx .* carrier;
     rx_bpsk = zeros(1,num_bits);
     for k = 1:num_bits
        m = ((k-1)*sps + 1) : k*sps;
        rx_bpsk(k)  = sum(rx(m));
    end

    bits_hat = rx_bpsk > 0;
    ber_bpsk_sim(idx) = sum(bits ~= bits_hat)/num_bits;

    %% 仿真 DSSS

    gold = 2*Gold_matrix(8,:) - 1;

    % 扩频
    spread_base = kron(symbols_base, gold);
    spread = repelem(spread_base,sps/sf);
    dsss_tx = spread.*carrier;
    
    mean(abs(dsss_tx).^2)
    noise_dsss =sqrt(sps/(2*(EbN0))) * randn(1, length(dsss_tx));
    rx_spread = dsss_tx + noise_dsss;

    rx_dsss = rx_spread.*carrier;

    chips_rec = zeros(1,num_bits*sf);
    decision = zeros(1,num_bits);
    % 解扩
    for k = 1:num_bits*sf
        m = ((k-1)*chip_sps + 1) : k*chip_sps;
        chips_rec(k) = sum(rx_dsss(m));
    end
    for k = 1:num_bits
        m = ((k-1)*sf + 1) : k*sf;
        decision(k) = sum(chips_rec(m) .* gold);
    end

    bits_hat_dsss = decision > 0;
    ber_dsss_sim(idx) = sum(bits ~= bits_hat_dsss)/num_bits;

end

%% 绘图
figure;
semilogy(EbN0_dB, ber_bpsk_theory, 'bo-'); hold on;
semilogy(EbN0_dB, ber_bpsk_sim, 'r*-');
semilogy(EbN0_dB, ber_dsss_sim, 'gs-');

grid on;
xlabel('E_b/N_0 (dB)');
ylabel('BER');
legend('理论BPSK', '仿真BPSK', '仿真DSSS');
title('BER性能对比');