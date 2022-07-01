% 無彩色化を行う

% Input
%   img_color : 元画像, XYZ値
%   mask : 物体部分のマスク画像

% Output
%   img_gray : 物体部分を無彩色にした画像
%   img_gray_back : 背景のみ無彩色にした画像

function img_gray = colorize_achromatic(img_color, mask)
    
    cx2u = makecform('xyz2upvpl');
    cu2x = makecform('upvpl2xyz');
    
    wp_d65_XYZ = whitepoint('d65');
    wp_d65_uvl = applycform(wp_d65_XYZ, cx2u);
    
    %img_color_uvl = applycform(img_color, cx2u);
    img_color_uvl = tnt.three_channel_convert([], img_color, @(c,d) XYZTouvY(d));
    
    img_gray_uvl = img_color_uvl; % 全体無彩色画像
    img_gray_uvl(:,:,1) = wp_d65_uvl(1);
    img_gray_uvl(:,:,2) = wp_d65_uvl(2);
    
    img_gray_object_uvl = img_gray_uvl .* mask; % 物体部分のみの無彩色画像
    img_gray_back_uvl = img_gray_uvl .* ~mask; % 背景部分のみの無彩色画像
    img_color_object_uvl = img_color_uvl .* mask; % 物体部分のみの有彩色画像
    img_color_back_uvl = img_color_uvl .* ~mask; % 背景部分のみの有彩色画像
    
    img_gray = img_gray_object_uvl + img_color_back_uvl;
    
    %img_gray = applycform(img_gray, cu2x);
    img_gray = tnt.three_channel_convert([], img_gray, @(c,d) uvYToXYZ(d));
    
    %img_gray_back = img_gray_back_uvl + img_color_object_uvl;
    %img_gray_back = applycform(img_gray_back, cu2x);
    %img_gray_back = tnt.three_channel_convert([], img_gray_back, @(c,d) uvYToXYZ(d));
    
end