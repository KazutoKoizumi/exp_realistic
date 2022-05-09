% 輝度修正を行う関数
% レンダリング結果の[0,1]に丸め込まれたXYZ値をディスプレイの最大・最低輝度に合わせた三刺激値にする

% Input 
%   img_original : 元画像（Mitsuba2のレンダリング結果）
%   lum_min : 指定する最低輝度（ディスプレイの最低輝度で良いが、多少余裕もたせる）
%   lum_max : 指定する最大輝度（ディスプレイの最大輝度より余裕持たせて少し低めに。トーンマップにより更に下がる）

function img_modified = renderXYZ_to_luminance(img_original, lum_min, lum_max)
    
    cx2u = makecform('xyz2upvpl');
    cu2x = makecform('upvpl2xyz');
    
    % ディスプレイの最低輝度を超えているかも確認するためuvlで輝度操作
    img_uvl = applycform(img_original, cx2u);
    lum = img_uvl(:,:,3);
    
    % トーンマップ(ReinHard)
    lw = max(lum,[],'all') + 0.4;
    lum = reinhard(lum, lw);
    
    % 最大輝度をかけて定義通りのXYZにする
    lum = lum .* lum_max;
    
    % 最低輝度の確認
    lum_min_map = lum > lum_min; % ディスプレイの最低輝度以下の部分を0にしたマップ
    lum_tmp = lum .* lum_min_map; % 0にする
    lum_min_map = ~ lum_min_map; % ディスプレイの最低輝度以下の部分が1のマップ
    lum_min_map = lum_min_map .* lum_min; % 最低輝度を入れる
    lum = lum_tmp + lum_min_map; % 最低輝度以下だった部分を最低輝度に合わせる
    
    img_uvl(:,:,3) = lum;
    img_modified = applycform(img_uvl, cu2x);  

end

