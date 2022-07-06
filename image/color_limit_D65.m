% D65色度がどの輝度まで色域内に含まれるかを確認する

% ディスプレイの最低・最大輝度
pass.calibration = '/home/koizumi/experiment/';
spectrum_data = csvread(strcat(pass.calibration,'calibration/spectrum_data.csv'));
rgb_converter = tnt.RgbConverter(spectrum_data);
xyz_min = rgb_converter.linear_rgb_to_xyz([0,0,0]');
xyz_max = rgb_converter.linear_rgb_to_xyz([1,1,1]');
lum_range = [xyz_min(2), xyz_max(2)];

lum_step = logspace(log10(lum_range(1)), log10(lum_range(2)), 10000);

% D65の色度
d65_xyz = whitepoint('d65')';
d65_uvl = tnt.three_channel_convert([], d65_xyz, @(c,d) XYZTouvY(d));

% 低輝度側の確認
d65_uvl(3) = lum_range(1); % スタートはディスプレイの最低輝度
lum_id = 1;
while 1
    % rgbに変換
    d65_xyz = tnt.three_channel_convert([], d65_uvl, @(c,d) uvYToXYZ(d));
    d65_rgb = rgb_converter.xyz_to_linear_rgb(d65_xyz);
    
    % 色域内の場合ループ終了
    if all(d65_rgb>=0 & d65_rgb<=1, 'all')
        break;
    end
    
    % 色域外の場合、輝度を上げてループ継続
    lum_id = lum_id + 1;
    d65_uvl(3) = lum_step(lum_id);
    
end
display([lum_step(lum_id-1), lum_step(lum_id)])
