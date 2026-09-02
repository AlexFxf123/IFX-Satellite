function [result_thre3_subBand,detRangeSNR] = detSubBand(paramsConfig,detMatrix_dB,plotSign,chirpClassify)
R_res = paramsConfig.R_res;
numBands = paramsConfig.numBands;
numChirpsPerSubBand = paramsConfig.numChirpsPerSubBand;
numActiveBands = paramsConfig.numActiveBands;
ADCsamples_Per_Chirp = paramsConfig.numFFTRange/2;                                                 % 取前一半（实数采样）

[RangeCFARparametersSubBand,DopplerCFARparametersSubBand] = cfgParamSet_subBandCfar(R_res,chirpClassify);   % 子带CFAR检测门限参数配置

detMatrixSubBand = zeros(numChirpsPerSubBand,ADCsamples_Per_Chirp);

%% 子带积累
for ii = 1:numBands
    detMatrixSubBand = detMatrixSubBand + detMatrix_dB((ii-1)*numChirpsPerSubBand+1:ii*numChirpsPerSubBand,:);
end
detMatrixSubBand = detMatrixSubBand./numActiveBands;%numBands;                                                              % 积累后取均值

if plotSign == 1
    figure(2);mesh(detMatrixSubBand);%hold on;
    xlabel('Range-bin');ylabel('Doppler-Bin');zlabel('Magnitude (dB)');
    title('子带积累RV图');
end

%% 对子带做CFAR检测
[result_thre3_subBand,detRangeSNR] = cfarSubBand(detMatrixSubBand,RangeCFARparametersSubBand,DopplerCFARparametersSubBand,numChirpsPerSubBand,paramsConfig);

end

