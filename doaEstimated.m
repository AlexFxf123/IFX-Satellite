function objList_doa = doaEstimated(objList_decode,rxChannelAll,comp_val_0,paramsConfig,signDML)

%% FFT测角
ant_pos_azi = paramsConfig.virtualPosAzi;
ant_pos_ele = paramsConfig.virtualPosEle;
azi_idx = paramsConfig.aziIdx;
ele_idx = paramsConfig.eleIdx;
ant_azi_idx = 1:length(ant_pos_azi);
ant_ele_idx = 1:length(ant_pos_ele);
d_azi = paramsConfig.spaceX;
d_ele = paramsConfig.spaceY;
% TxOrder = paramsConfig.TxOrder;
% RxOrder = paramsConfig.RxOrder;
% Tx_num = paramsConfig.numTX;
% Rx_num = paramsConfig.numRXchannels;
objNum = length(objList_decode(:,1)); % range
objList_doa = zeros(objNum,4);

for m = 1:objNum

    rxVirtualChannelData = rxChannelAll(m,:);
    data_comp = rxVirtualChannelData.*comp_val_0; % 校准补偿
    %     data_test_comp_win = data_test_comp.*hamming(length(data_test_comp)).';

    %% 数据排序
%     data_order_all = zeros(1,Tx_num*Rx_num);
%     for i = 1:length(TxOrder)
%         idx_tx = TxOrder(i);
%         data_order_tmp = data_comp((idx_tx - 1)*Tx_num + 1 : idx_tx*Tx_num);
%         data_order_all((i - 1)*Tx_num + 1 : i*Tx_num) = data_order_tmp(RxOrder);
%     end
    data_azi_comp = data_comp(azi_idx);
    data_ele_comp = data_comp(ele_idx);

    [aziorig,aziorig1,aziorig2,MagSqr1_dBorig] = func_calAz(data_azi_comp,ant_pos_azi+1,ant_azi_idx,d_azi,paramsConfig);
    [eleComp,eleComp1,eleComp2,MagSqr1_dBComp1] = func_calAz(data_ele_comp,ant_pos_ele,ant_ele_idx,d_ele,paramsConfig);

    objList_doa(m,1) = objList_decode(m,1);   % range
    objList_doa(m,2) = objList_decode(m,2);   % doppler
    objList_doa(m,3) = aziorig;               % azimuth
    objList_doa(m,13) = objList_decode(m,3);  % SNR

    %% DBF测角
    x_azi_DBF = ant_pos_azi.';
    x_ele_DBF = (ant_pos_ele - ant_pos_ele(1)).';
    theta_DBF = -60:0.1:60;                     % 方位角度范围（度）
    phi_DBF = -15:0.1:15;                       % 俯仰角度范围（度）
    W_azi = exp(-1i*2 * pi * x_azi_DBF .* sind(theta_DBF) * 0.55);
    W_ele = exp(-1i*2 * pi * x_ele_DBF .* sind(phi_DBF) * 0.75);

    array_azi_DBF_comp = abs(data_azi_comp * W_azi);
    array_ele_DBF_comp = abs(data_ele_comp * W_ele);

    [peak_dbf_comp,idx_dbf_comp] = max(array_azi_DBF_comp);
    azi_DBF_comp = theta_DBF(idx_dbf_comp);

    [peak_dbf_comp1,idx_dbf_comp1] = max(array_ele_DBF_comp);
    ele_DBF_comp = phi_DBF(idx_dbf_comp1);

    if (abs(ele_DBF_comp - eleComp) < 2)        % 存储俯仰角度
        objList_doa(m,4) = ele_DBF_comp;        % 俯仰峰值角度
    else
        objList_doa(m,4) = 0;
    end

    % 归一化方向图
    array_azi_DBF_comp = 20*log10(array_azi_DBF_comp / peak_dbf_comp);
    array_ele_DBF_comp = 20*log10(array_ele_DBF_comp / peak_dbf_comp1);

    % 0.1度测角增2点方案（方位）
    if paramsConfig.doaPointIncresed01 == 1
        % 方位
        if (idx_dbf_comp > 1)
            interpOffset = QuadraticInterp(array_azi_DBF_comp, idx_dbf_comp - 1);
            azi_DBF_comp1 = theta_DBF(idx_dbf_comp - 1); % 方位左边角度
            azi_DBF_comp1 = azi_DBF_comp1 + interpOffset * 0.1;
        else
            azi_DBF_comp1 = theta_DBF(idx_dbf_comp); % 方位左边角度
        end
        if (idx_dbf_comp < length(theta_DBF))
            interpOffset = QuadraticInterp(array_azi_DBF_comp, idx_dbf_comp + 1);
            azi_DBF_comp2 = theta_DBF(idx_dbf_comp + 1); % 方位右边角度
            azi_DBF_comp2 = azi_DBF_comp2 + interpOffset * 0.1;
        else
            azi_DBF_comp2 = theta_DBF(idx_dbf_comp); % 方位右边角度
        end

        if (abs(azi_DBF_comp - aziorig) < 1)
            objList_doa(m,3) = azi_DBF_comp;        % 方位峰值角度
            objList_doa(m,4) = azi_DBF_comp1;       % 方位峰值左边角度
            objList_doa(m,5) = azi_DBF_comp2;       % 方位峰值右边角度
        else
            objList_doa(m,3:5) = azi_DBF_comp;
        end

        % 俯仰
        if (idx_dbf_comp1 > 1)
            ele_DBF_comp1 = phi_DBF(idx_dbf_comp1 - 1); % 俯仰左边角度
        else
            ele_DBF_comp1 = phi_DBF(idx_dbf_comp1); % 俯仰左边角度
        end
        if (idx_dbf_comp1 < length(phi_DBF))
            ele_DBF_comp2 = phi_DBF(idx_dbf_comp1 + 1); % 俯仰右边角度
        else
            ele_DBF_comp2 = phi_DBF(idx_dbf_comp1); % 俯仰右边角度
        end

        if (abs(ele_DBF_comp - eleComp) < 2)        % 存储俯仰角度
            objList_doa(m,6) = ele_DBF_comp;        % 俯仰峰值角度
            objList_doa(m,7) = ele_DBF_comp1;       % 俯仰峰值左边角度
            objList_doa(m,8) = ele_DBF_comp2;       % 俯仰峰值右边角度
        else
            objList_doa(m,6:8) = 0;
        end
    end

    % 0.02度测角增4点方案（方位）
    if paramsConfig.doaPointIncresed002 == 1
        % 方位
        if (idx_dbf_comp > 1)
            azi_DBF_comp1 = azi_DBF_comp - 0.02; % 方位左边角度
            azi_DBF_comp2 = azi_DBF_comp - 0.04; % 方位左边角度
        else
            azi_DBF_comp1 = theta_DBF(idx_dbf_comp); % 方位左边角度
            azi_DBF_comp2 = theta_DBF(idx_dbf_comp); % 方位左边角度
        end

        if (idx_dbf_comp < length(theta_DBF))
            azi_DBF_comp3 = azi_DBF_comp + 0.02; % 方位右边角度
            azi_DBF_comp4 = azi_DBF_comp + 0.04; % 方位右边角度
        else
            azi_DBF_comp3 = theta_DBF(idx_dbf_comp); % 方位右边角度
            azi_DBF_comp4 = theta_DBF(idx_dbf_comp); % 方位右边角度
        end

        % 俯仰
        if (idx_dbf_comp1 > 1)
            ele_DBF_comp1 = phi_DBF(idx_dbf_comp1 - 1); % 俯仰左边角度
            ele_DBF_comp2 = phi_DBF(idx_dbf_comp1 - 1); % 俯仰左边角度
        else
            ele_DBF_comp1 = phi_DBF(idx_dbf_comp1); % 俯仰左边角度
            ele_DBF_comp2 = phi_DBF(idx_dbf_comp1); % 俯仰左边角度
        end
        if (idx_dbf_comp1 < length(phi_DBF))
            ele_DBF_comp3 = phi_DBF(idx_dbf_comp1 + 1); % 俯仰右边角度
            ele_DBF_comp4 = phi_DBF(idx_dbf_comp1 + 1); % 俯仰右边角度
        else
            ele_DBF_comp3 = phi_DBF(idx_dbf_comp1); % 俯仰右边角度
            ele_DBF_comp4 = phi_DBF(idx_dbf_comp1); % 俯仰右边角度
        end

        if (abs(azi_DBF_comp - aziorig) < 1)
            objList_doa(m,3) = azi_DBF_comp;        % 方位峰值角度
            objList_doa(m,4) = azi_DBF_comp1;       % 方位峰值左边角度
            objList_doa(m,5) = azi_DBF_comp2;       % 方位峰值右边角度
            objList_doa(m,6) = azi_DBF_comp3;       % 方位峰值左边角度
            objList_doa(m,7) = azi_DBF_comp4;       % 方位峰值右边角度
        else
            objList_doa(m,3:7) = azi_DBF_comp;
        end

        if (abs(ele_DBF_comp - eleComp) < 2)        % 存储俯仰角度
            objList_doa(m,8) = ele_DBF_comp;        % 俯仰峰值角度
            objList_doa(m,9) = ele_DBF_comp1;       % 俯仰峰值左边角度
            objList_doa(m,10) = ele_DBF_comp2;      % 俯仰峰值右边角度
            objList_doa(m,11) = ele_DBF_comp3;      % 俯仰峰值左边角度
            objList_doa(m,12) = ele_DBF_comp4;      % 俯仰峰值右边角度
        else
            objList_doa(m,8:12) = 0;
        end
    end

    % 绘制方向图

%     figure;
%     plot(theta_DBF, array_azi_DBF_comp);hold on; grid on;
%     xlabel('角度 (度)');
%     ylabel('增益 (dB)');
%     title(['方位DBF方向图 azi = ', num2str(azi_DBF_comp),'°']);
%     xlim([-90 90]);
%     ylim([-40 0]);
% 
%     figure;
%     plot(phi_DBF, array_ele_DBF_comp);hold on; grid on;
%     xlabel('角度 (度)');
%     ylabel('增益 (dB)');
%     title(['俯仰DBF方向图 ele = ', num2str(ele_DBF_comp),'°']);
%     xlim([-90 90]);
%     ylim([-40 0]);

    %% 二维DBF测角
%     X = paramsConfig.virtualPosX.';
%     Y = paramsConfig.virtualPosY.';
% 
%     data_test_comp_DBF = rxVirtualChannelData.* comp_val_0;
% 
%     dtheta = 1;
%     dphi = 1;                                                       % 扫描角度间隔
%     max_fov_azi = paramsConfig.maxFovAzi;
%     max_fov_ele = paramsConfig.maxFovEle;                           % 方位扫描角度
%     theta_scan = aziorig-max_fov_azi:dtheta:aziorig+max_fov_azi;    % 方位扫描角度,-60~60
%     phi_scan = -max_fov_ele:dphi:max_fov_ele;                       % 俯仰扫描角度,-15~15
%     theta_len = length(theta_scan);
%     phi_len = length(phi_scan);
%     beam = zeros(theta_len, phi_len);                               % 初始化波束
%     for i = 1:1:theta_len
%         for j = 1:1:phi_len
%             theta = theta_scan(i);
%             phi = phi_scan(j);
%             Fx = exp(-1i * X * paramsConfig.spaceX * 2 * pi * sind(theta) * cosd(phi));
%             Fy = exp(-1i * Y * paramsConfig.spaceY * 2 * pi * sind(phi));
%             Fxy = Fx.*Fy;
%             beam(i,j) = abs(data_test_comp_DBF * Fxy);
%         end
%     end
%     beam_comp_db = 20*log10(beam/max(max(beam)));
% %     beam_comp_db = 20*log10(beam);
% %     number = find(beam_comp_db<-50);
% %     g_temp = -50+unifrnd(-1,1,1,length(number));
% %     for ii = 1:length(number)
% %         beam_comp_db(number(ii)) = g_temp(ii);
% %     end
% 
%     [theta_comp_i,phi_comp_j] = find(beam_comp_db == max(max(beam_comp_db)));
%     theta_comp = theta_scan(theta_comp_i);  % 方位角
%     phi_comp = phi_scan(phi_comp_j);        % 俯仰角
% 
%     interpOffset_theta = 0;%QuadraticInterp(beam_comp_db(:,phi_comp_j), theta_comp_i);
%     interpOffset_phi = 0;%QuadraticInterp(beam_comp_db(theta_comp_i,:), phi_comp_j);
% 
% %     theta_comp_2DDBF = aziorig - max_fov_azi + (theta_comp_i - 1 + interpOffset_theta) * dtheta;
% %     phi_comp_2DDBF = -max_fov_ele + (phi_comp_j - 1 + interpOffset_phi) * dtheta;
%     theta_comp_2DDBF1 = theta_comp + interpOffset_theta * dtheta;
%     phi_comp_2DDBF1 = phi_comp + interpOffset_phi * dphi;
% 
%     if (abs(theta_comp_2DDBF1 - aziorig) < 1)
%         objList_doa(m,4) = phi_comp_2DDBF1;               % elevation
%     else
%         objList_doa(m,4) = 0;
%     end

%     figure;
%     mesh(phi_scan, theta_scan, beam_comp_db);
%     title('二维阵列方向图校准后');
%     xlabel('俯仰角');ylabel('方位角');zlabel('幅度(dB)');
%     % axis([-100 100 -100 100 -80 10]);
%     
%     figure;
%     plot(phi_scan,beam_comp_db(round(1+ (theta_comp + max_fov_azi)/dtheta), :));     % 对应方位角度切面（取俯仰的0°或者相应方位角作切面）
%     % plot(theta_scan,beam_comp_db(round(1+(phi_comp_twoLayers-(realAzi-max_fov_azi))/dtheta), :));     % 对应方位角度切面（取俯仰的0°或者相应方位角作切面）
%     xlabel('俯仰角/度');ylabel('幅度/dB');
%     grid on;hold on;
%     plot([phi_comp,phi_comp],ylim,'m-.');
%     title(['俯仰面方向图校准后 ','ele = ',num2str(phi_comp)]);
%     % axis([-100 100 -80 0]);
%     
%     figure;
%     plot(theta_scan,beam_comp_db(:, round(1+(phi_comp+max_fov_ele)/dphi)));       % 对应俯仰角度切面（原理同上）
%     xlabel('方位角/度');ylabel('幅度/dB');
%     grid on;hold on;
%     plot([theta_comp,theta_comp],ylim,'m-.');
%     title(['方位面方向图校准后 ','azi = ',num2str(theta_comp)]);
%     % axis([-100 100 -80 0]);

    %% DML测角
    if signDML == 1
        ant_pos_x_DML = (paramsConfig.virtualPosX + 1).';
        ant_pos_y_DML = (paramsConfig.virtualPosY - paramsConfig.virtualPosY(1) + 1).';

        data_test_comp_DML = rxVirtualChannelData.* comp_val_0;

        theta_grid = -60:0.2:60;
        phi_grid = -15:0.2:12;

        [phi_est, theta_est, P_DML] = DML_URA_2D(data_test_comp_DML.', ant_pos_x_DML, ant_pos_y_DML, theta_grid, phi_grid, paramsConfig.spaceX, paramsConfig.spaceY);
        % 输出时方位俯仰已对应纠正
        disp(['Estimated: Azimuth=', num2str(theta_est), '°, Elevation=', num2str(phi_est), '°']);

        % figure
        % mesh(P_DML);
    end
end
end

% fft测角函数
function [azi,azi1,azi2,MagSqr1_dB] = func_calAz(x,ant_pos_azi,azi_idx,d,paramsConfig)
azi = 0;
ele = 0;
N_fft = paramsConfig.numFFTDoA;
snap128 = N_fft;
theta_FFT128 = asind(1/d*((0:snap128-1)-floor(snap128/2))/snap128);
s = zeros(max(ant_pos_azi(azi_idx)),1);     % matlab是从1开始计数的
s(ant_pos_azi(azi_idx)) = x(azi_idx);       % 将64个通道的幅相值对应到相应的天线位置才能进行真实角度估计
s_fft_abs = abs(fft(s,N_fft));
[peak_max,idx_max] = max(s_fft_abs);
% interpOffset = QuadraticInterp(s_fft_abs, idx_max);
idx = idx_max;% - 1 + interpOffset;

if idx <= N_fft/2
    idx = idx + N_fft/2;
else
    idx = idx - N_fft/2;
end

azi = theta_FFT128(idx);

% 峰值左边角度
if (idx_max > 1)
    idx1 = idx_max - 1;% - 1 + interpOffset;
else
    idx1 = idx_max;
end
if idx1 <= N_fft/2
    idx1 = idx1 + N_fft/2;
else
    idx1 = idx1 - N_fft/2;
end
azi1 = theta_FFT128(idx1);

% 峰值右边角度
if (idx_max < length(theta_FFT128))
    idx2 = idx_max + 1;% - 1 + interpOffset;
else
    idx2 = idx_max;
end
if idx2 <= N_fft/2
    idx2 = idx2 + N_fft/2;
else
    idx2 = idx2 - N_fft/2;
end
azi2 = theta_FFT128(idx2);

MagSqr0_dB = 20*log10(s_fft_abs);
MagSqr1_dB = 20*log10(abs(fftshift(s_fft_abs/peak_max)));

% figure;plot(theta_FFT128,MagSqr1_dB);title(['idx\_max = ',num2str(idx_max),'  azi = ',num2str(azi)]);grid on;

end

% DML测角函数
function [phi_est, theta_est, P_DML] = DML_URA_2D(data, X, Y, theta_grid, phi_grid, spacing_azi, spacing_ele)

    [P, T] = size(data);
    R_hat = (1/P) * (data * data');                         % 样本协方差矩阵
    P_DML = zeros(length(theta_grid), length(phi_grid));

    % 遍历角度网格
    for i = 1:length(theta_grid)
        for j = 1:length(phi_grid)
            theta = theta_grid(i);
            phi = phi_grid(j);
            Fx = exp(-1i*X*2*pi*spacing_azi*sind(theta)*cosd(phi));
            Fy = exp(-1i*Y*2*pi*spacing_ele*sind(phi));
            A = Fx.*Fy;
            P_A = A * pinv(A' * A) * A';            % 投影矩阵
            P_DML(i,j) = abs(trace(P_A * R_hat));   % DML代价函数
        end
    end

    % 寻找峰值
    [~, idx] = max(P_DML(:));
    [i, j] = ind2sub(size(P_DML), idx);
    theta_est = -1*theta_grid(i);
    phi_est = -1*phi_grid(j);
end
