%% 刺激の物体部分の輝度・彩度の関係を可視化する

% Input
%   img : XYZ値の画像データ
%   mask : 物体部分を示すマスク
%   lum_range : スケーリング時の輝度範囲
%   sat_range : スケーリング時の彩度範囲
%   wp : 彩度計算時の白色点
%
% Output
%   lum_map : 
%   lum_list : 
%   sat_map : 
%   sat_list : 

function [lum_map, lum_list, sat_map, sat_list] = plot_relation_lum_sat(img, mask, wp, lum_range, sat_range)
    
    arguments
        img = zeros(100,100)
        mask = zeros(100,100)
        wp = whitepoint('d65')
        lum_range = [0, max(img(:,:,2),[],'all')]
        sat_range = [0, 0.0890]
    end

    %% 輝度取得
    [lum_map, lum_list] = get_luminance(img, mask);

    %% 彩度取得
    [sat_map, sat_list] = get_saturation(img, mask, wp);

    %% プロット
    figure;

    % 輝度マップ
    subplot(1,3,1);
    imagesc(lum_map, lum_range);
    colormap jet;
    colorbar;
    title('luminance');

    % 彩度マップ
    subplot(1,3,2);
    imagesc(sat_map, sat_range);
    colormap jet;
    colorbar;
    title('saturation');

    % 輝度-彩度
    subplot(1,3,3);
    scatter(lum_list, sat_list);
    xlim(lum_range);
    ylim(sat_range);
    xlabel('luminance');
    ylabel('saturation');


end