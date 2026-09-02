function [rxChannelAll,objList_decode,paramsConfig] = DDMADemodulate(rangeDoppler,detMatrix_dB,detObjlist_subBand,detRangeSNR,paramsConfig)

numRXchannels = paramsConfig.numRXchannels;
numTX = paramsConfig.numTX;
numBands = paramsConfig.numBands;
numActiveBands = paramsConfig.numActiveBands;
numChirps = paramsConfig.numChirps;

[detObjDopBin,detObjRngBin] = find(detObjlist_subBand ~= 0);
numObjList = length(detObjRngBin);
rxChannelAll = zeros(numObjList,numTX*numRXchannels);
objList_decode = zeros(numObjList,3);   % range,doppler,SNR

for rangeLineIdx = 1:numObjList

    dopplerFFTSize = length(rangeDoppler(1,:,1));

    TxShiftBinArr_temp = ((0:numBands-1)/numBands)*dopplerFFTSize;          % 获得DDMA相位偏移指数
    TxShiftBinArrPerObj = detObjDopBin(rangeLineIdx) + TxShiftBinArr_temp;  % 每个目标的相移位置
    TxShiftBinArrPerObj(TxShiftBinArrPerObj<=0) = TxShiftBinArrPerObj(TxShiftBinArrPerObj<=0) + numChirps;
    sumDopplerMetric = zeros(numBands,1);                                   % 存放8个子带的积累值，用于寻找第一发射通道

    % 对目标点的各子带相应位置的点做8个点的能量积累
    for ii = 1:numBands
        for jj = 1:numActiveBands
            searchIdx = ii + jj - 1;
            if searchIdx > numBands
                searchIdx = searchIdx - numBands;
            end
            sumDopplerMetric(ii) = sumDopplerMetric(ii) + detMatrix_dB(TxShiftBinArrPerObj(searchIdx),detObjRngBin(rangeLineIdx));
        end
    end

    [~,maxChannel] = max(sumDopplerMetric);             % 第一发射通道所在的子带
    realDopplerIdx = TxShiftBinArrPerObj(maxChannel);   % 第一发射通道处目标的dopplerIdx

    rxChannelData = [];                                 % 所有通道幅相值
    % 根据第一通道来获得当前目标的所有通道的幅相值
    for nn = 1:numActiveBands
        RangeIdx = detObjRngBin(rangeLineIdx);
        channelIdx = maxChannel + nn - 1;

        if channelIdx > numBands
            channelIdx = channelIdx - numBands;
        end

        DopplerIdx = TxShiftBinArrPerObj(channelIdx);

        rxChannelData_temp = squeeze(rangeDoppler(RangeIdx,DopplerIdx,:));
        rxChannelData = cat(1,rxChannelData,rxChannelData_temp); % 48x1

    end

    rxChannelAll(rangeLineIdx,:) = rxChannelData.';%对应每个目标的所有通道幅相值（TX1~TX6顺序存储）PCB板位置上的顺序是321654
    objList_decode(rangeLineIdx,1) = detObjRngBin(rangeLineIdx);
    objList_decode(rangeLineIdx,2) = realDopplerIdx;
    objList_decode(rangeLineIdx,3) = detRangeSNR(detObjDopBin(rangeLineIdx),detObjRngBin(rangeLineIdx));
%     objList_decode(rangeLineIdx,4) = detDopplerSNR(detObjDopBin(rangeLineIdx),detObjRngBin(rangeLineIdx));

end
paramsConfig.numObjList = numObjList;

end

