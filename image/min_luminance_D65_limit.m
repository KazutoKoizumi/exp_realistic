% D65色度が色域内に入る最低輝度を求める

cx2u = makecform('xyz2upvpl');
cu2x = makecform('upvpl2xyz');
wp_d65_XYZ = whitepoint('d65');
wp_d65_uvl = applycform(wp_d65_XYZ, cx2u);

pass.calibration = '/home/koizumi/experiment/';
spectrum_data = csvread(strcat(pass.calibration,'calibration/spectrum_data.csv'));
rgb_converter = tnt.RgbConverter(spectrum_data);
min_xyz = rgb_converter.linear_rgb_to_xyz([0,0,0]');
display_min_luminance = min_xyz(2);

luminance_list = logspace(log10(display_min_luminance), 0, 1000)';

luminance_d65_limit = 0;
for i = 1:numel(luminance_list)
    wp_d65_uvl(3) = luminance_list(i);
    
    wp_xyz = applycform(wp_d65_uvl, cu2x);
    wp_rgb = rgb_converter.xyz_to_linear_rgb(wp_xyz');
    
    % 色域内の場合ループ終了
    if all(wp_rgb>=0 & wp_rgb<=1, 'all')
        luminance_d65_limit = luminance_list(i);
        display(luminance_d65_limit);
        break;
    end
    
end

if i == numel(luminance_list)
    fprintf('D65色度が色域に含まれていません');
end
    
