function [RangeCFARparametersSubBand,DopplerCFARparametersSubBand] = cfgParamSet_subBandCfar(R_res,chirpClassify)
if chirpClassify == 0.2
    %% 0.2m 波形
    RangeCFARparametersSubBand.numNoiseCell = 12;       % 噪底搜索长度
    RangeCFARparametersSubBand.numGuardCell = 4;        % 保护单元长度
    RangeCFARparametersSubBand.k = 0.8;                 % 选取噪底系数
    RangeCFARparametersSubBand.threshold5 = 20;         % 0-5m阈值
    RangeCFARparametersSubBand.threshold10 = 15;        % 5-10m阈值
    RangeCFARparametersSubBand.threshold20 = 14;        % 10-20m阈值
    RangeCFARparametersSubBand.threshold30 = 10;        % 20-30m阈值
    RangeCFARparametersSubBand.threshold40 = 10;        % 30-40m阈值
    RangeCFARparametersSubBand.threshold50 = 8;         % 40-50m阈值
    RangeCFARparametersSubBand.threshold60 = 10;        % 50-60m阈值
    RangeCFARparametersSubBand.threshold70 = 10;        % 60-70m阈值
    RangeCFARparametersSubBand.threshold80 = 8;         % 70-80m阈值
    RangeCFARparametersSubBand.threshold90 = 8;         % 80-90m阈值
    RangeCFARparametersSubBand.threshold100 = 8;        % 90-100m阈值
    RangeCFARparametersSubBand.threshold150 = 8;       % 100m-150m阈值
    RangeCFARparametersSubBand.thresholdB150 = 8;      % 150m以后阈值
    RangeCFARparametersSubBand.R_res = R_res;
    RangeCFARparametersSubBand.startIdx = 2;            % 舍去前3个距离bin

    DopplerCFARparametersSubBand.numNoiseCell = 12;     % 噪底搜索长度
    DopplerCFARparametersSubBand.numGuardCell = 4;      % 保护单元长度
    DopplerCFARparametersSubBand.k = 0.8;               % 选取噪底系数
    DopplerCFARparametersSubBand.threshold5 = 28;       % 0-5m阈值
    DopplerCFARparametersSubBand.threshold10 = 10;      % 5-10m阈值
    DopplerCFARparametersSubBand.threshold20 = 10;      % 10-20m阈值
    DopplerCFARparametersSubBand.threshold30 = 11;       % 20-30m阈值
    DopplerCFARparametersSubBand.threshold40 = 10;      % 30-40m阈值
    DopplerCFARparametersSubBand.threshold50 = 10;      % 40-50m阈值
    DopplerCFARparametersSubBand.threshold60 = 10;      % 50-60m阈值
    DopplerCFARparametersSubBand.threshold70 = 10;      % 60-70m阈值
    DopplerCFARparametersSubBand.threshold80 = 10;      % 70-80m阈值
    DopplerCFARparametersSubBand.threshold90 = 8;       % 60-90m阈值
    DopplerCFARparametersSubBand.threshold100 = 8;      % 90-100m阈值
    DopplerCFARparametersSubBand.threshold150 = 10;     % 100m-150m阈值
    DopplerCFARparametersSubBand.thresholdB150 = 15;    % 150m以后阈值
    DopplerCFARparametersSubBand.R_res = R_res;

elseif chirpClassify == 1
    %% 0.4m 波形
    RangeCFARparametersSubBand.numNoiseCell = 16;       % 噪底搜索长度
    RangeCFARparametersSubBand.numGuardCell = 6;        % 保护单元长度
    RangeCFARparametersSubBand.k = 0.2;                 % 选取噪底系数
    RangeCFARparametersSubBand.threshold5 = 20;         % 0-5m阈值
    RangeCFARparametersSubBand.threshold10 = 18;        % 5-10m阈值
    RangeCFARparametersSubBand.threshold20 = 14;        % 10-20m阈值
    RangeCFARparametersSubBand.threshold30 = 10;        % 20-30m阈值
    RangeCFARparametersSubBand.threshold40 = 10;        % 30-40m阈值
    RangeCFARparametersSubBand.threshold50 = 13;        % 40-50m阈值
    RangeCFARparametersSubBand.threshold60 = 14;        % 50-60m阈值
    RangeCFARparametersSubBand.threshold70 = 12;        % 60-70m阈值
    RangeCFARparametersSubBand.threshold80 = 10;         % 70-80m阈值
    RangeCFARparametersSubBand.threshold90 = 10;         % 80-90m阈值
    RangeCFARparametersSubBand.threshold100 = 11;        % 90-100m阈值
    RangeCFARparametersSubBand.threshold150 = 8;        % 100m-150m阈值
    RangeCFARparametersSubBand.threshold200 = 8;        % 150m-200m以后阈值
    RangeCFARparametersSubBand.threshold250 = 8;        % 200m-250m以后阈值
    RangeCFARparametersSubBand.thresholdB250 = 8;       % 250m以后阈值
    RangeCFARparametersSubBand.R_res = R_res;
    RangeCFARparametersSubBand.startIdx = 2;            % 舍去前一个距离bin

    DopplerCFARparametersSubBand.numNoiseCell = 12;     % 噪底搜索长度
    DopplerCFARparametersSubBand.numGuardCell = 4;      % 保护单元长度
    DopplerCFARparametersSubBand.k = 0.4;               % 选取噪底系数
    DopplerCFARparametersSubBand.threshold5 = 20;       % 0-5m阈值
    DopplerCFARparametersSubBand.threshold10 = 20;      % 5-10m阈值
    DopplerCFARparametersSubBand.threshold20 = 20;      % 10-20m阈值
    DopplerCFARparametersSubBand.threshold30 = 19;      % 20-30m阈值
    DopplerCFARparametersSubBand.threshold40 = 17;      % 30-40m阈值
    DopplerCFARparametersSubBand.threshold50 = 13;      % 40-50m阈值
    DopplerCFARparametersSubBand.threshold60 = 14;      % 50-60m阈值
    DopplerCFARparametersSubBand.threshold70 = 12;      % 60-70m阈值
    DopplerCFARparametersSubBand.threshold80 = 10;      % 70-80m阈值
    DopplerCFARparametersSubBand.threshold90 = 10;      % 80-90m阈值
    DopplerCFARparametersSubBand.threshold100 = 11;     % 90-100m阈值
    DopplerCFARparametersSubBand.threshold150 = 8;     % 100m-150m阈值
    DopplerCFARparametersSubBand.threshold200 = 8;      % 150m-200m以后阈值
    DopplerCFARparametersSubBand.threshold250 = 8;      % 200m-250m以后阈值
    DopplerCFARparametersSubBand.thresholdB250 = 8;     % 250m以后阈值
    DopplerCFARparametersSubBand.R_res = R_res;

else
    %% 1.25m 波形
    RangeCFARparametersSubBand.numNoiseCell = 16;                  % 噪底搜索长度
    RangeCFARparametersSubBand.numGuardCell = 4;                   % 保护单元长度
    RangeCFARparametersSubBand.k = 0.4;                            % 选取噪底系数
    RangeCFARparametersSubBand.threshold10 = 10; % 0-10m阈值       %动态26 静态25
    RangeCFARparametersSubBand.threshold20 = 8; % 10-20m阈值      %动态26 静态24
    RangeCFARparametersSubBand.threshold30 = 11; % 20-30m阈值      %动态19 静态14
    RangeCFARparametersSubBand.threshold40 = 8; % 30-40m阈值
    RangeCFARparametersSubBand.threshold50 = 7; % 40-50m阈值
    RangeCFARparametersSubBand.threshold60 = 9; % 50-60m阈值
    RangeCFARparametersSubBand.threshold70 = 9; % 60-70m阈值
    RangeCFARparametersSubBand.threshold80 = 7; % 70-80m阈值
    RangeCFARparametersSubBand.threshold90 = 9; % 80-90m阈值
    RangeCFARparametersSubBand.threshold100 = 10.5; % 90m-100m以后阈值
    RangeCFARparametersSubBand.threshold150 = 9; % 100m-150m以后阈值
    RangeCFARparametersSubBand.threshold200 = 7; % 150m-200m以后阈值
    RangeCFARparametersSubBand.threshold250 = 7; % 200m-250m以后阈值
    RangeCFARparametersSubBand.thresholdB250 = 6; % 250m以后阈值
    RangeCFARparametersSubBand.R_res = R_res;
    RangeCFARparametersSubBand.startIdx = 2;

    DopplerCFARparametersSubBand.numNoiseCell = 12;                  % 噪底搜索长度
    DopplerCFARparametersSubBand.numGuardCell = 4;                   % 保护单元长度
    DopplerCFARparametersSubBand.k = 0.4;                            % 选取噪底系数
    DopplerCFARparametersSubBand.threshold10 = 18; % 0-10m阈值
    DopplerCFARparametersSubBand.threshold20 = 16; % 10-20m阈值
    DopplerCFARparametersSubBand.threshold30 = 10; % 20-30m阈值
    DopplerCFARparametersSubBand.threshold40 = 10; % 30-40m阈值
    DopplerCFARparametersSubBand.threshold50 = 10; % 40-50m阈值
    DopplerCFARparametersSubBand.threshold60 = 10; % 50-60m阈值
    DopplerCFARparametersSubBand.threshold70 = 10; % 60-70m阈值
    DopplerCFARparametersSubBand.threshold80 = 9; % 70-80m阈值
    DopplerCFARparametersSubBand.threshold90 = 8; % 80-90m阈值
    DopplerCFARparametersSubBand.threshold100 = 8; % 90m-100m以后阈值
    DopplerCFARparametersSubBand.threshold150 = 8; % 100m-150m以后阈值
    DopplerCFARparametersSubBand.threshold200 = 8; % 150m-200m以后阈值
    DopplerCFARparametersSubBand.threshold250 = 8; % 200m-250m以后阈值
    DopplerCFARparametersSubBand.thresholdB250 = 7; % 250m以后阈值
    DopplerCFARparametersSubBand.R_res = R_res;
    
end
end

