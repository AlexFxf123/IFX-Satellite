function [adcOutFrame,imgVideo] = ADCDataPrepro(fileNameA,fileNameB,fileNameI,filePathData0,filePathData1,filePathImg,paramsConfig)%imgVideo

filePathA = strcat(filePathData0, fileNameA);
filePathB = strcat(filePathData1, fileNameB);
filePathI = strcat(filePathImg, fileNameI);
fpA = fopen(filePathA,'rb');
fpB = fopen(filePathB,'rb');
rawDataA = fread(fpA, 'int16', 'l');
rawDataB = fread(fpB, 'int16', 'l');
imgVideo = imread(filePathI);

fclose(fpA);
fclose(fpB);

data_reshapleA = reshape(rawDataA,paramsConfig.numRXChannelPerDevice,paramsConfig.ADCsamples_Per_Chirp,paramsConfig.numChirps); %[4,512,384]
data_reshapleB = reshape(rawDataB,paramsConfig.numRXChannelPerDevice,paramsConfig.ADCsamples_Per_Chirp,paramsConfig.numChirps); %[4,512,384]

adcOutFrameA = permute(data_reshapleA, [2 3 1]);% [sample, chirp, rx_num] 512*384*4
adcOutFrameB = permute(data_reshapleB, [2 3 1]);% [sample, chirp, rx_num] 512*384*4

adcOutFrame = cat(3,adcOutFrameA,adcOutFrameB);% [sample, chirp, rx_num] 512*384*8

%% plot ADC data
%     for n = 1:8
%         figure
%         for i = 1:paramsConfig.numChirps
%             plot(adcOutFrame(:,i,n));hold on;grid on;
%         end
%         title(['第',num2str(n),'通道ADC数据']);
%     end
end