% 選考尺度値の有意差の有無をブートストラップサンプルをもとに検定する 実験3用

function [sig_diff,sig_diff_CGeffect] = significant_difference_realistic(BS_sample,num_sti,flag_par)
    B = 10000; %ブートストラップサンプル数
    %alpha = 5/8; % 有意水準 (片側検定)、ボンフェローニ補正
    %bonferroni_alpha = 5/8; % ボンフェローニ補正、無彩色との比較
    ubi = round(B*(100-alpha)/100);
    lbi = round(B*alpha/100);
    
    object = object_paramater(flag_par);
    color_pair = nchoosek(1:num_sti,2);
    idx = make_index(flag_par);
    
    % 結果記録用のテーブル
    varTypes = {'string','string','double','double','string','string','string','int8'};
    varNames = {'shape','light','diffuse','roughness','method','hue1','hue2','significantDifference'};
    sig_diff = table('Size',[object.all_num*(object.hue_num-1),8],'VariableTypes',varTypes,'VariableNames',varNames); % grayとの有意差のみ
    
    CGeffect_BS_sample = zeros(B,object.all_num);
    
    count = 1;
    for i = 1:object.all_num
        p = zeros(8,1);
        for n = 1:num_sti-1 % grayとの有意差のみ
            sampleDiff = BS_sample(:,color_pair(n,1),i) - BS_sample(:,color_pair(n,2),i); % "gray-有彩色"
            
            sdata = sort(sampleDiff);
            upLim = sdata(ubi);
            %lowLim = sdata(lbi);
            
            %{
            % 両側検定
            if upLim*lowLim > 0 % 有意差あり
                sigDiff = 1
            else % 有意差なし
                sigDiff = 0
            end
            %}
            
            % 片側検定
            if upLim < 0 % "gray-有彩色"が0より小さいか
                sigDiff = 1;
            else
                sigDiff = 0;
            end
            
            % ｐ値を求める
            if n <= 8
                num = nnz(sdata>=0);
                p(n) = num/B;
            end
            
            sig_diff(count,:) = {object.shape(idx(i,1)),object.light(idx(i,2)),object.diffuse_v(idx(i,3)),object.rough_v(idx(i,4)),object.method(idx(i,5)),object.hue(color_pair(n,1)),object.hue(color_pair(n,2)),sigDiff};
            count = count + 1;
        end
        
        % 効果量を求める（ブートストラップサンプル10000個分）
        BS_sample_color_mean = mean(BS_sample(:,2:9,i),2);
        CGeffect_BS_sample(:,i) = BS_sample_color_mean - BS_sample(:,1,i);
                    
        fprintf('analysis progress : %d / %d\n\n', i, object.all_num);
    end
    
    % 効果量が有意に正か検定
    CGeffect_BS_sample_mean = mean(CGeffect_BS_sample,2);
    sdata = sort(CGeffect_BS_sample_mean);
    lowLim = sdata(B*5/100);
    if lowLim > 0
        sig_diff_CGeffect = 1;
    else
        sig_diff_CGeffect = 0;
    end
    
end
