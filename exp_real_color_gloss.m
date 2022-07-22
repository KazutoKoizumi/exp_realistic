% レンダリング結果そのままの色の刺激を使用した光沢感測定実験
clear all;

% 日時、被験者、セッション数の取得
exp_time.date = datetime;
sn = input('Sbuject Name?: ', 's');
session_num = input('Session Number?: '); % セッション番号

% パス
pass.data = strcat('../data/exp_realistic/',sn);
exp_record = sprintf('../data/exp_realistic/%s/record_%s.txt', sn,sn);

% データ保存用のディレクトリ作成
mkdir(pass.data);
mkdir(strcat(pass.data,'/session',num2str(session_num)));

AssertOpenGL;
ListenChar(2);
KbName('UnifyKeyNames');
screenNumber = max(Screen('Screens'));
%InitializeMatlabOpenGL;

try 

%% 初期値設定

% キーボード設定
key.escape = KbName('ESCAPE');
%key.left = KbName('1!');
%key.right = KbName('2@');
key.left = KbName('4');
key.right = KbName('6');

% 白色点
wp.d65_XYZ = whitepoint('D65')';
wp.d65_uvl =  XYZTouvY(wp.d65_XYZ); % uvlと記載のところは基本的にu'v'色度 

% 実験画面の背景色の設定 (D65色度、要確認)
bg.lum = 2;
bg.uvl = [wp.d65_uvl(1), wp.d65_uvl(2), bg.lum]';
bg.XYZ = uvYToXYZ(bg.uvl);
bg.color = round(conv_XYZ2RGB(bg.XYZ));

% 刺激のパラメータ
flag_par = 3; % 模擬実物体実験用
object = object_paramater(flag_par);

% 試行数
trial.num_pair_response = 2; % 1種の刺激対に対する被験者1人あたりの応答数
trial.num_pair = (object.hue_pair + object.hue_metal_pair) * object.light_num * object.rough_num; % 刺激対の総数
trial.all = trial.num_pair * trial.num_pair_response;
trial.session = trial.all / 12; % 1セッションの試行数
trial.trash = 20;

%% 刺激のインデックス(刺激ペア含む)、呈示順、結果保存テーブルの設定
% 刺激のインデックス
idx_stimuli = make_index(flag_par);
idx = zeros(trial.num_pair, 5); % material, light, roughness, hue1, hue2
count = 0;
for i = 1:object.material_num
    for j = 1:object.light_num
        for k = 1:object.rough_num
            if i == 1
                idx(count+1:count+object.hue_pair,1:3) = repmat([i,j,k], object.hue_pair,1);
                idx(count+1:count+object.hue_pair,4:5) = nchoosek(1:object.hue_num*2, 2);
                count = count+object.hue_pair;
            elseif i == 2
                idx(count+1:count+object.hue_metal_pair,1:3) = repmat([i,j,k], object.hue_metal_pair,1);
                idx(count+1:count+object.hue_metal_pair,4:5) = nchoosek(1:object.hue_metal_num*2, 2);
                count = count+object.hue_metal_pair;
            end
        end
    end
end

% 呈示順、全ての結果の保存、セッションごとの結果の保存の設定
varTypes = {'string','string','double','string','string','string','datetime','string'};
varNames = {'material','light','rough','hue1','hue2','win','responseTime','left_or_right'};
if session_num == 1
    % 呈示順、結果保存テーブル、セッションの記録を作る
    result.data = table('Size',[trial.all,size(varTypes,2)],'VariableTypes',varTypes,'VariableNames',varNames);
    result.order(1:trial.num_pair) = randperm(trial.num_pair);
    result.order(trial.num_pair+1:trial.all) = randperm(trial.num_pair);
    result.('session1') = table('Size',[trial.session,size(varTypes,2)],'VariableTypes',varTypes,'VariableNames',varNames);
else
    % 読み込む
    load(strcat(pass.data,'/result.mat'));
    result.(strcat('session',num2str(session_num))) = table('Size',[trial.session,size(varTypes,2)],'VariableTypes',varTypes,'VariableNames',varNames);
end

% 捨て試行の呈示順
order_trash = randi([1,trial.num_pair],1,trial.trash);

%% Psychtoolbox

    %% PTB準備
    % set window
    PsychImaging('PrepareConfiguration');
    PsychImaging('AddTask', 'General', 'FloatingPoint32BitIfPossible');
    [winPtr, winRect] = PsychImaging('Openwindow', screenNumber, bg.color);
    Priority(MaxPriority(winPtr));
    %[offwin1,offwinrect]=Screen('OpenOffscreenWindow',winPtr, 0);
    
    %FlipInterval = Screen('GetFlipInterval', winPtr); % monitor 1 flame time
    %RefleshRate = 1./FlipInterval; 
    HideCursor(screenNumber);
    
    % 画面サイズ、位置の取得
    [win_width, win_height]=Screen('WindowSize', winPtr);
    [mx,my] = RectCenter(winRect);
    
    %% 刺激背景画像読み込み
    %% 要確認
    
    
    
    load('../stimuli/back/back_stimuli.mat');
    %{
    Screen('TextSize', winPtr, 50);
    DrawFormattedText(winPtr, 'Please wait', 'center', 'center',[255 255 255]);
    Screen('Flip', winPtr);
    load('../stimuli/stimuli_bunny.mat');
    load('../stimuli/stimuli_dragon.mat');
    load('../stimuli/stimuli_blob.mat');
    %}
    [sti_image.y,sti_image.x,sti_image.z] = size(back_stimuli(:,:,:,1));
    
    %% 実験パラメータ設定
    % 時間関連
    exp_time.show_stimuli = 1; % 刺激の呈示時間[s]
    exp_time.before = 0.5; % 呈示前の時間[s]
    exp_time.interval = 0.5; % 試行間のインターバルの時間[s]
    
    % 刺激サイズ関連
    view_distance = 80; % 視距離 (cm)
    screen_width = 54.3; % スクリーンの横幅（cm）
    visual_angle = 11; % 視角（degree）
    sx = 2 * view_distance * tan(deg2rad(visual_angle/2)) * win_width / screen_width; % stimuli x size (pixel)
    sy = sx * sti_image.y / sti_image.x; % stimuli y size (pixel)
    distance = 14; % 刺激間の距離 (pixel) 
    
    % 呈示位置関連
    position.count = 1; % 刺激の呈示位置のカウンタ
    position.presentation_num = 25; % 呈示枚数
    position.presentation =  presentation_position(win_width,win_height,2*sx+distance,sy); % 呈示位置のリスト
    
    %% 実験開始直前の表示
    text.start = 'Press any key to start';
    Screen('TextSize', winPtr, 50);
    DrawFormattedText(winPtr, text.start, 'center', 'center',[255 255 255]);
    Screen('Flip', winPtr);
    KbWait([], 2);
    WaitSecs(2);
    
    %% 実験のメインループ
    for i = 1:trial.session + trial.trash
        %% 呈示する刺激と位置を決定
        % 呈示する刺激の決定
        if i <= trial.trash % 捨て試行
            trial.idx_num = order_trash(i); % 全試行のうちのインデックスの番号
            id = idx(trial.idx_num,:); % この試行で呈示する刺激のインデックス
        else % 本試行
            n = trial.session*(session_num-1) + (i-trial.trash); % 全体の試行番号
            trial.idx_num = result.order(n);
            id = idx(trial.idx_num,:);
        end
        
        left_right = randi([1 2]); % 左に呈示する画像がhue1かhue2か
        
        pass.stimuli = strcat('../stimuli/',object.shape,'/',object.material(id(1)) ,'/',object.light(id(2)),'/',object.rough(id(3)));
        load(strcat(pass.stimuli,'/stimuli.mat')); % 刺激読み込み
        sti_image.rgb_left = stimuli(:,:,:,id(3+left_right)); % 左に呈示する画像のrgb値
        sti_image.rgb_right = stimuli(:,:,:,id(6-left_right)); % 右に呈示する画像のrgb値
        
        
        %% ここから修正
        % 刺激呈示位置
        %position.rx = randi(fix(win_width-(2*sx+distance))-1);
        %position.ry = randi(fix(win_height-sy)-1);
        position.rx = position.presentation(position.count,1);
        position.ry = position.presentation(position.count,2);
        position.left = [position.rx, position.ry, position.rx+sx, position.ry+sy];
        position.right = [position.rx+sx+distance, position.ry, position.rx+2*sx+distance, position.ry+sy];
        
        position.count = position.count + 1;
        if position.count > position.presentation_num
            position.count = 1;
        end
        
        % 試行番号と呈示する刺激のパラメータ表示
        if i <= trial.trash
            fprintf('trash\n');
        else
            fprintf('main\n');
        end
        fprintf('trial number in this session : %d\n', i);
        fprintf('stimuli number : %d\n', trial.idx_num);
        fprintf('%s, %s, diffuse:%f, rough:%f, %s\n', object.shape(id(1)),object.light(id(2)),object.diffuse_v(id(3)),object.rough_v(id(4)),object.method(id(5)));
        fprintf('color pair : %s vs %s\n', object.hue(id(5+left_right)),object.hue(id(8-left_right)));
        
        %% 刺激呈示前に背景のみ呈示
        sti_image.tex_back_left = Screen('MakeTexture', winPtr,back_stimuli(:,:,:,id(2)));
        sti_image.tex_back_right = Screen('MakeTexture',winPtr,back_stimuli(:,:,:,id(2)));
        Screen('DrawTexture', winPtr, sti_image.tex_back_left, [], position.left);
        Screen('DrawTexture', winPtr, sti_image.tex_back_right, [], position.right);
        exp_time.flip = Screen('Flip', winPtr);
        
        %% 刺激呈示
        sti_image.tex_left = Screen('MakeTexture', winPtr,sti_image.rgb_left);
        sti_image.tex_right = Screen('MakeTexture', winPtr,sti_image.rgb_right);
        Screen('DrawTexture', winPtr, sti_image.tex_left, [], position.left);
        Screen('DrawTexture', winPtr, sti_image.tex_right, [], position.right);
        exp_time.flip = Screen('Flip', winPtr, exp_time.flip + exp_time.before);
        %exp_time.flip = Screen('Flip', winPtr);
        
        % capture
        sti_image.capture = Screen('GetImage',winPtr);
        
        % 1秒後に刺激を消す
        Screen('FillRect', winPtr, bg.color);
        exp_time.flip = Screen('Flip', winPtr, exp_time.flip+exp_time.show_stimuli);
        %exp_time.flip = Screen('Flip', winPtr);
        Screen('Close', [sti_image.tex_left, sti_image.tex_right]);
        
        %% 被験者応答
        keyIsDown = 0;
        flag = 0;
        while 1
            [keyIsDown,seconds,keyCode] = KbCheck(-1);
            if keyIsDown && keyCode(key.left)
                flag = 1;
                response = left_right;
                break;
            elseif keyIsDown && keyCode(key.right)
                flag = 2;
                response = 3 - left_right;
                break;
            elseif keyIsDown && keyCode(key.escape)
                flag = 3;
                response = 0;
                break;
            end
        end
        exp_time.response = datetime;
        
        %% 中断処理
        if flag == 3
            DrawFormattedText(winPtr, 'Experiment is interrupted', 'center', 'center',[255 255 255]);
            Screen('Flip', winPtr);
            WaitSecs(1);
            break
        end
        
        %% 応答データを記録
        if i > trial.trash
            %session_result(i-trial.trash,:) = {object.shape(id(1)),object.light(id(2)),object.diffuse_v(id(3)),object.rough_v(id(4)),object.method(id(5)),object.hue(id(6)),object.hue(id(7)),object.hue(id(5+response)),exp_time.response};
            result.(strcat('session',num2str(session_num)))(i-trial.trash,:) = {object.shape(id(1)),object.light(id(2)),object.diffuse_v(id(3)),object.rough_v(id(4)),object.method(id(5)),object.hue(id(6)),object.hue(id(7)),object.hue(id(5+response)),exp_time.response,left_right};
            result.data(trial.idx_num,:) = {object.shape(id(1)),object.light(id(2)),object.diffuse_v(id(3)),object.rough_v(id(4)),object.method(id(5)),object.hue(id(6)),object.hue(id(7)),object.hue(id(5+response)),exp_time.response,left_right};
        end
        
        % 応答表示
        fprintf('pressed key : %d\n', flag);
        fprintf('subject response : %s\n\n', object.hue(id(5+response)));
        
        %% 実験が半分経過
        if i == round((trial.session+trial.trash)/2)
            DrawFormattedText(winPtr, 'Half. Press any key to continue.', 'center', 'center',[255 255 255]);
            Screen('Flip', winPtr);
            KbWait([], 2);
        end
        
        WaitSecs(exp_time.interval);
    end
    
    %% 実験終了後
    exp_time.finish = datetime; % 実験終了時刻
    
    % データ保存
    %result = setfield(result,strcat('session',num2str(session_num)),session_result);
    save(strcat(pass.data,'/result.mat'), 'result');
    writetable(result.data, strcat(pass.data,'/result_data.txt'));
    writetable(result.(strcat('session',num2str(session_num))), strcat(pass.data,'/session',num2str(session_num),'.txt'));
    
    % セッションごとのログ
    exp_time.exp_long = exp_time.finish - exp_time.date;
    fp = fopen(exp_record,'a');
    fprintf(fp, '%dセッション目\n', session_num);
    fprintf(fp, '実験実施日　%s\n', char(exp_time.date));
    fprintf(fp, '試行回数　%d回\n', i);
    fprintf(fp, '実験時間　%s\n\n', char(exp_time.exp_long));
    fclose(fp);
    
    % 終了の表示
    text.finish = 'The experiment is over. Press any key.';
    Screen('TextSize', winPtr, 50);
    DrawFormattedText(winPtr, text.finish, 'center', 'center',[255 255 255]);
    Screen('Flip', winPtr);
    KbWait([], 2);
    
    % 終了処理
    Priority(0);
    Screen('CloseAll');
    ShowCursor;
    ListenChar(0);
catch
    Screen('CloseAll');
    ShowCursor;
    ListenChar(0);
    psychrethrow(psychlasterror);
end
