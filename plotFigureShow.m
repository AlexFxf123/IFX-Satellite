function [h1,h4] = plotFigureShow(objList,frameID,chirpClassify,imgVideo,paramsConfig)%imgVideo,
%     [idxMove,~] = find(abs(objList(:,5)) >= 1); %rangeIdx,speedIdx,横坐标，纵坐标，高度，speed,range,azimuth
    objR = (1:length(objList(:,1))).';


    h = figure(6);%('Color', [1, 1, 3]); % 创建时设置背景色
%     set(h,'OuterPosition', get(0,"ScreenSize"));                % 设置图形全屏显

    speedThread = 1.5;

    xPerM = objList((abs(objList(:,6)) > speedThread),3);       % 运动目标
    yPerM = objList((abs(objList(:,6)) > speedThread),4);
    zPerM = objList((abs(objList(:,6)) > speedThread),5);
    xPerS = objList((abs(objList(:,6)) < speedThread),3);       % 静止目标
    yPerS = objList((abs(objList(:,6)) < speedThread),4);
    zPerS = objList((abs(objList(:,6)) < speedThread),5);


    h1 = subplot(1,6,[5,6]);
    if paramsConfig.doaPointIncresed01 ~= 1
        scatter(xPerM,yPerM,6,[0,1,0],'filled'); hold on;
        scatter(xPerS,yPerS,6,[0,1,0],'filled');
    else
        scatter(xPerM,yPerM,5,[0,1,0],'filled'); hold on;
        scatter(xPerS,yPerS,5,[0,1,0],'filled');
    end

    if chirpClassify == 0.2
        xlim([-10 10]); ylim([0 60]);
    elseif chirpClassify == 1
        xlim([-15 15]); ylim([0 270]);
    else
        xlim([-25 25]); ylim([0 260]);
    end

    xlabel('横坐标(m)');
    ylabel('纵坐标(m)');
    grid on;
    box on;
    hold on;
    x = linspace(min(xlim), max(xlim), 100);
    y = linspace(min(ylim), max(ylim), 100);
    plot(x, repmat(min(ylim):diff(ylim)/10:max(ylim), length(x), 1), 'Color',[1,0,0,0.2],'LineStyle','-','LineWidth',1);
    plot(repmat(min(xlim):diff(xlim)/10:max(xlim), length(y), 1)', y, 'Color',[1,0,0,0.2],'LineStyle','-','LineWidth',1);
    hold on;

    set(gca,'Color', [0 0.3 0.6]);

    title(sprintf('帧数: %d',frameID));

    h4 =subplot(1,6,[1,2,3,4]); 
    imshow(imgVideo);
    title('视频播放');
   
    drawnow;
    pause(0.08);

end

