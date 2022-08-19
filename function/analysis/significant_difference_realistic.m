% 選考尺度値の有意差の有無をブートストラップサンプルをもとに検定する 実験3用
% Holm法で有意水準を補正

% Input
%   BS_sample : psvのブートストラップサンプル, (10000*比較色相数*照明*粗さ)
%   num_sti : 比較する刺激条件の数

function [p, sig_diff] = significant_difference_realistic(BS_sample,num_sti,flag_par)
    B = 10000; %ブートストラップサンプル数
    
    object = object_paramater(flag_par);
    color_pair = nchoosek(1:num_sti,2);
    
    % 結果記録用のマトリクス
    p = zeros(size(color_pair,1), 1, object.light_num, object.rough_num);
    sig_diff = p;
    
    for j = 1:object.light_num % 照明
        for k = 1:object.rough_num % 粗さ
            
            for n = 1:size(color_pair,1)
                sample_diff = BS_sample(:,color_pair(n,1),j,k) - BS_sample(:,color_pair(n,2),j,k);
                sdata = sort(sample_diff);
                
                % p値
                num = min([nnz(sdata<=0), nnz(sdata>=0)]);
                p(n,1,j,k) = num/B;
            end
            clear n;
            
            % Holm法で有意水準を補正して検定
            [p_sort, id_sort] = sort(p(:,:,j,k));
            for n = 1:size(color_pair,1)
                alpha_holm = 0.025/(size(color_pair,1)+1-n);
                
                if p_sort(n) < alpha_holm
                    sig_diff(id_sort(n),:,j,k) = 1;
                else
                    sig_diff(id_sort(n),:,j,k) = 0;
                    break;
                end
            end
            
        end
    end
        
end
