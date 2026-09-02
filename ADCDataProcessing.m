function [rangeDoppler,detMatrix_dB] = ADCDataProcessing(adcOutFrame,paramsConfig)

ADCsamples_Per_Chirp = paramsConfig.ADCsamples_Per_Chirp;
numRXchannels = paramsConfig.numRXchannels;
numChirps = paramsConfig.numChirps;
numFFTRange = paramsConfig.numFFTRange;
numFFTDoppler = paramsConfig.numFFTDoppler;

%% cancel DC in range
% meanRangeTemp = mean(adcOutFrame(1:ADCsamples_Per_Chirp/2,:,:),1);  % 滑窗去直流
% for n = 1:numRXchannels
%     meanRange = repmat(meanRangeTemp(1,:,n),ADCsamples_Per_Chirp,1);
%     adcOutFrame(:,:,n) = adcOutFrame(:,:,n) - meanRange;
% end

if (paramsConfig.FFTRateFactorRng ~= 1 || paramsConfig.FFTRateFactorDop ~= 1)
    % 增加点数处理
    range_win = hann(ADCsamples_Per_Chirp);                                 % range窗函数
    doppler_win = hann(numChirps)';                                         % doppler窗函数
    range_win_mat = repmat(range_win,1,numChirps,numRXchannels);
    doppler_win_mat = repmat(doppler_win,numFFTRange,1,numRXchannels);

    rangeProfile = fft(adcOutFrame.*range_win_mat,numFFTRange);
    rangeDoppler = fftshift(fft(rangeProfile.*doppler_win_mat,numFFTDoppler,2),2);     % range * doppler * channel       

    detMatrix_temp = sum(abs(rangeDoppler),3);
    detMatrix = detMatrix_temp(1:numFFTRange/2,:).';               % 取前一半（实数采样）：doppler,range
    detMatrix_dB = 20*log10(abs(detMatrix));

else
    % 原始采样点处理
    range_win = hann(ADCsamples_Per_Chirp);                                 % range窗函数
    doppler_win = hann(numChirps)';                                         % doppler窗函数
    range_win_mat = repmat(range_win,1,numChirps,numRXchannels);
    doppler_win_mat = repmat(doppler_win,ADCsamples_Per_Chirp/2,1,numRXchannels);

    rangeProfile = fft(adcOutFrame.*range_win_mat);
    rangeDoppler = fftshift(fft(rangeProfile(1:ADCsamples_Per_Chirp/2,:,:).*doppler_win_mat,[],2),2);     % range * doppler * channel
%     rangeDoppler = fft(rangeProfile.*doppler_win_mat,[],2);     % range * doppler * channel

    detMatrix_temp = sum((abs(rangeDoppler)),3);                            % 先求abs再求和积累，要比先求和积累再求abs的值要大，再增加，
    % detMatrix_temp = sum((abs(rangeDoppler)).^2,3);                       % 每点求.^2，提高信噪比
    detMatrix = detMatrix_temp.';                                           % 取前一半（实数采样）：doppler,range
    detMatrix_dB = 20*log10(abs(detMatrix));                                % 求和后取平方再进行10log10运算的值，要低于求和后再进行20log10运算的值，求和后求平方再进行20log10运算的值最高（信噪比最大）

end

% 保存BIN文件
% real1 = real(rangeDoppler);
% imag1 = imag(rangeDoppler);
% rangeDoppler1 = zeros(1,256*256*8);
% for ii = 1:256*256*8
%     rangeDoppler1(2*ii-1) = real1(ii);
%     rangeDoppler1(2*ii) = imag1(ii);
% end
% 
% fid = fopen('rangeDoppler1.bin','wb'); %% I want to save array1 in the nazmul.bin file
% fwrite(fid,rangeDoppler1,"uint16");
% status=fclose(fid);

% fid = fopen('detMatrix.bin','wb'); %% I want to save array1 in the nazmul.bin file
% fwrite(fid,detMatrix);
% status=fclose(fid);
end

