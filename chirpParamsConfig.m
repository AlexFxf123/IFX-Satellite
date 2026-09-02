function paramsConfig = chirpParamsConfig(chirpClassify)
%% Parsing the ADC data
c = 3e8;                                        % 光速（m/s）
freqStart = 76e9;                               % 起始频率（Hz）
idleTimeConst = 12.8*1e-6;                      % chirp下降时间（s）
rampEndTime = 26*1e-6;                          % chirp上升时间（s）
Sample_rate = 25e6;                             % 采样频率（Hz）
Sample_time = 20.48e-6;                         % 采样时间（s）
Samples_per_Chirp = Sample_time*Sample_rate;    % 采样点数
numChirpsInLoop = 12;                           % 每次循环发波数
numLoops = 32;                                  % 发波循环次数
numRXChannelPerDevice = 4;                      % 每块级联芯片接收通道数量
numTXPerDevice = 4;                             % 每块级联芯片发射通道数量
numBands = 12;                                  % 子带划分数量
emptyBands = 4;                                 % 空带数量
numDevices = 2;                                 % 级联芯片数量

paramsConfig.ADCsamples_Per_Chirp = Samples_per_Chirp;
paramsConfig.numChirpsInLoop = numChirpsInLoop;
paramsConfig.numLoops = numLoops;
paramsConfig.numTX = numDevices*numTXPerDevice;
paramsConfig.numRXChannelPerDevice = numRXChannelPerDevice;
paramsConfig.numRXchannels = numDevices*numRXChannelPerDevice;
paramsConfig.numChirps = numChirpsInLoop*numLoops;
paramsConfig.numBands = numBands;
paramsConfig.numActiveBands = numBands - emptyBands;
paramsConfig.numChirpsPerSubBand = paramsConfig.numChirps/paramsConfig.numBands;

paramsConfig.numObjList = 0;                                                % 探测目标数量

if chirpClassify == 0.2
    % Parsing the chirp 0.366m    
    freqSlopeConst = 36.5*1e12;                                               % 频率斜率

elseif chirpClassify == 1
    % Parsing the chirp 0.732m
    freqSlopeConst = 7.32422*1e12;                                               % 频率斜率

else
    % Parsing the chirp 1.25m
    freqSlopeConst = 6*1e12;                                                % 频率斜率

end
B = 1/Sample_rate*paramsConfig.ADCsamples_Per_Chirp*freqSlopeConst;         % chirp有效带宽
Tp = idleTimeConst+rampEndTime;                                             % chirp总时间
lamda = c/(freqStart+B/2);                                                  % 中心频率计算波长
paramsConfig.R_res = c/2/B;                                                 % 距离分辨率
paramsConfig.R_Max = paramsConfig.R_res*paramsConfig.ADCsamples_Per_Chirp;  % 最远探测距离
paramsConfig.V_Max = lamda/4/Tp;                                            % 最大不模糊速度,相比于单发模式降低了一半
paramsConfig.V_res = paramsConfig.V_Max*2/paramsConfig.numChirps;           % 速度分辨率，相比于单发模式也降低了一半


%% 天线阵元配置
paramsConfig.virtualPosAzi = [10,7,25,17,28,34,24,21,39,31,42,48,36,33,51,43,54,60,38,35,53,45,56,62,40,37,55,47,58,64];  % 方位虚拟阵列坐标 
paramsConfig.aziIdx = [17,18,19,20,21,22,33,34,35,36,37,38,41,42,43,44,45,46,49,50,51,52,53,54,57,58,59,60,61,62];        % 方位虚拟阵列idx
paramsConfig.virtualPosEle = [1,20,10,7,26,16,21,40,30,13,32,22];                                     % 俯仰虚拟阵列
paramsConfig.eleIdx = [6,7,8,14,15,16,22,23,24,30,31,32];                                       % 俯仰虚拟阵列idx
paramsConfig.TxOrder = [2,1,4,3,5,6,7,8];                                                          % 发射通道排列顺序
paramsConfig.RxOrder = [2,1,4,3,6,5,8,7];                                                          % 接收通道排列顺序
paramsConfig.spaceX = 0.5;                                                                         % 水平阵列单元间距
paramsConfig.spaceY = 0.5;                                                                        % 垂直阵列单元间距

%% RD处理配置
paramsConfig.FFTRateFactorRng = 1;                                                                 % 距离维度FFT扩展比例因子
paramsConfig.FFTRateFactorDop = 1;                                                                 % 速度维度FFT扩展比例因子
paramsConfig.numFFTRange = paramsConfig.FFTRateFactorRng * paramsConfig.ADCsamples_Per_Chirp;      % 距离维度FFT数量扩展
paramsConfig.numFFTDoppler = paramsConfig.FFTRateFactorDop * paramsConfig.numChirps;               % 距离维度FFT数量扩展

if paramsConfig.FFTRateFactorDop ~= 1
    paramsConfig.numChirpsPerSubBand = paramsConfig.numFFTDoppler/paramsConfig.numBands;
end

%% 测角配置
paramsConfig.doaPointIncresed01 = 0;                                                               % 测角增点开关，1：开，0：关
paramsConfig.doaPointIncresed002 = 0;                                                              % 测角增点开关，1：开，0：关
paramsConfig.numFFTDoA = 1024;                                                                      % FFT测角点数
paramsConfig.maxFovAzi = 60;                                                                       % 2DDBF方位搜索范围
paramsConfig.maxFovEle = 15;                                                                       % 2DDBF俯仰搜索范围
end

