close all;clear;clc

%% Path to the Binary file captured from the 2-chip cascade board
baseDir = fileparts(mfilename('fullpath'));
filePathData0 = fullfile(baseDir, 'data', 'BJT_20260827_114500', 'port0_radar_master');
filePathData1 = fullfile(baseDir, 'data', 'BJT_20260827_114500', 'port1_radar_slave');
filePathImg   = fullfile(baseDir, 'data', 'BJT_20260827_114500', 'port9_cam_front_wide');

dirout_dataA = dir(fullfile(filePathData0, '*.raw'));
dirout_dataB = dir(fullfile(filePathData1, '*.raw'));
dirout_dataI = dir(fullfile(filePathImg, '*.jpeg'));
if isempty(dirout_dataI)
    dirout_dataI = dir(fullfile(filePathImg, '*.jpg'));
end
nFrameA = length(dirout_dataA);
nFrameB = length(dirout_dataB);
if nFrameA == nFrameB
    nFrame = nFrameA;
else
    nFrame = 0;
end

chirpClassify = 1;

%% 仿真参数设置
paramsConfig = chirpParamsConfig(chirpClassify);
 
Frame_start = 100;                                                % 开始帧
signDML = 0;                                                    % DML测角开关
plotSign = 0;                                                   % 画图开关
moduleTimeSign = 1;                                             % 各模块耗时统计开关，1=开启，0=关闭
projectionSign = 1;                                             % 点云投影到图像开关，1=开启，0=关闭
plotEveryNFrame = 1;                                            % 图片每帧刷新
plotHandles = struct('fig',[], 'axPoint',[], 'axImg',[], 'moveHandle',[], 'staticHandle',[], 'imgHandle',[]);

for frameID = Frame_start:nFrame
    
    frameID

    fileNameA = dirout_dataA(frameID).name;
    fileNameB = dirout_dataB(frameID).name;
    fileNameI = dirout_dataI(frameID).name;

    %% ADC数据读取
    if moduleTimeSign == 1
        tADC = tic;
    end
    [adcOutFrame,imgVideo] = ADCDataPrepro(fileNameA,fileNameB,fileNameI,filePathData0,filePathData1,filePathImg,paramsConfig);%imgVideo
    if moduleTimeSign == 1
        fprintf('ADCDataPrepro elapsed: %.3f s\n', toc(tADC));
    end

    %% ADC数据基础处理
    if moduleTimeSign == 1
        tProc = tic;
    end
    [rangeDoppler,detMatrix_dB] = ADCDataProcessing(adcOutFrame,paramsConfig);
    if moduleTimeSign == 1
        fprintf('ADCDataProcessing elapsed: %.3f s\n', toc(tProc));
    end
   
    if plotSign == 1
        figure(1); mesh(detMatrix_dB);grid on;
        xlabel('Range-bin');ylabel('Doppler-Bin');zlabel('Magnitude (dB)');
        title('RV detmatrix')
    end

    %% 子带积累检测
    if moduleTimeSign == 1
        tSubBand = tic;
    end
    [detObjlist_subBand,detRangeSNR] = detSubBand(paramsConfig,detMatrix_dB,plotSign,chirpClassify);
    if moduleTimeSign == 1
        fprintf('detSubBand elapsed: %.3f s\n', toc(tSubBand));
    end
    
    if plotSign == 1
        figure(3); mesh(detObjlist_subBand);grid on;%flipud
        title('子带CFAR检测结果');
    end

    %% 解调匹配
    if moduleTimeSign == 1
        tDemod = tic;
    end
    [rxChannelAll,objList_decode,paramsConfig] = DDMADemodulate(rangeDoppler,detMatrix_dB,detObjlist_subBand,detRangeSNR,paramsConfig);
    if moduleTimeSign == 1
        fprintf('DDMADemodulate elapsed: %.3f s\n', toc(tDemod));
    end

    if plotSign == 1
        figure(4);scatter(objList_decode(:,1),objList_decode(:,2));grid on;%flipud
        xlim([0,255]);ylim([0,383]);
        title('匹配解调检测结果');
    end

    %% 测角 FFT/DBF/DML
    if moduleTimeSign == 1
        tDOA = tic;
    end
    load comp_val_yheng_zy_20260731.mat
    objList_doa = doaEstimated(objList_decode,rxChannelAll,comp_val_0,paramsConfig,signDML); % rangeIdx,dopplerIdx,azi(1~3),ele(1~3)
    if moduleTimeSign == 1
        fprintf('doaEstimated elapsed: %.3f s\n', toc(tDOA));
    end
    
    %% 转换坐标
    if moduleTimeSign == 1
        tTrans = tic;
    end
    objList_doa(:,3) = objList_doa(:,3) - 2.4;% 安装位置角度偏离补偿  0.2m -2.8°
    objList_doa(:,4) = objList_doa(:,4) + 2.0;% 安装位置角度偏离补偿
    objList = coordinateTrans(objList_doa,paramsConfig); % 1:rangeIdx，2:speedIdx，3:横坐标1，4:纵坐标1，5:高度1，
    % 6:横坐标2，7:纵坐标2，8:高度2，9:横坐标3，10:纵坐标3，11:高度3，12:speed，13:range，14:azi1，15:azi2，16:azi3，17:ele1，18:ele2，19:ele3，
    objList(:,3) = objList(:,3) - 0.2; % 安装位置横向坐标补偿
    objList(:,4) = objList(:,4) + 2.5; % 安装位置纵向坐标补偿
    objList(:,5) = objList(:,5) - 1.0; % 安装位置高度补偿
    if moduleTimeSign == 1
        fprintf('coordinateTrans elapsed: %.3f s\n', toc(tTrans));
    end

    %% 画图
    if mod(frameID, plotEveryNFrame) == 0 || frameID == Frame_start
        if moduleTimeSign == 1
            tPlot = tic;
        end
        [h1,h4,plotHandles] = plotFigureShow(objList,frameID,chirpClassify,imgVideo,paramsConfig,plotHandles,projectionSign);%imgVideo,
        if moduleTimeSign == 1
            fprintf('plotFigureShow elapsed: %.3f s\n', toc(tPlot));
        end
        length(objList(:,1))
    end

end
