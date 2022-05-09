% ラインハルト関数
%
% Input
%   lum : 各ピクセルの輝度値
%   lw : 指定する最高輝度


function f = reinhard(lum, lw)

    f = lum .* (1 + (lum./lw^2)) ./ (1+lum);
    
end

