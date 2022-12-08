%% 刺激画像のLab色度を確認
% 比較のためにu'v'での色度もプロット

clear all;

flag_par = 3; % 実験番号
object = object_paramater(flag_par); % 各パラメータまとめ
idx = make_index(flag_par);
pass.mat = '../../mat/';

spectrum_data = csvread('../../../calibration/spectrum_data.csv');
rgb_converter = tnt.RgbConverter(spectrum_data);
xyz_max = rgb_converter.linear_rgb_to_xyz([1,1,1]');

% L*a*b*変換時の白色点設定
wp.d65_XYZ = whitepoint('d65');
wp.d65_XYZ_disp = wp.d65_XYZ * xyz_max(2);

% 白色点
wp.d65_uvl = tnt.three_channel_convert([], wp.d65_XYZ_disp', @(c,d) XYZTouvY(d))';
wp.d65_lab = tnt.three_channel_convert([], wp.d65_XYZ_disp', @(c,d) XYZToLab(d, wp.d65_XYZ_disp'))';


%% Main
count = 0;
for i = 1:object.material_num % material
    
    if i == 1
        hue_name = object.hue;
        hue_num = object.hue_num;
    elseif i == 2
        hue_name = object.hue_metal;
        hue_num = object.hue_metal_num;
    end
    
    for j = 1:object.light_num
        for k = 1:object.rough_num
            % 画像読み込み
            pass.object = strcat(pass.mat,object.shape(1),'/',object.material(i),'/',object.light(j),'/',object.rough(k),'/');
            load(strcat(pass.object,'stimuli_xyz.mat'));
            load('../../mat/mask/bunny_mask.mat');
            load('../../mat/mask/highlight_mask.mat');
            load('../../mat/mask/highlight_round_mask.mat');
            
            %f = figure;
            %hold on;
            for h = 1:hue_num
                %% 値計算
                img = stimuli_xyz(:,:,:,h);
                
                mask = logical(mask);
                mask_HL = highlight_mask(:,:,h,i,j,k);
                mask_HL_near = highlight_round_mask(:,:,h,i,j,k);
                mask_body = logical(mask - mask_HL);
                
                % L*a*b*に変換
                img_lab = tnt.three_channel_convert([], img, @(c,d) XYZToLab(d, wp.d65_XYZ_disp'));
                
                % 各成分取り出し
                lab_all.l_map(:,:,h) = img_lab(:,:,1);
                lab_all.a_map(:,:,h) = img_lab(:,:,2);
                lab_all.b_map(:,:,h) = img_lab(:,:,3);
                
                % 物体部分の値取り出し
                l_map_tmp = lab_all.l_map(:,:,h) .* mask;
                a_map_tmp = lab_all.a_map(:,:,h) .* mask;
                b_map_tmp = lab_all.b_map(:,:,h) .* mask;
                lab_object.l_map(:,:,h) = l_map_tmp;
                lab_object.a_map(:,:,h) = a_map_tmp;
                lab_object.b_map(:,:,h) = b_map_tmp;
                lab_object.l_list(:,:,h) = l_map_tmp(mask);
                lab_object.a_list(:,:,h) = a_map_tmp(mask);
                lab_object.b_list(:,:,h) = b_map_tmp(mask);
                
                % ハイライト部分の値取り出し
                l_map_tmp = lab_all.l_map(:,:,h) .* mask_HL;
                a_map_tmp = lab_all.a_map(:,:,h) .* mask_HL;
                b_map_tmp = lab_all.b_map(:,:,h) .* mask_HL;
                lab_HL.l_map(:,:,h) = l_map_tmp;
                lab_HL.a_map(:,:,h) = a_map_tmp;
                lab_HL.b_map(:,:,h) = b_map_tmp;
                lab_HL.l_list(:,:,h) = l_map_tmp(mask_HL);
                lab_HL.a_list(:,:,h) = a_map_tmp(mask_HL);
                lab_HL.b_list(:,:,h) = b_map_tmp(mask_HL);
                
                % ハイライト周辺部分の値取り出し
                l_map_tmp = lab_all.l_map(:,:,h) .* mask_HL_near;
                a_map_tmp = lab_all.a_map(:,:,h) .* mask_HL_near;
                b_map_tmp = lab_all.b_map(:,:,h) .* mask_HL_near;
                lab_HL_near.l_map(:,:,h) = l_map_tmp;
                lab_HL_near.a_map(:,:,h) = a_map_tmp;
                lab_HL_near.b_map(:,:,h) = b_map_tmp;
                lab_HL_near.l_list(:,:,h) = l_map_tmp(mask_HL_near);
                lab_HL_near.a_list(:,:,h) = a_map_tmp(mask_HL_near);
                lab_HL_near.b_list(:,:,h) = b_map_tmp(mask_HL_near);
                
                %% u'v'値計算
                % u'v'に変換
                img_uvl = tnt.three_channel_convert([], img, @(c,d) XYZTouvY(d));
                
                % 各成分取り出し
                uvl_all.u_map(:,:,h) = img_uvl(:,:,1);
                uvl_all.v_map(:,:,h) = img_uvl(:,:,2);
                uvl_all.l_map(:,:,h) = img_uvl(:,:,3);
                
                % 物体部分の値取り出し
                u_map_tmp = uvl_all.u_map(:,:,h) .* mask;
                v_map_tmp = uvl_all.v_map(:,:,h) .* mask;
                l_map_tmp = uvl_all.l_map(:,:,h) .* mask;
                uvl_object.u_map(:,:,h) = u_map_tmp;
                uvl_object.v_map(:,:,h) = v_map_tmp;
                uvl_object.l_map(:,:,h) = l_map_tmp;
                uvl_object.u_list(:,:,h) = u_map_tmp(mask);
                uvl_object.v_list(:,:,h) = v_map_tmp(mask);
                uvl_object.l_list(:,:,h) = l_map_tmp(mask);
                
                % ハイライト部分の値取り出し
                u_map_tmp = uvl_all.u_map(:,:,h) .* mask_HL;
                v_map_tmp = uvl_all.v_map(:,:,h) .* mask_HL;
                l_map_tmp = uvl_all.l_map(:,:,h) .* mask_HL;
                uvl_HL.u_map(:,:,h) = u_map_tmp;
                uvl_HL.v_map(:,:,h) = v_map_tmp;
                uvl_HL.l_map(:,:,h) = l_map_tmp;
                uvl_HL.u_list(:,:,h) = u_map_tmp(mask_HL);
                uvl_HL.v_list(:,:,h) = v_map_tmp(mask_HL);
                uvl_HL.l_list(:,:,h) = l_map_tmp(mask_HL);
                
                % ハイライト周辺部分の値取り出し
                u_map_tmp = uvl_all.u_map(:,:,h) .* mask_HL_near;
                v_map_tmp = uvl_all.v_map(:,:,h) .* mask_HL_near;
                l_map_tmp = uvl_all.l_map(:,:,h) .* mask_HL_near;
                uvl_HL_near.u_map(:,:,h) = u_map_tmp;
                uvl_HL_near.v_map(:,:,h) = v_map_tmp;
                uvl_HL_near.l_map(:,:,h) = l_map_tmp;
                uvl_HL_near.u_list(:,:,h) = u_map_tmp(mask_HL_near);
                uvl_HL_near.v_list(:,:,h) = v_map_tmp(mask_HL_near);
                uvl_HL_near.l_list(:,:,h) = l_map_tmp(mask_HL_near);
                
                %% プロット
                %{
                % 散布図（a*とb*）
                subplot(1,2,1);
                hold on;
                scatter(lab_object.a_list, lab_object.b_list, [], graph_color(h,:));
                xlabel('a');
                ylabel('b');
                title('Lab');
                
                %{
                % 散布図（a*とL*）
                %subplot(1,3,2);
                hold on;
                scatter(lab_object.a_list, lab_object.l_list, [], graph_color(h,:));
                xlabel('a');
                ylabel('L');
                
                % 散布図（b*とL*）
                %subplot(1,3,3);
                hold on;
                scatter(lab_object.b_list, lab_object.l_list, [], graph_color(h,:));
                xlabel('b');
                ylabel('L');
                %}
                
                % 散布図（u'v'）
                subplot(1,2,2);
                hold on;
                scatter(uvl_object.u_list, uvl_object.v_list, [], graph_color(h,:));
                xlabel('u');
                ylabel('v');
                title("u'v'");
                %}
                
            end
            
            % save
            save(strcat(pass.object,'lab_all.mat'), 'lab_all');
            save(strcat(pass.object,'lab_object.mat'), 'lab_object');
            save(strcat(pass.object,'lab_HL.mat'), 'lab_HL');
            save(strcat(pass.object,'lab_HL_near.mat'), 'lab_HL_near');
            save(strcat(pass.object,'uvl_all.mat'), 'uvl_all');
            save(strcat(pass.object,'uvl_object.mat'), 'uvl_object');
            save(strcat(pass.object,'uvl_HL.mat'), 'uvl_HL');
            save(strcat(pass.object,'uvl_HL_near.mat'), 'uvl_HL_near');
            
            clear lab_all lab_object lab_HL lab_HL_near uvl_all uvl_object uvl_HL uvl_HL_near;
            
        end
        
        count = count + 1
    end
    
end


%% プロット
% 素材・照明条件ごとにfigure作成（行：粗さ、列：labかuvか）
% 金属素材のCuとAuに関しては表示しない
graph_color = [[242,151,146]; [227,163,91]; [185,180,61]; [99,195,133];[41,196,182]; [79,188,225]; [173,169,229]; [225,154,192]] / 255;
region_txt = ["object", "HL", "HL near"];
for n = 1:3 % 領域の違い
    for i = 1:object.material_num % material

        %{
        if i == 1
            hue_name = object.hue;
            hue_num = object.hue_num;
        elseif i == 2
            hue_name = object.hue_metal;
            hue_num = object.hue_metal_num;
        end
        %}
        hue_num = 8;

        for j = 1:object.light_num

            f = figure;
            hold on;
            for k = 1:object.rough_num
                
                % 色度データ読み込み
                pass.object = strcat(pass.mat,object.shape(1),'/',object.material(i),'/',object.light(j),'/',object.rough(k),'/');
                switch n
                    case 1 % 物体全体
                        load(strcat(pass.object,'lab_object.mat'));
                        load(strcat(pass.object,'uvl_object.mat'));
                        lab = lab_object;
                        uvl = uvl_object;
                    case 2 % ハイライト部分
                        load(strcat(pass.object,'lab_HL.mat'));
                        load(strcat(pass.object,'uvl_HL.mat'));
                        lab = lab_HL;
                        uvl = uvl_HL;
                    case 3 % ハイライト周辺部分
                        load(strcat(pass.object,'lab_HL_near.mat'));
                        load(strcat(pass.object,'uvl_HL_near.mat'));
                        lab = lab_HL_near;
                        uvl = uvl_HL_near;
                end

                count_panel = k;
               
                
                for h = 1:hue_num
                    
                    % 散布図（a*とb*）
                    x = lab.a_list(:,:,h);
                    y = lab.b_list(:,:,h);
                    subplot(2,3,count_panel);
                    hold on;
                    scatter(x, y, [], graph_color(h,:));
                    xlabel('a');
                    ylabel('b');
                    title(strcat("Lab, ", object.rough(k)));
                    grid on;
                    pbaspect([1 1 1]);

                    % 散布図（u'v'）
                    x = uvl.u_list(:,:,h);
                    y = uvl.v_list(:,:,h);
                    subplot(2,3,count_panel+3);
                    hold on;
                    scatter(x, y, [], graph_color(h,:));
                    xlabel("u'");
                    ylabel("v'");
                    title(strcat("u'v', ", object.rough(k)));
                    grid on;
                    pbaspect([1 1 1]);
                end
                
                % 白色点プロット
                % ab
                subplot(2,3,count_panel);
                hold on;
                scatter(wp.d65_lab(2), wp.d65_lab(3), [], [0,0,0], 'filled');
                % uv
                subplot(2,3,count_panel+3);
                hold on;
                scatter(wp.d65_uvl(1), wp.d65_uvl(2), [], [0,0,0], 'filled');
                
            end

            sgtitle(strcat(region_txt(n), ", ", object.material(i),", ",object.light(j)));
            
            f.WindowState = 'maximized';
            fig_name = strcat('色度プロット_',region_txt(n),'_',object.material(i),'_',object.light(j),'.png');
            file_name = strcat('../../image/color_coordinate/',fig_name);
            saveas(gcf, file_name);
            close;
            
        end     

    end
end