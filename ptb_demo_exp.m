%% 実験画面に刺激画像を呈示する

% パス
pass.color_gloss = '/home/koizumi/experiment/exp_color_gloss';

% 初期準備
AssertOpenGL;
ListenChar(2);
KbName('UnifyKeyNames');
screenNumber = max(Screen('Screens'));
%InitializeMatlabOpenGL;

%% 初期値設定

% キーボード設定
key.escape = KbName('ESCAPE');
%key.left = KbName('1!');
%key.right = KbName('2@');
key.left = KbName('4');
key.right = KbName('6');
key.next = KbName('5');

% 実験画面の背景色の設定
cx2u = makecform('xyz2upvpl');
cu2x = makecform('upvpl2xyz');
bg_lum = 2;
wp_d65_XYZ = whitepoint('d65');
wp_d65_uvl = applycform(wp_d65_XYZ, cx2u);
bg_upvpl = [wp_d65_uvl(1), wp_d65_uvl(2), bg_lum];
bg_color = reshape(conv_XYZ2RGB(applycform(reshape(bg_upvpl,1,1,3),cu2x)),1,3)

% 背景のRGBを明示的に設定
% 測光してD65の色度や刺激画像の色度に近いことを確認

%bg_color = reshape(conv_XYZ2RGB(reshape(wp_d65_XYZ*bg_lum,1,1,3)),1,3)

% テキストの色設定
txt_color = reshape(conv_XYZ2RGB(reshape(wp_d65_XYZ*30,1,1,3)),1,3);

% 刺激のパラメータ
flag_par = 3; % 実験番号
object = object_paramater(flag_par); % 各パラメータまとめ
idx = make_index(flag_par);

%% Psychtoolbox
try
    %% PTB準備
    % set window
    PsychImaging('PrepareConfiguration');
    PsychImaging('AddTask', 'General', 'FloatingPoint32BitIfPossible');
    [winPtr, winRect] = PsychImaging('Openwindow', screenNumber, bg_color);
    Priority(MaxPriority(winPtr));
    
    % 画面サイズ、位置の取得
    [win_width, win_height]=Screen('WindowSize', winPtr);
    [mx,my] = RectCenter(winRect);
    
    %% 刺激画像読み込み
    i = 1; % material
    j = 1; % light
    k = 1; % roughness
    load(strcat('../stimuli/bunny/',object.material(i),'/',object.light(j),'/',object.rough(k),'/stimuli.mat'));
    [sti_image.y,sti_image.x,sti_image.z] = size(stimuli(:,:,:,1));
    
    %% 実験パラメータ設定
    exp_time.show_stimuli = 1; % 刺激の呈示時間[s]
    exp_time.before = 0.5; % 呈示前の時間[s]
    exp_time.interval = 0.5; % 試行間のインターバルの時間[s]
    
    % 刺激サイズの設定
    view_distance = 80; % 視距離 (cm)
    screen_width = 54.3; % スクリーンの横幅（cm）
    visual_angle = 11; % 視角（degree）
    sx = 2 * view_distance * tan(deg2rad(visual_angle/2)) * win_width / screen_width; % stimuli x size (pixel)
    sy = sx * sti_image.y / sti_image.x; % stimuli y size (pixel)
    distance = 14; % 刺激間の距離 (pixel)
    
    % 刺激呈示位置
    position.left = [mx-sx-distance/2, my-sy/2, mx-distance/2, my+sy/2];
    position.right = [mx+distance/2, my-sy/2, mx+sx+distance/2, my+sy/2];
    
    
    %% 実験開始直前
    text.start = 'Press any key to start';
    Screen('TextSize', winPtr, 50);
    DrawFormattedText(winPtr, text.start, 'center', 'center',txt_color);
    Screen('Flip', winPtr);
    KbWait([], 2);
    WaitSecs(2);
    
    trial.num = object.hue_num;
    for n = 1:trial.num
        fprintf('%s, %s, roughness:%f, %s\n', object.material(i),object.light(j),object.rough_v(k),object.hue(n));
        
        % 刺激呈示
        sti_image.rgb_color = stimuli(:,:,:,n);
        sti_image.rgb_gray = stimuli(:,:,:,8+n);
        sti_image.tex_color = Screen('MakeTexture',winPtr,sti_image.rgb_color);
        sti_image.tex_gray = Screen('MakeTexture',winPtr,sti_image.rgb_gray);
        Screen('DrawTexture', winPtr, sti_image.tex_color, [], position.left);
        Screen('DrawTexture', winPtr, sti_image.tex_gray, [], position.right);

        exp_time.flip = Screen('Flip', winPtr);

        
        % capture
        if n == 1
            sti_image.capture = Screen('GetImage',winPtr);
        end
        %}
            
        WaitSecs(0.5);
            
        % 被験者応答
        keyIsDown = 0;
        flag = 0;
        while 1
            [keyIsDown, seconds, keyCode] = KbCheck(-1);
            if keyIsDown && keyCode(key.next)
                flag = 1;
                break;
            elseif keyIsDown && keyCode(key.escape)
                flag = 2;
                break;
            end
        end

        % if push escape key, experiment is interrupted
        if flag == 2
            DrawFormattedText(winPtr, 'Experiment is interrupted', 'center', 'center',txt_color);
            Screen('Flip', winPtr);
            WaitSecs(1);
            break
        end
                   
        if flag == 2
            break;
        end
        
        WaitSecs(exp_time.interval);
    end
    
    % experiment finish
    finTime = datetime;
    finishText = 'The experiment is over. Press any key.';
    Screen('TextSize', winPtr, 50);
    DrawFormattedText(winPtr, finishText, 'center', 'center',txt_color);
    Screen('Flip', winPtr);
    KbWait([], 2);
    
    Priority(0);
    Screen('CloseAll');
    ShowCursor;
    ListenChar(0);
catch
    Screen('CloseAll');
    ShowCursor;
    a = "dame";
    ListenChar(0);
    psychrethrow(psychlasterror);
end
    