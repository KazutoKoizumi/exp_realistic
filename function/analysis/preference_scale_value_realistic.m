%% 選好尺度値を求める, 実験3
% 金属とプラスチックはそれぞれ別で呼び出す

% Input
%   standings : 実験結果からまとめた勝敗表の構造体
%   num_sti : 組み合わせの刺激の数
%   tnum : 同じペアの比較数（被験者合計）
%
% Output
%   psv : 選好尺度値
%   psv_CI : 選好尺度値と95%信頼区間
%   BS_sample : ブートストラップサンプル

function [psv,psv_CI,BS_sample] = preference_scale_value_realistic(standings,num_sti,num_param,tnum)
    % parameters
    B = 10000; % Repetition number in Bootstrap
    %tnum = 6; % trial number in each stimulus pair in conventional experiment
    
    flag_par = 3;
    object = object_paramater(flag_par);
    
    % result
    psv = zeros(1,num_sti, object.light_num, object.rough_num);
    psv_CI = zeros(num_sti,3, object.light_num, object.rough_num);
    BS_sample = zeros(B,num_sti, object.light_num, object.rough_num);
    
    % choose ML method
    fprintf('What ML method are you using?\n')
    fprintf('   [1] Customized fminsearch in MLDS method\n');
    fprintf('   [2] Normal fminsearch\n');
    fprintf('   [3] fmincon for constrained parameter range (MATLAB only)\n');
    method = input('Please enter 1, 2, or 3 (default: 3):   ');
    
    % make ground truth: psychological sensation magnitude such as 'glossiness'
    GroundTruth = rand(1,num_sti).*6-3; % range of Ground Truth of sensation magnitude
    
    % make stimulus pairs
    num_sti = length(GroundTruth);
    cmbs = zeros((num_sti*(num_sti-1)./2), 2);
    combinum = size(cmbs,1);
    count = 1;
    for a = 1:num_sti-1
        for b = a+1:num_sti
            cmbs(count,1) = a;
            cmbs(count,2) = b;
            count = count + 1;
        end
    end
    
    % show some info
    fprintf('Ground truths of sensation values were created.\n');
    fprintf('   Number of stimuli: %d\n', num_sti);
    fprintf('   Number of stimulus combinations: %d\n\n', combinum);
    if IsOctave, fflush(1); end
    
    WaitSecs(0.2);

    fprintf('Trial number per stimulus pair: %d\n\n\n', tnum);
    fprintf('-> Total trial number: %d\n', tnum.*combinum);
    
    snum = (length(cmbs).*tnum)./floor(num_sti/2); % make the trialnum equal between conventional and swiss-draw experiment
    fprintf('Session number: %d\n', snum);
    if IsOctave, fflush(1); end
    
    %% preparation for different algorithms
    startstring = {'Simulation of conventional paired comparison experiment..\n',...
                   'Simulation of swiss-draw experiment..\n',...
                   'Simulation of random stim-pair experiment..\n',...
                   'Simulation of half swiss-draw and random experiment..\n'};
    algostr = {'Conventional method', 'Swiss-draw', 'Pure-random', 'half swiss-random'};

    % variable to store standard errors of each method
    mean_se = zeros(1,4);

    algo = 1;
    
    sd = 1; % SD of sensation ('1' is the assumption of case V)
    
    %% analysis
    progress = 0;
    
    for j = 1:1 %object.light_num
        for k = 2:2 %object.rough_num
            %fprintf('%d / %d \n\n', i,num_param);
            
            %% experiment result
            mtx = standings.mtx(:,:,j,k);
            out_of_num = standings.out_of_num(:,:,j,k);
            num_greater = standings.num_greater(:,:,j,k);

            %% ここから
            %% step1. Analysis to estimate sensation magnitude
            % Analysis 1: Thurston's case V model based on z-score�itypically the results are slightly distorted�j
            estimated_psv = TNT_FCN_PCanalysis_Thurston(mtx, 0.005);
            estimated_psv = estimated_psv - mean(estimated_psv);

            % Analysis 2: Maximum likelihood method�itypically better with enough trials�j
            InitValues = estimated_psv - estimated_psv(1); % Thurston's estimated value is the initial value. But the leftmost value was set to be 0 to reduce DOF.
            [estimated_psv2,num_greater_v,out_of_num_v] = TNT_FCN_PCanalysis_ML(out_of_num, num_greater, cmbs, InitValues, method);
            estimated_psv2 = estimated_psv2 - mean(estimated_psv2);

            fprintf('....Done!!\n\n\n');    if IsOctave, fflush(1); end
            WaitSecs(0.8);

            %% step2. Bootstrap analysis
            str = ['Bootstrap analysis of ', algostr{algo}, '\n'];
            fprintf(str);
            fprintf('  Bootstrap repetition number: %d\n\n\n', B);
            if IsOctave, fflush(1); end

            % variables to store bootstrap samples
            sv_th = zeros(B, num_sti); % Bootstrap samples for Thurston method.
            sv_ml = zeros(B, num_sti); % Bootstrap samples for ML. -> typically this is better

            pg = 1;
            for b=1:B % makes bootstrap samples (requires a lot of processing time)
            % show progress
            if b/B>pg*0.05
            fprintf('   progress...%2.0f%%\n', pg*0.05*100);if IsOctave, fflush(1); end
            pg = pg+1;
            end

            % Simulation of observer responses 1: from results of Thurston's method (z-score)
            if algo==1 % conventional method
            [mtx_s, out_of_num_s, num_greater_s] = TNT_FCN_ObsResSimulation(estimated_psv, cmbs, tnum, sd);
            else % swiss-draw method, random method, or half of swiss-draw and random method(2,3, or 4)
            [mtx_s, out_of_num_s, num_greater_s] = TNT_FCN_ObsResSimulation_swiss(estimated_psv, cmbs, snum, sd, method, 0, algo-1);
            end

            % Analysis�Fz-score
            sv_th(b,:) = TNT_FCN_PCanalysis_Thurston(mtx_s, 0.005);
            sv_th(b,:) = sv_th(b,:) - mean(sv_th(b,:));

            % Simulation of observer responses 2: from results of ML
            if algo==1 % conventional method
            [mtx_s, ou_of_num_s, num_greater_s] = TNT_FCN_ObsResSimulation(estimated_psv2, cmbs, tnum, sd);
            else % swiss-draw method, random method, or half of swiss-draw and random method(2,3, or 4)
            [mtx_s, ou_of_num_s, num_greater_s] = TNT_FCN_ObsResSimulation_swiss(estimated_psv2, cmbs, snum, sd, method, 0, algo-1);
            end

            % pre-analysis based on Thurston's case V (using z-score)
            prediction = TNT_FCN_PCanalysis_Thurston(mtx_s, 0.005);

            % Analysis: Maximum likelihood
            InitValues = prediction - prediction(1); % from pre-analysis: the leftmost value was set to be 0 to reduce DOF
            [sv_ml(b,:), dummy1, dummy2] = TNT_FCN_PCanalysis_ML(ou_of_num_s, num_greater_s, cmbs, InitValues, method);
            sv_ml(b,:) = sv_ml(b,:) - mean(sv_ml(b,:));
            end

            % simple SE: not used (�����o�C�A�X���l�����ƕs�K�؂�)
            ses_th = std(sv_th); % by Thurston
            ses_ml = std(sv_ml); % by ML
            fprintf('....Done!!\n\n\n');   if IsOctave, fflush(1); end

            % 95% confidence interval based on Bootstrap samples
            ranges95_th = zeros(num_sti, 3); % 95%CI�@by Thurston
            ranges95_ml = zeros(num_sti, 3); % 95%CI�@by ML
            ubi = round(B*97.5/100);
            lbi = round(B*2.5/100);
            mi = round(B./2);
            for s=1:num_sti
                % for Thurston data
                sdata = sort(sv_th(:,s));
                ranges95_th(s,1) = sdata(lbi)-estimated_psv(s); % lower bound
                ranges95_th(s,2) = sdata(ubi)-estimated_psv(s); % upper bound
                ranges95_th(s,3) = estimated_psv(s); % 推定値

                % for ML data
                sdata = sort(sv_ml(:,s));
                ranges95_ml(s,1) = sdata(lbi)-estimated_psv2(s); % lower bound
                ranges95_ml(s,2) = sdata(ubi)-estimated_psv2(s); % upper bound
                ranges95_ml(s,3) = estimated_psv2(s); % 推定値
            end

            % record data
            psv(:,:,j,k) = estimated_psv2;
            psv_CI(:,:,j,k) = ranges95_ml;
            BS_sample(:,:,j,k) = sv_ml; % bootstrap sample

            progress = progress + 1;
            fprintf('analysis progress : %d / %d\n\n', progress, num_param);

            %{
            %% just to compare the experiment procedures: plot the simulation results
            % Comparison of Thurston and ML: estimated sensation values with error bars.
            str = ['Ground truth vs Estimated: ', algostr{algo}];
            figure('Position',[1 1 800 300], 'Name', str);
            subplot(1,2,1); hold on;
            plot(GroundTruth, estimated_sv, 'ok');
            errorbar(GroundTruth, ranges95_th(:,3), -ranges95_th(:,1), ranges95_th(:,2), '.k'); % 68%CI
            plot([-4 4], [-4 4],'--k')
            title('Estimated by Thurston method')
            xlabel('Ground truth');
            ylabel('Estimated sensation value');
            subplot(1,2,2); hold on;
            plot(GroundTruth, estimated_sv2, 'ok');
            errorbar(GroundTruth, ranges95_ml(:,3), -ranges95_ml(:,1), ranges68_ml(:,2), '.k'); % 68%CI
            plot([-4 4], [-4 4],'--k')
            title('Estimated by maximum likelihood method')
            xlabel('Ground truth');
            ylabel('Estimated sensation value');


            % Histograms of bootstrap samples of the minimum sensation value
            [dummy, index] = min(GroundTruth);
            str = ['Histogram of estimated values', algostr{algo}];
            figure('Position',[1 1 800 300], 'Name', str);
            subplot(1,2,1); hold on;
            hist(sv_th(:,index), 20);
            title('Thurston method');

            subplot(1,2,2); hold on;
            hist(sv_ml(:,index), 20);
            title('Maximum likelihood');


            % shows psychometric function in the analysis
            if algo==2
            params = estimated_sv2 - estimated_sv2(1);
            dummy = TNT_FCN_MLDS_negLL(params(2:end), cmbs, NumGreater_v, OutOfNum_v, 1);
            end


            %% save standard errors of each method
            mean_se(algo) = mean(ses_ml);

            fprintf('Mean standard error of each experimental algorithm (analyzed by maximum likelihood method)\n');
            % Histograms of bootstrap samples of the minimum sensation value
            [dummy, index] = min(GroundTruth);
            str = ['Histogram of estimated values', algostr{algo}];
            figure('Position',[1 1 800 300], 'Name', str);
            subplot(1,2,1); hold on;
            hist(sv_th(:,index), 20);
            title('Thurston method');

            subplot(1,2,2); hold on;
            hist(sv_ml(:,index), 20);
            title('Maximum likelihood');fprintf('   conventional method: %f\n', mean_se(1));
            %}
        end
    end
    
end
