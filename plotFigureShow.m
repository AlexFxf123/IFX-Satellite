function [h1,h4,plotHandles] = plotFigureShow(objList,frameID,chirpClassify,imgVideo,paramsConfig,plotHandles)%imgVideo,
%     [idxMove,~] = find(abs(objList(:,5)) >= 1); %rangeIdx,speedIdx,横坐标，纵坐标，高度，speed,range,azimuth
    if nargin < 6 || isempty(plotHandles)
        plotHandles = struct('fig',[], 'axPoint',[], 'axImg',[], 'moveHandle',[], 'staticHandle',[], 'imgHandle',[]);
    end

    if isempty(plotHandles.fig) || ~isgraphics(plotHandles.fig,'figure') || ~isgraphics(plotHandles.axPoint,'axes') || ~isgraphics(plotHandles.axImg,'axes')
        plotHandles.fig = figure(6);
        set(plotHandles.fig,'Color',[0.93 0.93 0.97]);
        plotHandles.axPoint = subplot(1,6,[5,6]);
        plotHandles.axImg = subplot(1,6,[1,2,3,4]);
        plotHandles.moveHandle = scatter(plotHandles.axPoint, 0, 0, 6, [0,1,0], 'filled');
        plotHandles.staticHandle = scatter(plotHandles.axPoint, 0, 0, 6, [0,1,0], 'filled');
        imgDisplay = undistortCameraFrame(imgVideo);
        plotHandles.imgHandle = imshow(imgDisplay, 'Parent', plotHandles.axImg);
    else
        figure(plotHandles.fig);
    end

    if ~isgraphics(plotHandles.moveHandle,'scatter') || ~isgraphics(plotHandles.staticHandle,'scatter') || ~isgraphics(plotHandles.imgHandle,'image')
        if isgraphics(plotHandles.axPoint,'axes')
            plotHandles.moveHandle = scatter(plotHandles.axPoint, 0, 0, 6, [0,1,0], 'filled');
            plotHandles.staticHandle = scatter(plotHandles.axPoint, 0, 0, 6, [0,1,0], 'filled');
        end
        if isgraphics(plotHandles.axImg,'axes')
            imgDisplay = undistortCameraFrame(imgVideo);
            plotHandles.imgHandle = imshow(imgDisplay, 'Parent', plotHandles.axImg);
        end
    end

    % 仅保留 XY 平面点云，并按高度映射颜色：高度 5m~ -5m 范围内显示，超出该范围直接过滤
    xAll = objList(:,3);
    yAll = objList(:,4);
    zAll = objList(:,5);

    validMask = (zAll >= -5) & (zAll <= 5);
    xAll = xAll(validMask);
    yAll = yAll(validMask);
    zAll = zAll(validMask);

    if isempty(xAll)
        xAll = 0; yAll = 0; zAll = 0; validMask = false;
    end

    if ~isempty(zAll) && any(validMask)
        zMin = -5;
        zMax = 5;
        nBins = 11;
        zClamped = min(max(zAll, zMin), zMax);
        zNorm = (zClamped - zMin) / (zMax - zMin);
        binIndex = min(max(floor(zNorm * nBins) + 1, 1), nBins);

        % 11 级颜色表：紫 -> 红
        colorTable = [
            0.35, 0.00, 0.85;
            0.45, 0.05, 0.85;
            0.55, 0.15, 0.80;
            0.45, 0.35, 0.75;
            0.25, 0.55, 0.80;
            0.15, 0.75, 0.75;
            0.10, 0.88, 0.50;
            0.40, 0.90, 0.25;
            0.75, 0.82, 0.18;
            0.95, 0.48, 0.15;
            1.00, 0.00, 0.00];

        colorMap = colorTable(binIndex, :);
    else
        colorMap = [0,1,0];
    end

    if isgraphics(plotHandles.moveHandle,'scatter')
        set(plotHandles.moveHandle,'XData',xAll,'YData',yAll,'CData',colorMap);
    end
    if isgraphics(plotHandles.staticHandle,'scatter')
        set(plotHandles.staticHandle,'XData',xAll,'YData',yAll,'CData',colorMap);
    end

    if chirpClassify == 0.2
        xlim(plotHandles.axPoint, [-10 10]); ylim(plotHandles.axPoint, [0 60]);
    elseif chirpClassify == 1
        xlim(plotHandles.axPoint, [-15 15]); ylim(plotHandles.axPoint, [0 150]);
    else
        xlim(plotHandles.axPoint, [-25 25]); ylim(plotHandles.axPoint, [0 150]);
    end

    xlabel(plotHandles.axPoint, '横坐标(m)');
    ylabel(plotHandles.axPoint, '纵坐标(m)');
    grid(plotHandles.axPoint, 'on');
    box(plotHandles.axPoint, 'on');
    set(plotHandles.axPoint,'Color',[0 0.3 0.6]);
    title(plotHandles.axPoint, sprintf('帧数: %d',frameID));

    imgDisplay = undistortCameraFrame(imgVideo);
    if isgraphics(plotHandles.imgHandle,'image')
        set(plotHandles.imgHandle,'CData',imgDisplay);
    else
        plotHandles.imgHandle = imshow(imgDisplay, 'Parent', plotHandles.axImg);
    end
    title(plotHandles.axImg,'视频播放');

    h1 = plotHandles.axPoint;
    h4 = plotHandles.axImg;
    drawnow limitrate;

end

function imgUndist = undistortCameraFrame(img)
    p9Path = fullfile(fileparts(mfilename('fullpath')), 'p9.txt');
    imgUndist = img;
    if ~exist(p9Path,'file')
        return;
    end

    try
        params = parseP9Calibration(p9Path);
        K = [params.fx 0 params.cx;
             0 params.fy params.cy;
             0 0 1];
        cameraParams = cameraParameters('IntrinsicMatrix', K, ...
            'RadialDistortion', [params.k1 params.k2 params.k3], ...
            'TangentialDistortion', [params.p1 params.p2], ...
            'ImageSize', [params.imageHeight params.imageWidth]);
        imgUndist = undistortImage(img, cameraParams);
    catch
        imgUndist = img;
    end
end

function params = parseP9Calibration(filePath)
    fid = fopen(filePath, 'r');
    if fid == -1
        error('p9.txt not found');
    end
    cleanup = onCleanup(@() fclose(fid));
    params = struct('imageWidth',3840,'imageHeight',2160,'fx',1909.8956460710,'fy',1909.3369972662, ...
        'cx',1922.8073212009,'cy',1084.4421887270,'k1',23.1846139002,'k2',13.9531484754, ...
        'p1',0.0002145402,'p2',0.0000006458,'k3',0.7535716687);
    while ~feof(fid)
        line = fgetl(fid);
        if isempty(line) || ~ischar(line)
            continue;
        end
        if contains(line, 'imageWidth')
            params.imageWidth = sscanf(line, 'imageWidth= %f');
        elseif contains(line, 'imageHeight')
            params.imageHeight = sscanf(line, 'imageHeight= %f');
        elseif contains(line, 'fx')
            params.fx = sscanf(line, 'fx= %f');
        elseif contains(line, 'fy')
            params.fy = sscanf(line, 'fy= %f');
        elseif contains(line, 'cx')
            params.cx = sscanf(line, 'cx= %f');
        elseif contains(line, 'cy')
            params.cy = sscanf(line, 'cy= %f');
        elseif contains(line, 'k1')
            params.k1 = sscanf(line, 'k1= %f');
        elseif contains(line, 'k2')
            params.k2 = sscanf(line, 'k2= %f');
        elseif contains(line, 'p1')
            params.p1 = sscanf(line, 'p1= %f');
        elseif contains(line, 'p2')
            params.p2 = sscanf(line, 'p2= %f');
        elseif contains(line, 'k3')
            params.k3 = sscanf(line, 'k3= %f');
        end
    end
end

