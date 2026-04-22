clear all;
m1=[1 0 0 0 0 1 0 0 1 0 1 1 0 0 1 1 1 1 1 0 0 0 1 1 0 1 1 1 0 1 0];
m2=[1 1 1 1 1 0 1 1 1 0 0 0 1 0 1 0 1 1 0 1 0 0 0 0 1 1 0 0 1 0 0];
%%
L = length(m1);
Gold_matrix = zeros(L+1, L);
Gold_matrix(1, :) = m1;
Gold_matrix(2, :) = m2;
Gold_matrix(3, :) = xor(m1, m2);

for k = 1:L-1
    Gold_matrix(3+k, :) = xor(m1, circshift(m2, k));
end

%%
subplot(5,1,1);
stem(0:length(m1)-1,m1);
subplot(5,1,2);
stem(0:length(m2)-1,m2);

subplot(5,1,3);
R_m1m1 = self_R(m1);
R_5cycles = repmat(R_m1m1, 1, 5);
plot(0:length(R_5cycles)-1,R_5cycles);

subplot(5,1,4);
R_m2m2 = self_R(m2);
R_5cycles = repmat(R_m2m2, 1, 5);
plot(0:length(R_5cycles)-1,R_5cycles);

subplot(5,1,5);
R_m1m2 = cor_R(m1,m2);
R_5cycles = repmat(R_m1m2, 1, 5);
plot(0:length(R_5cycles)-1,R_5cycles);

%%
Gold1 = Gold_matrix(8,:);
Gold2 = Gold_matrix(18,:);
figure;

subplot(3,1,1);
R_g1g1 = self_R(Gold1);
R_5cycles = repmat(R_g1g1, 1, 5);
plot(0:length(R_5cycles)-1,R_5cycles);

subplot(3,1,2);
R_g2g2 = self_R(Gold2);
R_5cycles = repmat(R_g2g2, 1, 5);
plot(0:length(R_5cycles)-1,R_5cycles);

subplot(3,1,3);
R_g1g2 = cor_R(Gold1,Gold2);
R_5cycles = repmat(R_g1g2, 1, 5);
plot(0:length(R_5cycles)-1,R_5cycles);
%%
figure;
N = 400000;
fs = 100000;
R_5cycles = repmat(R_g2g2, 1, 5);
yyb = fft(R_5cycles, N);
magb = abs(yyb);           
fbb = (0:N/2-1)*fs/N;      % 频率轴从0开始更标准，fs是采样率
plot(fbb, magb(1:N/2)*2/N);

%%
n = 100;
Rb = 10;                    % 比特率

Gold1 = Gold_matrix(8,:);
L = length(Gold1);

Rchip = L*Rb;
fc = 10*Rchip;                  % 载波频率 
fs = 10*fc;                    % 采样率 1 MHz
sps = fs/Rb;

sign_base = randi([0 1], 1, n);

subplot(3,1,1);
stem(sign_base);
title('随机码波形');

Gold1 = Gold_matrix(8,:);
repeat_times = Rchip/(L*Rb);
gold_base=repmat(Gold1,1,repeat_times);

gold_base_bpsk = 2*gold_base - 1;            % 映射到±1
sign_base_bpsk = 2*sign_base - 1;

sign_base_Waveform = repelem(sign_base_bpsk,sps);
t = (0:length(sign_base_Waveform)-1)/fs;
carrier = cos(2*pi*fc*t);
sign_high_nogold = sign_base_Waveform.*carrier;

subplot(3,1,2);
plot(t,sign_high_nogold);
xlabel('s');
title('扩频前bpsk信号时域波形');
axis([0.09,0.102,-1.2,1.2]);

dsss_base=kron(sign_base_bpsk,gold_base_bpsk);
dsss_Waveform = repelem(dsss_base,sps/L);
t = (0:length(dsss_Waveform)-1)/fs;
carrier = cos(2*pi*fc*t);
dsss_high = dsss_Waveform .* carrier;

subplot(3,1,3);
plot(t,dsss_high);
xlabel('s');
title('扩频后bpsk信号时域波形');
axis([0,1.1e-2,-1.2,1.2]);

%%
figure;
                
N_fft = 4096;                     
window=boxcar(length(Gold1)); %矩形窗
[Pxx, f] = periodogram(Gold1, window, N_fft, fs, 'centered');
Pxx_dB = 10*log10(Pxx);
plot(f, Pxx_dB, 'LineWidth', 1);

xlabel('频率 (Hz)');
ylabel('功率/频率 (dB/Hz)');
title('Gold序列功率谱估计 (周期图法)');
xlim([-fs/2, fs/2]);
%%
figure;
plot(f, Pxx, 'LineWidth', 1);
grid on;

% 设置坐标轴和标签
xlabel('频率 (Hz)');
ylabel('功率/频率 (W/Hz)');
title('Gold序列功率谱估计 (周期图法)');

xlim([-fs/2, fs/2]);

%%
figure;
N = 2^nextpow2(length(sign_high_nogold));
yyb = fft(sign_high_nogold, N);
magb = abs(yyb);           
fbb = (0:N/2-1)*fs/N;      
subplot(2,1,1);
plot(fbb, magb(1:N/2)*2/N);
axis([2.4e3,4e3,0,0.1]);

yyb = fft(dsss_high, N);
magb = abs(yyb);           
fbb = (0:N/2-1)*fs/N;      
subplot(2,1,2);
plot(fbb, magb(1:N/2)*2/N);
axis([2.4e3,4e3,0,0.1]);


