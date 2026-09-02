
function [detIdxAlongRange, detSNR, num_out] = CFAR_OS_doppler(data_in,idxRange, DopplerCFARparameters,dopplerIdx,debugCfar,FFTRateFactorRng)

numColumn = length(data_in);
detIdxAlongRange = zeros(1,numColumn);%先初始化一个长的，再变短
detSNR = zeros(1,numColumn);
noise_floor_aver = zeros(1,numColumn);
num_out = 0;
noiseIdx = round(DopplerCFARparameters.numNoiseCell * DopplerCFARparameters.k);
for ii=1:numColumn %doppler
    if ii < dopplerIdx && debugCfar == 1
        continue;
    end
    s = data_in(ii);
    if ii <= DopplerCFARparameters.numGuardCell + 1 % 最左边 小于保护单元
        noiseLeftIdx = (ii-DopplerCFARparameters.numGuardCell-DopplerCFARparameters.numNoiseCell+numColumn:ii-DopplerCFARparameters.numGuardCell-1+numColumn);% 中间
        noiseLeftIdx(noiseLeftIdx<=0) = noiseLeftIdx(noiseLeftIdx<=0)+numColumn;
        noiseLeft = data_in(noiseLeftIdx);
        noiseRightIdx = (ii+DopplerCFARparameters.numGuardCell+1:ii+DopplerCFARparameters.numGuardCell+DopplerCFARparameters.numNoiseCell);
        noiseRight = data_in(noiseRightIdx);
        noiseLR = sort([noiseLeft,noiseRight]);
        noise = noiseLR(noiseIdx*2);
    elseif ii > DopplerCFARparameters.numGuardCell + 1 && ii <= DopplerCFARparameters.numGuardCell+DopplerCFARparameters.numNoiseCell
        noiseLeftIdx = [(ii-DopplerCFARparameters.numGuardCell-DopplerCFARparameters.numNoiseCell+numColumn:numColumn) (1:ii-DopplerCFARparameters.numGuardCell-1)];% 左边，大于保护单元小于（保护单元+搜索单元）
        noiseLeft = data_in(noiseLeftIdx);
        noiseRightIdx = (ii+DopplerCFARparameters.numGuardCell+1:ii+DopplerCFARparameters.numGuardCell+DopplerCFARparameters.numNoiseCell);
        noiseRight = data_in(noiseRightIdx);
        noiseLR = sort([noiseLeft,noiseRight]);
        noise = noiseLR(noiseIdx*2);
    elseif ii > numColumn-DopplerCFARparameters.numGuardCell-DopplerCFARparameters.numNoiseCell && ii < numColumn-DopplerCFARparameters.numGuardCell
        noiseLeftIdx = (ii-DopplerCFARparameters.numGuardCell-DopplerCFARparameters.numNoiseCell:ii-DopplerCFARparameters.numGuardCell-1);
        noiseLeft = data_in(noiseLeftIdx);
        noiseRightIdx = [(ii+DopplerCFARparameters.numGuardCell+1:numColumn) (1:ii+DopplerCFARparameters.numGuardCell+DopplerCFARparameters.numNoiseCell-numColumn)];% 右边，大于最大值-（保护单元+搜索单元）小于最大值-保护单元
        noiseRight = data_in(noiseRightIdx);
        noiseLR = sort([noiseLeft,noiseRight]);
        noise = noiseLR(noiseIdx*2);
    elseif ii >= numColumn-DopplerCFARparameters.numGuardCell % 最右边，大于最大值-保护单元
        noiseLeftIdx = (ii-DopplerCFARparameters.numGuardCell-DopplerCFARparameters.numNoiseCell:ii-DopplerCFARparameters.numGuardCell-1);
        noiseLeft = sort(data_in(noiseLeftIdx));
        noiseRightIdx = (ii+DopplerCFARparameters.numGuardCell+1-numColumn:ii+DopplerCFARparameters.numGuardCell+DopplerCFARparameters.numNoiseCell-numColumn);% 右边，大于最大值-（保护单元+搜索单元）小于最大值-保护单元
        noiseRight = data_in(noiseRightIdx);
        noiseLR = sort([noiseLeft,noiseRight]);
        noise = noiseLR(noiseIdx*2);
    else
        noiseLeftIdx = (ii-DopplerCFARparameters.numGuardCell-DopplerCFARparameters.numNoiseCell:ii-DopplerCFARparameters.numGuardCell-1);% 中间
        noiseLeftIdx(noiseLeftIdx<=0) = noiseLeftIdx(noiseLeftIdx<=0)+numColumn;
        noiseLeft = data_in(noiseLeftIdx);
        noiseRightIdx = (ii+DopplerCFARparameters.numGuardCell+1:ii+DopplerCFARparameters.numGuardCell+DopplerCFARparameters.numNoiseCell);
        noiseRightIdx(noiseRightIdx>numColumn) = noiseRightIdx(noiseRightIdx>numColumn)-numColumn;
        noiseRight = data_in(noiseRightIdx);
        noiseLR = sort([noiseLeft,noiseRight]);
        noise = noiseLR(noiseIdx*2);
    end
    SNR = s - noise;
    range = DopplerCFARparameters.R_res * idxRange / FFTRateFactorRng;
    if range <= 5
        threshold = DopplerCFARparameters.threshold5;
    elseif range <= 10
        threshold = DopplerCFARparameters.threshold10;
    elseif range <= 20
        threshold = DopplerCFARparameters.threshold20;
    elseif range <= 30
        threshold = DopplerCFARparameters.threshold30;
    elseif range <= 40
        threshold = DopplerCFARparameters.threshold40;
    elseif range <= 50
        threshold = DopplerCFARparameters.threshold50;
    elseif range <= 60
        threshold = DopplerCFARparameters.threshold60;
    elseif range <= 70
        threshold = DopplerCFARparameters.threshold70;
    elseif range <= 80
        threshold = DopplerCFARparameters.threshold80;
    elseif range <= 90
        threshold = DopplerCFARparameters.threshold90;
    elseif range <= 100
        threshold = DopplerCFARparameters.threshold100;
    elseif range <= 150
        threshold = DopplerCFARparameters.threshold150;
    elseif range <= 200
        threshold = DopplerCFARparameters.threshold200;
    elseif range <= 250
        threshold = DopplerCFARparameters.threshold250;
    else
        threshold = DopplerCFARparameters.thresholdB250;
    end

    if SNR > threshold

        num_out = num_out + 1;
        detIdxAlongRange(num_out) = ii;
        detSNR(ii) = SNR;
        noise_floor_aver(num_out) = noise;

    end
end
% figure(1)
% plot(data_in)
% if (num_out < numColumn/2)
%     % 替换第一次检测出的目标
%     for ii=1:num_out
%         data_in( detIdxAlongRange(ii)) = noise_floor_aver(ii);
%     end
%     % 二次检测
%     for ii=1:numColumn %Ranges
%         s=data_in(ii);
%         if ii>=1 && ii<=RangeCFARparameters.numGaurdCell+RangeCFARparameters.numNoiseCell
%             noiseRightIdx = (ii+RangeCFARparameters.numGaurdCell+1:ii+RangeCFARparameters.numGaurdCell+RangeCFARparameters.numNoiseCell);
%             noiseRight = mean(data_in(noiseRightIdx));
%             noise=noiseRight;
%         elseif ii>numColumn-RangeCFARparameters.numGaurdCell-RangeCFARparameters.numNoiseCell && ii<=numColumn
%             noiseLeftIdx = (ii-RangeCFARparameters.numGaurdCell-RangeCFARparameters.numNoiseCell:ii-RangeCFARparameters.numGaurdCell-1);
%             noiseLeft = mean(data_in(noiseLeftIdx));
%             noise=noiseLeft;
%         else
%             noiseLeftIdx = (ii-RangeCFARparameters.numGaurdCell-RangeCFARparameters.numNoiseCell:ii-RangeCFARparameters.numGaurdCell-1);
%             noiseLeftIdx(noiseLeftIdx<=0) = noiseLeftIdx(noiseLeftIdx<=0)+numColumn;
%             noiseLeft = mean(data_in(noiseLeftIdx));
%             noiseRightIdx = (ii+RangeCFARparameters.numGaurdCell+1:ii+RangeCFARparameters.numGaurdCell+RangeCFARparameters.numNoiseCell);
%             noiseRightIdx(noiseRightIdx>numColumn) = noiseRightIdx(noiseRightIdx>numColumn)-numColumn;
%             noiseRight = mean(data_in(noiseRightIdx));
%             noise=min(noiseLeft,noiseRight);
%         end
%         SNR=s-noise;
%         if SNR>RangeCFARparameters.threshold
%             num_out=num_out+1;
%             detIdxAlongRange(num_out)=ii;
%             detSNR(num_out)=SNR;
%         end
%     end
% end
detIdxAlongRange = detIdxAlongRange(1:num_out);
% detSNR = detSNR(1:num_out);
end


