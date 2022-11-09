%% 色相依存性

% Input 
%   h : hue (degree)

function fh = HK_hue_dependency(h)
    h = deg2rad(h); 
    fh = -0.160*cos(h) + 0.132*cos(2*h) - 0.405*sin(h) + 0.080*sin(2*h) + 0.792;
end