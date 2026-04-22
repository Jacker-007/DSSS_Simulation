clear; close all; clc;

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

%%
N_users = 10;
n = 100;
Rb = 10;                    % 比特率

Gold_user = Gold_matrix(1:N_users,:);
L = length(Gold_matrix(1,:));

Rchip = L*Rb;
fc = 40*Rchip;                
fs = 10*fc;                   
sps = fs/Rb;

user_bits = zeros(N_users,n);
for i=1:N_users
    user_bits(i,:) = randi([0 1], 1, n);
end

user_gold_base = 2*Gold_user - 1;            % 映射到±1
user_bits_base = 2*user_bits - 1;

user_dsss = zeros(N_users,n*L);

user_dsss_Waveform = zeros(N_users,n*sps);
user_dsss_high = zeros(N_users,n*sps);
t = (0:length(user_dsss_Waveform(1,:))-1)/fs;
carrier = cos(2*pi*fc*t);

for i=1:N_users
    user_dsss(i,:) = kron(user_bits_base(i,:),user_gold_base(i,:));
    user_dsss_Waveform(i,:) = repelem(user_dsss(i,:),sps/L);
    user_dsss_high(i,:) = user_dsss_Waveform(i,:).*carrier;
end

%%
user_dsss_recieve = sum(user_dsss_high, 1);

EbN0_dB = 5; 
EbN0_linear = 10^(EbN0_dB/10); 

Eb = L;
N0 = Eb / EbN0_linear;
sigma = sqrt(N0 / 2);

channel_Noise = sigma*randn(size(user_dsss_recieve));
user_dsss_recieve = user_dsss_recieve + channel_Noise;

%%
chip_sps = sps / L;
chips_rec = zeros(N_users,n*L);
bits_rec_dsss = zeros(N_users,n);

user_R = user_dsss_recieve.*carrier;

for i=1:N_users

    for k = 1:n*L
        idx = ((k-1)*chip_sps + 1) : k*chip_sps;
        chips_rec(i,k) = sum(user_R(idx));
    end

    for k = 1:n
        idx = ((k-1)*L + 1) : k*L;
        bits_rec_dsss(i,k)  = sum(chips_rec(i,idx).*user_gold_base(i,:));
    end
    
    bits_rec_dsss(i,:) = bits_rec_dsss(i,:) > 0;
    
    errors = sum(user_bits(i,:) ~= bits_rec_dsss(i,:));
    fprintf('第%d个用户: BER=%.4f \n', i,errors/n);

    figure;
    subplot(2,1,1);
    stem(user_bits(i,:), 'b', 'LineWidth', 1);
    ylim([-0.5 1.5]);
    subplot(2,1,2);
    stem(bits_rec_dsss(i,:), 'r', 'LineWidth', 1);
    ylim([-0.5 1.5]);
end




