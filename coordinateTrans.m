function objList = coordinateTrans(objList_doa,paramsConfig)

objNum = paramsConfig.numObjList;
numChirps = paramsConfig.numChirps;
R_res = paramsConfig.R_res;
V_res = paramsConfig.V_res;

objList = [];

for k = 1:objNum
    rangeIdx = objList_doa(k,1);
    dopplerIdx = objList_doa(k,2);
%     ramgeInterpOffset = QuadraticInterp(detMatrix_dB(dopplerIdx,:), rangeIdx);
%     dopplerInterpOffset = QuadraticInterp(detMatrix_dB(:,rangeIdx), dopplerIdx);
    ramgeInterpOffset = 0.5;%偶数的中间数一半，例如1-10的中间是5.5
    dopplerInterpOffset = 0.5;

    %% 距离计算
    if paramsConfig.FFTRateFactorRng ~= 1
        range = (rangeIdx - 1 + ramgeInterpOffset) / paramsConfig.FFTRateFactorRng * R_res;     % 未做补偿
    else
        range = (rangeIdx - 1 + ramgeInterpOffset) * R_res;                                     % 未做补偿
    end

    %% 速度计算
    dopplerIdxTemp = dopplerIdx - 1 + dopplerInterpOffset;                                      % 未做补偿

    dopplerIdxTemp = (dopplerIdxTemp - numChirps/2);                                            % 未解模糊

    if paramsConfig.FFTRateFactorDop ~= 1
        speed = dopplerIdxTemp / paramsConfig.FFTRateFactorDop * V_res;                         % 未解模糊
    else
        speed = dopplerIdxTemp * V_res;                                                         % 未解模糊
    end

    %% 角度增点策略
    if (paramsConfig.doaPointIncresed01 == 1)

        % 目标峰值点迹坐标
        x1 = range * sind(objList_doa(k,3));                                                        % 横坐标  俯仰角度不准，暂时不做XY平面的投影
        y1 = range * cosd(objList_doa(k,3));                                                        % 纵坐标  俯仰角度不准，暂时不做XY平面的投影
        z1 = range * sind(objList_doa(k,6));                                                        % 高度
        % 目标峰值左边点迹坐标
        x2 = range * sind(objList_doa(k,4));                                                        % 横坐标  俯仰角度不准，暂时不做XY平面的投影
        y2 = range * cosd(objList_doa(k,4));                                                        % 纵坐标  俯仰角度不准，暂时不做XY平面的投影
        z2 = range * sind(objList_doa(k,7));                                                        % 高度
        % 目标峰值右边点迹坐标
        x3 = range * sind(objList_doa(k,5));                                                        % 横坐标  俯仰角度不准，暂时不做XY平面的投影
        y3 = range * cosd(objList_doa(k,5));                                                        % 纵坐标  俯仰角度不准，暂时不做XY平面的投影
        z3 = range * sind(objList_doa(k,8));                                                        % 高度

        obj1_temp = [objList_doa(k,1), objList_doa(k,2), x1, y1, z1, speed, range, objList_doa(k,3), objList_doa(k,6);
                     objList_doa(k,1), objList_doa(k,2), x2, y2, z2, speed, range, objList_doa(k,4), objList_doa(k,7);
                     objList_doa(k,1), objList_doa(k,2), x3, y3, z3, speed, range, objList_doa(k,5), objList_doa(k,8)];
        objList = cat(1,objList,obj1_temp);
        
    elseif (paramsConfig.doaPointIncresed002 == 1)

        % 目标峰值点迹坐标
        x1 = range * sind(objList_doa(k,3));                                                        % 横坐标  俯仰角度不准，暂时不做XY平面的投影
        y1 = range * cosd(objList_doa(k,3));                                                        % 纵坐标  俯仰角度不准，暂时不做XY平面的投影
        z1 = range * sind(objList_doa(k,8));                                                        % 高度
        % 目标峰值左边点迹坐标
        x2 = range * sind(objList_doa(k,4));                                                        % 横坐标  俯仰角度不准，暂时不做XY平面的投影
        y2 = range * cosd(objList_doa(k,4));                                                        % 纵坐标  俯仰角度不准，暂时不做XY平面的投影
        z2 = range * sind(objList_doa(k,9));                                                        % 高度
        % 目标峰值左边点迹坐标
        x3 = range * sind(objList_doa(k,5));                                                        % 横坐标  俯仰角度不准，暂时不做XY平面的投影
        y3 = range * cosd(objList_doa(k,5));                                                        % 纵坐标  俯仰角度不准，暂时不做XY平面的投影
        z3 = range * sind(objList_doa(k,10));                                                       % 高度
        % 目标峰值右边点迹坐标
        x4 = range * sind(objList_doa(k,6));                                                        % 横坐标  俯仰角度不准，暂时不做XY平面的投影
        y4 = range * cosd(objList_doa(k,6));                                                        % 纵坐标  俯仰角度不准，暂时不做XY平面的投影
        z4 = range * sind(objList_doa(k,11));                                                       % 高度
        % 目标峰值右边点迹坐标
        x5 = range * sind(objList_doa(k,7));                                                        % 横坐标  俯仰角度不准，暂时不做XY平面的投影
        y5 = range * cosd(objList_doa(k,7));                                                        % 纵坐标  俯仰角度不准，暂时不做XY平面的投影
        z5 = range * sind(objList_doa(k,12));                                                       % 高度

        obj1_temp = [objList_doa(k,1), objList_doa(k,2), x1, y1, z1, speed, range, objList_doa(k,3), objList_doa(k,8);
                     objList_doa(k,1), objList_doa(k,2), x2, y2, z2, speed, range, objList_doa(k,4), objList_doa(k,9);
                     objList_doa(k,1), objList_doa(k,2), x3, y3, z3, speed, range, objList_doa(k,5), objList_doa(k,10);
                     objList_doa(k,1), objList_doa(k,2), x4, y4, z4, speed, range, objList_doa(k,6), objList_doa(k,11);
                     objList_doa(k,1), objList_doa(k,2), x5, y5, z5, speed, range, objList_doa(k,7), objList_doa(k,12)];
        objList = cat(1,objList,obj1_temp);
    else
        
        % 目标峰值点迹坐标
        x1 = range * sind(objList_doa(k,3));                                                        % 横坐标  俯仰角度不准，暂时不做XY平面的投影
        y1 = range * cosd(objList_doa(k,3));                                                        % 纵坐标  俯仰角度不准，暂时不做XY平面的投影
        z1 = range * sind(objList_doa(k,4));                                                        % 高度
        obj1_temp = [objList_doa(k,1), objList_doa(k,2), x1, y1, z1, speed, range, objList_doa(k,3), objList_doa(k,4),objList_doa(k,13)];
        objList = cat(1,objList,obj1_temp);
    end

end

end

