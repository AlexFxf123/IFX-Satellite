function [result_thre3_subBand,detRangeSNR] = cfarSubBand(detMatrixSubBand,RangeCFARparametersSubBand,DopplerCFARparametersSubBand,numChirpsPerSubBand,paramsConfig)

dopplerSubBand = 1;     % doppler Idx for debug 
rangeSubBand  =  62;    % range Idx for debug 
debugCfarSubBand = 0;   % switch for debug 
numRangeAll = 0;        % number of objs after range cfar
numDopplerAll = 0;      % number of objs after doppler cfar
detRangeSNR = zeros(paramsConfig.numChirpsPerSubBand,paramsConfig.ADCsamples_Per_Chirp/2);       % SNR of objs after range cfar
detDopplerSNR = zeros(paramsConfig.numChirpsPerSubBand,paramsConfig.ADCsamples_Per_Chirp/2);     % SNR of objs after doppler cfar
ADCsamples_Per_Chirp = paramsConfig.numFFTRange/2;
FFTRateFactorRng = paramsConfig.FFTRateFactorRng;

result_thre1_subBand = zeros(numChirpsPerSubBand,ADCsamples_Per_Chirp);
result_thre2_subBand = zeros(numChirpsPerSubBand,ADCsamples_Per_Chirp);

noiseRange = mean(mean(detMatrixSubBand(:,(end-16):end))); % 最后16个距离单元均值作为噪底

for j = 1:numChirpsPerSubBand
    if j < dopplerSubBand && debugCfarSubBand == 1
        continue
    end
    [detIdxAlongRangeSubBand, detRangeSNRSubBand, num_out_rangeSubBand] = CFAR_OS_range(detMatrixSubBand(j,:),RangeCFARparametersSubBand,rangeSubBand,debugCfarSubBand,noiseRange,FFTRateFactorRng);
    result_thre1_subBand(j,detIdxAlongRangeSubBand) = 1;
    numRangeAll = numRangeAll + num_out_rangeSubBand;
    detRangeSNR(j,:) = detRangeSNRSubBand;
end

for j = RangeCFARparametersSubBand.startIdx:ADCsamples_Per_Chirp
    if j < rangeSubBand && debugCfarSubBand == 1
        continue
    end
    [detIdxAlongDopplerSubBand, detDopplerSNRSubBand, num_out_dopplerSubBand] = CFAR_OS_doppler(detMatrixSubBand(:,j).', j, DopplerCFARparametersSubBand,dopplerSubBand,debugCfarSubBand,FFTRateFactorRng);
    result_thre2_subBand(detIdxAlongDopplerSubBand,j) = 1;
    numDopplerAll = numDopplerAll + num_out_dopplerSubBand;
    detDopplerSNR(:,j) = detDopplerSNRSubBand.';
end

result_thre3_subBand = result_thre1_subBand .* result_thre2_subBand;

end

