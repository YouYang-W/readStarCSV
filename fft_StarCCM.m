% --------
% 处理STAR-CCM+的CSV文件的压强数据，进行FFT
% 功能：绘制频率/声压级频谱、频率/PSD频谱。计算脉动压强级、总级
% --------
% 处理单列 数据：时间  | 压强 | 压强 | ......

% 2026年1月7日修订：关于PSD计算部分

addpath('G:\codeStorage\matlab\readStarCSV'); % 读取程序模块

%% 读取数据
filename = 'G:\codeStorage\matlab\readStarCSV\example.csv';
T = readStarCSV(filename);
T_copy = T;

p_ref   = 1e-6;                               % 参考声压
L       = length(T_copy.physical_time_s);     % 信号长度
Fs      = 1/mean(diff(T_copy.physical_time_s)); % 采样率
delta_f = Fs/L;                               % 频率分辨率
fprintf('频率分辨率：%.2f Hz\n' , delta_f);
fprintf('信号持续时间：%.2f s\n', L/Fs);
d       = 0.01822;
D       = 0.04445;
Beta    = d.^2/D.^2 ;
U       = 0.336;                              % 流速

f        = Fs * (0:(L/2)) / L;                % 生成频率
f        = f(2:end);                          % 去掉 0 Hz
f_T      = f';                                % 转置

%% FFT
signalColName = 'up_wall_1';
Signal = T_copy{:, signalColName};
Signal = Signal - mean(Signal); % 习惯上先去直流分量（减去平均压力）
Signal_fft  = fft(Signal) ;  % FFT得到 实部(幅值)＋虚部(相位)

Magnitude = abs( Signal_fft(1:L/2 + 1) ) / (L/2) ;
Magnitude_RMS = Magnitude / sqrt(2);
Magnitude_RMS = Magnitude_RMS(2:end);          % 去掉 0 Hz

% 注释：Magnitude是得到每个频率分量的单边谱峰值幅值
% 再除以 √2 转换为每个频率分量的RMS值

% PSD = Magnitude_RMS.^2 * (L / Fs);
% PSD = (Magnitude.^2 / 2) * (L / Fs) 第二种方法

% 计算声压级、总声级
SPL    = 20 * log10 ( Magnitude_RMS / p_ref ) ;
OSPL   = 10 * log10 ( sum( 10 .^ (SPL/10) ) );
fprintf('脉动压强总级：%.3f dB\n', OSPL);

% SPL频谱图
figure(1);
semilogx(f,SPL); xlabel('Frequency (Hz)'); ylabel('SPL (dB)');
grid on;                            % 开启网格
set(gca,'FontName','Times New Roman', ...
    'FontSize',18,'LineWidth',1.5);
title('SPL Spectrum');
% close();

%% PSD
% window: 窗口长度，通常取信号总长的 1/4 到 1/8。窗口越短，曲线越平滑，但频率分辨率会降低。
window_len = floor(L/4);
noverlap   = floor(window_len/2); % 50% 重叠
nfft       = window_len;          % FFT 点数，通常等于窗口长

[PSD_welch, f_welch] = pwelch(Signal, hanning(window_len), ...
                              noverlap, nfft, Fs);

figure(2);
loglog(f_welch,PSD_welch); xlabel('Frequency (Hz)'); ylabel('PSD (Pa^2/Hz)');
% grid on;
set(gca,'FontName','Times New Roman', ...
    'FontSize',18,'LineWidth',1.5);
title('PSD');
% xlim([0 5000])
% close();

%% 对频率和PSD无量纲
figure(3)
PSD_dimensionless = PSD_welch * (U/d) * power( (0.5 * 1000 * (U/Beta).^2), -2);
f_dimensionless   = f_welch * d / (U/Beta);
h_data            = loglog (f_dimensionless,PSD_dimensionless);
hold on;

St_slope_range    = [1e-2, 30]; % 选择一个跨越主要频段的 St 范围
PSD_slope_line    = 1e-4 * (St_slope_range).^(-11/3); % 计算参考线的值
h_slope           = loglog (St_slope_range, PSD_slope_line, 'k--', 'LineWidth', 1.2);

xlim([1e-2,20]);ylim([1e-10,1e-1]);
xlabel('St');
label_str = '$\frac{\Phi_{pp} \frac{U_o}{D_o}}{\left(0.5 \rho U_o^2\right)^2}$';

ylabel(label_str, 'Interpreter', 'latex', 'FontSize', 22);

legend([h_data, h_slope], {'STAR-CCM+', '$St^{-11/3}$'}, ...
    'Interpreter', 'latex', 'Location', 'southwest', 'FontSize', 14);
title('Dimensionless PSD Comparison');
grid on;
% close();

copy = [f_dimensionless, PSD_dimensionless];
fprintf('处理完成！\n');