% 実験結果から勝敗表を作る関数, 実験3

% Input
%   sn : 被験者名
%   num_compair : 1種の刺激対に対する応答回数
%
% Output
%   mtx : 勝率
%   out_of_num : 対戦数
%   num_greater : 勝数


function standings = make_standings_realistic(sn,num_compair)
    if strcmp(sn,"all")
        sn_list = ["pre_koizumi", "pre_kosone"]; 
    else
        sn_list = string(sn);
    end
    N = size(sn_list,2);
    exp = 'exp_realistic';
    
    flag_par = 3;
    object = object_paramater(flag_par);
    num_pair_all = object.hue_pair + object.hue_metal_pair;
    
    n_tmp = 0;

    for i = 1:2 % material
        if i == 1
            hue = object.hue_pair_list;
            num_sti = numel(hue); % 比較を行う刺激数
            num_comb = object.hue_pair; % 刺激対の組の総数
        elseif i == 2
            hue = object.hue_metal_pair_list;
            num_sti = numel(hue);
            num_comb = object.hue_metal_pair;
        end
        mtx_tmp = zeros(num_sti, num_sti, object.light_num, object.rough_num); % 3:照明数, 4:粗さ数
        out_of_num_tmp = mtx_tmp;
        num_greater_tmp = mtx_tmp;

        for j = 1:1 % light
            for k = 2:2 % roughness

                for p = 1:num_comb
                    n_tmp = n_tmp+1;

                    for s = 1:N % 被験者数
                        load(strcat('../../data/',exp,'/pre/',sn_list(s),'/result.mat'));
                        data = result.data;

                        for repeat_comp = 1:num_compair
                            n = n_tmp + num_pair_all * (repeat_comp-1);

                            hue1 = find(hue == data.hue1(n));
                            hue2 = find(hue == data.hue2(n));
                            win = find(hue == data.win(n));

                            out_of_num_tmp(hue1,hue2,j,k) = out_of_num_tmp(hue1,hue2,j,k) + 1;
                            out_of_num_tmp(hue2,hue1,j,k) = out_of_num_tmp(hue2,hue1,j,k) + 1;
                            if win == hue1
                                num_greater_tmp(win,hue2,j,k) = num_greater_tmp(win,hue2,j,k) + 1;
                            elseif win == hue2
                                num_greater_tmp(win,hue1,j,k) = num_greater_tmp(win,hue1,j,k) + 1;
                            end

                        end
                    end

                end

            end
        end

        mtx_tmp = num_greater_tmp ./ out_of_num_tmp;
        for j = 1:num_sti
            mtx_tmp(j,j) = nan;
        end
        
        %{
        if i == 1
            mtx.plastic = mtx_tmp;
            out_of_num.plastic = out_of_num_tmp;
            num_greater.plastic = num_greater_tmp;
        elseif i == 2
            mtx.metal = mtx_tmp;
            out_of_num.metal = out_of_num_tmp;
            num_greater.metal = num_greater_tmp;
        end
        %}
        
        if i == 1
            mtx_tmp_plastic = mtx_tmp;
            out_of_num_tmp_plastic = out_of_num_tmp;
            num_greater_tmp_plastic = num_greater_tmp;
        elseif i == 2
            mtx_tmp_metal = mtx_tmp;
            out_of_num_tmp_metal = out_of_num_tmp;
            num_greater_tmp_metal = num_greater_tmp;
        end
        
    end
    
    %{
    standings.mtx = mtx;
    standings.out_of_num = out_of_num;
    standings.num_greater = num_greater;
    %}
    
    % マトリックスの大きさがplasticとmetalとで異なるのでcell配列で保存
    % 1:plastic, 2:metal
    standings.mtx = {mtx_tmp_plastic, mtx_tmp_metal};
    standings.out_of_num = {out_of_num_tmp_plastic, out_of_num_tmp_metal};
    standings.num_greater = {num_greater_tmp_plastic, num_greater_tmp_metal};
    
end
            
