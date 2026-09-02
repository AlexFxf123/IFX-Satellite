function [adcOutFrame,imgVideo] = ADCDataPrepro(fileNameA,fileNameB,fileNameI,filePathData0,filePathData1,filePathImg,paramsConfig)%imgVideo

filePathA = fullfile(filePathData0, fileNameA);
filePathB = fullfile(filePathData1, fileNameB);
filePathI = fullfile(filePathImg, fileNameI);

if ~exist(filePathA,'file')
    error('ADCDataPrepro:MissingFileA', 'Raw file A not found: %s', filePathA);
end
if ~exist(filePathB,'file')
    error('ADCDataPrepro:MissingFileB', 'Raw file B not found: %s', filePathB);
end
if ~exist(filePathI,'file')
    error('ADCDataPrepro:MissingImage', 'Image file not found: %s', filePathI);
end

fpA = fopen(filePathA,'rb');
fpB = fopen(filePathB,'rb');
if fpA == -1 || fpB == -1
    error('ADCDataPrepro:OpenFailed', 'Failed to open raw data files: %s or %s', filePathA, filePathB);
end

rawDataA = fread(fpA, inf, 'int16', 0, 'l');
rawDataB = fread(fpB, inf, 'int16', 0, 'l');
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