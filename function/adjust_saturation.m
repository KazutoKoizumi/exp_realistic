%% 低輝度側で色域外になっている部分を色域内におさめる

% Input
%   img : XYZの画像データ
%   lum_threshold : 色域調整を行うピクセルの輝度閾値

function img_modified = adjust_saturation(img, lum_threshold)
    
    pass = '/home/koizumi/experiment/';
    spectrum_data = csvread(strcat(pass,'calibration/spectrum_data.csv'));
    rgb_converter = tnt.RgbConverter(spectrum_data);
    
    load(strcat(pass,'exp_realistic/mat/mask/bunny_mask.mat'));

    [iy,ix,iz] = size(img);
    
    img_uvl = tnt.three_channel_convert([], img, @(c,d) XYZTouvY(d));
    img_rgb = rgb_converter.xyz_to_linear_rgb(img);
    
    wp_xyz = whitepoint('d65')';
    wp_uvl = tnt.three_channel_convert([], wp_xyz, @(c,d) XYZTouvY(d));
    
    for i = 1:iy
        for j = 1:ix
            rgb = permute(img_rgb(i,j,:), [3 1 2]);
            
            % 色域内かどうか確認
            if any(rgb < 0 | rgb > 1, 'all')
                % 色域外の場合
                
                % 輝度閾値と比較
                if img_uvl(i,j,3) < lum_threshold
                    % 閾値より輝度が小さい場合、色域内に収まるまで彩度を下げる
                    
                    tmp_uvl = permute(img_uvl(i,j,:), [3 1 2]);
                    
                    % 角度と距離を求める（d65色度座標を白色点とし、これを中心として極座標表現）
                    [theta, rho] = cart2pol(tmp_uvl(1)-wp_uvl(1), tmp_uvl(2)-wp_uvl(2));
                    step = rho / 100; % 更新のステップサイズ
                    
                    % 色域内に入るまで彩度（白色点からの距離）を小さくする
                    while 1
                        rho = rho - step;
                        if rho >= 0
                            [delta_u, delta_v] = pol2cart(theta, rho);
                        else % 彩度が負になった場合、白色点の色度に合わせる
                            new_uvl(1) = wp_uvl(1);
                            new_uvl(2) = wp_uvl(2);
                            break;
                        end
                            
                        new_uvl = [wp_uvl(1)+delta_u, wp_uvl(2)+delta_v, tmp_uvl(3)]';
                        
                        % 更新したuvlをrgbに変換して色域確認
                        new_xyz = tnt.three_channel_convert([], new_uvl, @(c,d) uvYToXYZ(d));
                        new_rgb = rgb_converter.xyz_to_linear_rgb(new_xyz);
                        
                        % 色域内の場合ループ終了
                        if all(new_rgb>=0 & new_rgb<=1, 'all')
                            break;
                        end
                        
                    end
                    
                    % 色度を更新
                    img_uvl(i,j,1) = new_uvl(1);
                    img_uvl(i,j,2) = new_uvl(2);
                    
                else
                    % 輝度閾値より高輝度の場合
                    
                    % オブジェクト領域か判定
                    if logical(mask(i,j))
                        % オブジェクト内部で色域外の場合
                        fprintf('警告：物体内の高輝度領域で色域外の点があります\n\n');
                    else
                        % オブジェクト外で色域外の場合、周囲のピクセルに合わせる
                        if i == 1 && j == 1 % 左上
                            img_uvl(i,j,1) = img_uvl(i+1,j,1);
                            img_uvl(i,j,2) = img_uvl(i+1,j,2);
                        elseif i == iy && j == 1 % 左下
                            img_uvl(i,j,1) = img_uvl(i-1,j,1);
                            img_uvl(i,j,2) = img_uvl(i-1,j,2);
                        else
                            img_uvl(i,j,1) = img_uvl(i-1,j,1);
                            img_uvl(i,j,2) = img_uvl(i-1,j,2);
                        end
                    end
                    
                end
                    

            end
            
        end
    end
    
    img_modified = tnt.three_channel_convert([], img_uvl, @(c,d) uvYToXYZ(d));
    
end