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
        scatter3(xPerM,yPerM,zPerM,6,[0,1,0],'filled');hold on;
        scatter3(xPerS,yPerS,zPerS,6,[0,1,0],'filled');
    else
        scatter3(xPerM,yPerM,zPerM,5,[0,1,0],'filled');hold on;
        scatter3(xPerS,yPerS,zPerS,5,[0,1,0],'filled');
    end

    if chirpClassify == 0.2
        axis([-10 10 0 60 -2 2]);
    elseif chirpClassify == 1
        axis([-15 15 0 270 -2 2]);
%         xlim([-25, 25]);                                        % 设置x轴范围
%         ylim([0, 260]);                                         % 设置y轴范围
%         zlim([-10, 10]);
    else
        axis([-35 35 0 305]);
        xlim([-25, 25]);                                        % 设置x轴范围
        ylim([0, 260]);                                         % 设置y轴范围
        zlim([-5, 5]);
    end
    xlabel('横坐标(m)');
    ylabel('纵坐标(m)');
    zlabel('高度(m)');
    hold on;                                                    % 保持当前图形，以便在上面绘制额外的线条
    x = linspace(min(xlim), max(xlim), 100);                    % 在当前xlim范围内生成更多点以增加密度
    y = linspace(min(ylim), max(ylim), 100);                    % 在当前ylim范围内生成更多点以增加密度
    plot(x, repmat(min(ylim):diff(ylim)/10:max(ylim), length(x), 1), 'Color',[1,0,0,0.2],'LineStyle','-','LineWidth',1); % 绘制水平网格线
    plot(repmat(min(xlim):diff(xlim)/10:max(xlim), length(y), 1)', y, 'Color',[1,0,0,0.2],'LineStyle','-','LineWidth',1); % 绘制垂直网格线
    hold on;                                                    % 结束绘图保持状态

    set(gca,'Color', [0 0.3 0.6]);                              % 设置背景为红色

    title(sprintf('帧数: %d',frameID));

    h4 =subplot(1,6,[1,2,3,4]); 
    imshow(imgVideo);
    title('视频播放');
   
    drawnow;
    pause(0.08);

end

