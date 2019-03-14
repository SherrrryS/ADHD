%---------------Draw Brain Topoplot Maps Scripts---------------%
% E2.0 draw the maps of partial electrodes (automatically find the coordinates for the selected chans)
% 2012.11.07

% Topoplot function for ERP results.
% by WCM at beijing normal univ.  2012.10.03.
% allow the contrast maps between conditions (use  all 64 channels)
clear all;close all;clc;
addpath([pwd '\param']);
addpath([pwd '\functions']);
Cond_names = {['Short'];['Middle'];['Long'];               %1-3
              ['Forg'];['Rem'];                            %4-5
              ['P1'];['P2'];                               %6-7
              ['SF'];['MF'];['LF'];['SR'];['MR'];['LR'];   %8-13
              ['S1'];['S2'];['M1'];['M2'];['L1'];['L2'];   %14-19
              ['F1'];['F2'];['R1'];['R2'];                 %20-23
              ['SF1'];['SF2'];['SR1'];['SR2'];             %24-27
              ['MF1'];['MF2']; ['MR1'];['MR2'];            %28-31
              ['LF1'];['LF2']; ['LR1'];['LR2'];            %32-35
             };

% myeloc file name
eloc_file_name='myeloc.txt';
fid=fopen(eloc_file_name,'w');

%% -----------------------------------------------%
% parameters needs to be checked
category_select={[13 10]};
img_file_format=1;  % 1 = tif, 2=eps, 3=jpg, 4=fig
colorbar_enable=1;  % 1= with colorbars
caxis_range=[ ];%[-10 10]; % [] = default ;  % alternatively you can specify several ranges for each time window
% chan_unselect_plot=[ 30,10,17,23,24,25,28,29,30,56,60,62];
chan_unselect_plot=[ ];
% subject_select=0;  % 0 = ave, other = a specific subject
subjects=[1:8];
sub_unselect=[ ];
subjects(sub_unselect)=[ ];
%-----------------------------------------------%
% ---in times (ms)---
% time_window_sta=[0:100:500]'; % in ms
% time_window_end=[100:100:600]'; % in ms
% time_window=[time_window_sta  time_window_end];
% time_window_name={[time_window]};

% % or

% time_window_name=['RF'];
time_window=[210 240];
time_window_name={[time_window]};
%-----------------------------------------------%
% input data
input_folder='results';
load('param\Step1_param');
load([pwd '\' input_folder '\' 'EEG_data_all.mat']);
% results_folder_name='results_final_TF\TF';         % you'd better describe the purpose of this reprocessing step
% preprocess_folder='preprocess_TF';
output_folder=[pwd '\topoplot\']; if isempty(output_folder); mkdir(output_folder); end
sr=p.sr;
% epoch_limits=[-1000 2000];

% define the range limit referring to 0 (the first sample)
epoch_limits=epoch_limits*1000;%add this formula if the units was second;
before_stim_sample_limit=round(epoch_limits(1,1)*sr/1000);
% after_stim_sample_limit=round((epoch_limits(1,2))*sr)-1;

% check epoch param
if epoch_limits(1,1)>=epoch_limits(1,2)  disp('Epoch error!'); end  % 1 can't be equal to 2

for j=1:size(time_window,1)
    % check selection param
    if time_window(j,1)>time_window(j,2)
        disp('Selection error: ending time ahead of starting time!');
        
    else
        if epoch_limits(1,1)<=time_window(j,1)
            % no matter how eeglab actually epohes (<0, round, >0, round+1)
            if round((time_window(j,2))*sr/1000)==round((epoch_limits(1,2))*sr/1000)
                disp('Warning: the last sample can not be selected because of eeglab epoching rules!');
                sample_select_end=round((time_window(j,2))*sr/1000)-before_stim_sample_limit;
                if time_window(j,1)<time_window(j,2)
                    sample_select_start=1+round((time_window(j,1))*sr/1000)-before_stim_sample_limit;
                else
                    sample_select_start=sample_select_end;
                end
            elseif round((time_window(j,2))*sr/1000)<round((epoch_limits(1,2))*sr/1000)
                sample_select_end=1+round((time_window(j,2))*sr/1000)-before_stim_sample_limit;
                sample_select_start=1+round((time_window(j,1))*sr/1000)-before_stim_sample_limit;
            else
                disp('Selection error: Exceeding the last sample!');
            end
        else
            disp('Selection error: Exceeding the before stim range!');
        end
    end
    sample_select(j,:)=[sample_select_start,sample_select_end];
end


chan_EOG=[];  % special for scan
% chan_unselect_plot=[30];%10,17,23,24,25,28,29,30,56,60,62];  % get rid of outer elec  from 62  exclude two EOG  channels
chanind_selected = [1:64];%[1:30,33:64];   % actually not used here
chanind_selected_expend=chanind_selected;
chanind_selected(chan_EOG)=[];
chan_unselect_plot = [];
chanind_selected_expend(sort([chan_EOG chan_unselect_plot]))=[];
chan_select_num=size(chanind_selected,2);
chan_select_plot_num=size(chanind_selected_expend,2);
% define bad channels
%autumatically arrange channel location files
channel_name_plot_special={'Fc5.','Fc3.','Fc1.','Fcz.','Fc2.','Fc4.','Fc6.','C5..','C3..','C1..','Cz..','C2..','C4..','C6..','Cp5.','Cp3.','Cp1.','Cpz.','Cp2.','Cp4.','Cp6.','Fp1.','Fpz.','Fp2.','Af7.','Af3.','Afz.','Af4.','Af8.','F7..','F5..','F3..','F1..','Fz..','F2..','F4..','F6..','F8..','Ft7.','Ft8.','T7..','T8..','Tp7.','Tp8.','P9..','P7..','P5..','P3..','P1..','Pz..','P2..','P4..','P6..','P8..','P10.','Po7.','Po3.','Poz.','Po4.','Po8.','O1..','Oz..','O2..','Iz..'};
channel_name_plot=upper({'Fc5','Fc3','Fc1','Fcz','Fc2','Fc4','Fc6','C5','C3','C1','Cz','C2','C4','C6','Cp5','Cp3','Cp1','Cpz','Cp2','Cp4','Cp6','Fp1','Fpz','Fp2','Af7','Af3','Afz','Af4','Af8','F7','F5','F3','F1','Fz','F2','F4','F6','F8','Ft7','Ft8','T7','T8','Tp7','Tp8','P9','P7','P5','P3','P1','Pz','P2','P4','P6','P8','P10','Po7','Po3','Poz','Po4','Po8','O1','Oz','O2','Iz'});
chan_total_num_plot=size(channel_name_plot,2);

plot_channel_coord=[-68	0.3;-60	0.219;-42	0.14;0	0.101;42	0.14;60	0.219;68	0.3;-90	0.304;-90	0.203;-90	0.101;0	0;90	0.101;90	0.203;90	0.304;-112	0.3;-120	0.219;-138	0.14;180	0.101;138	0.14;120	0.219;112	0.3;    -18	0.406;
    0	0.406;18	0.406;-36	0.406;-23	0.343;0	0.304;23	0.343;36	0.406;-54	0.406;-46	0.363;-35	0.275;-21	0.219;0	0.203;21	0.219;35	0.275;46	0.363;54	0.406;-72	0.406;72	0.406;-90	0.406;90	0.406;    -108	0.406;    108	0.406;
    -126	0.499;-126	0.406;-134	0.343;-145	0.275;-159	0.219;180	0.181;159	0.219;145	0.275;134	0.343;126	0.406;126	0.499;-144	0.406;-157	0.343;180	0.304;157	0.343;144	0.406;-162	0.406;180	0.406;162	0.406;180	0.499
    ];
%
chan_name={'FP1','AF7','AF3','F1','F3','F5','F7','FT7','FC5','FC3','FC1','C1','C3','C5','T7','TP7','CP5','CP3','CP1','P1','P3','P5','P7','P9','PO7','PO3','O1','IZ','OZ','POZ','PZ','CPZ','FPZ','FP2','AF8','AF4','AFZ','FZ','F2','F4','F6','F8','FT8','FC6','FC4','FC2','FCZ','CZ','C2','C4','C6','T8','TP8','CP6','CP4','CP2','P2','P4','P6','P8','P10','PO8','PO4','O2'};
%==========================%
% % chan_num=size(chan_name,2);
%
% chan_reject=[];
% chan_plot_keep=[];
% for chan_select_cnt=1:chan_select_plot_num
%     cmp_tmp=0;
%     chan_name_plot_tmp=0;
%     for chan_plot_cnt=1:chan_total_num_plot
%         % compare upper()
%         if strcmp(chan_name{1,chanind_selected_expend(1,chan_select_cnt)},    channel_name_plot{1,chan_plot_cnt})==1
%             cmp_tmp=cmp_tmp+1;
%             chan_name_plot_tmp=chan_plot_cnt;
%         end
%     end
%
%     if cmp_tmp==1
%         chan_plot_keep=[chan_plot_keep chan_name_plot_tmp]; % for plot
%     elseif cmp_tmp==0
%         % no matched channels
%         chan_reject=[chan_reject chan_select_cnt];  % for chan names
%     else
%         disp('Error! Found more than 1 matched chan names!')
%     end
%
% end
% clear chan_select_cnt  chan_plot_cnt cmp_tmp chan_name_plot_tmp
%
% chan_select_final=chanind_selected_expend;%chanind_selected; % in selected
% chan_select_final(chan_reject)=[];  % now in 64
% % chanind_selected=chan_select_final;
% for topoplot, we have to reject some channels

chan_plot_keep=sort(chanind_selected);

% generate chan_order in 64
% chan_order=[];
% for chan_plot_cnt_final=1:size(chan_plot_keep,2)
%     tmp=0;
%     for chan_cnt_final=1:size(chan_select_final,2)
%         if strcmp(chan_name{1,chan_select_final(1,chan_cnt_final)},    channel_name_plot{1,chan_plot_keep(1,chan_plot_cnt_final)})==1
%             if tmp==0
% %                 chan_order=[chan_order chan_cnt_final];
%                     chan_order=[chan_order chan_select_final(1,chan_cnt_final)];
%             end
%             tmp=tmp+1;
%         end
%     end
% end
% clear tmp chan_plot_cnt_final chan_cnt_final
chan_order = [1:64];
chan_select_final = [1:64];

if (size(chan_plot_keep,2)~=size(chan_select_final,2))||(size(chan_plot_keep,2)~=size(chan_order,2))
    disp('Selected chan do not match plot chan');
end

% save eloc files for plot
for chan_plot_cnt_final=1:size(chan_plot_keep,2)
    chan_info_plot{chan_plot_cnt_final,1}=chan_plot_cnt_final;
    chan_info_plot{chan_plot_cnt_final,2}=plot_channel_coord(chan_plot_keep(1,chan_plot_cnt_final),1);
    chan_info_plot{chan_plot_cnt_final,3}=plot_channel_coord(chan_plot_keep(1,chan_plot_cnt_final),2);
    chan_info_plot{chan_plot_cnt_final,4}=channel_name_plot_special{1,chan_plot_keep(1,chan_plot_cnt_final)};
    
    fprintf(fid,'%d',chan_plot_cnt_final);
    fprintf(fid,'  ');
    fprintf(fid,'%d',plot_channel_coord(chan_plot_keep(1,chan_plot_cnt_final),1));
    fprintf(fid,'  ');
    fprintf(fid,'%f',plot_channel_coord(chan_plot_keep(1,chan_plot_cnt_final),2));
    fprintf(fid,'  ');
    fprintf(fid,'%s',channel_name_plot_special{1,chan_plot_keep(1,chan_plot_cnt_final)});
    fprintf(fid,'\n');
end
fclose(fid)
clear chan_plot_cnt_final

% transform indices in 64 to 62 channels
% chanind_selected_tmp=chanind_selected;
% chanind_selected_tmp(chan_EOG)=[];

if size(chan_order,2)~=size(chan_select_final,2)
    disp('Size of chan_select_final ~= size of chan_order!');
end

i=1;j=1;
for cnt_tmp=1:size(chan_order,2)
    for cnt_plot_tmp=1:size(chanind_selected,2)  % more than chan_order
        % order in 64 to order in 62
        if chan_order(1,cnt_tmp)==chanind_selected(1,cnt_plot_tmp)
            chan_order_new(1,i)=cnt_plot_tmp;
            i=i+1;
        end
        % actually not used
        if chan_select_final(1,cnt_tmp)==chanind_selected(1,cnt_plot_tmp)
            chan_select_final_plot(1,j)=cnt_plot_tmp;
            j=j+1;
        end
    end
end

if size(chan_order_new,2)~=size(chan_select_final_plot,2)
    disp('Size of chan_order_new ~= size of chan_select_final_plot! ')
end

chan_order=chan_order_new;  % now in 62 channels
% chanind_selected_expend=chan_select_final_new;

clear i j chan_order_new
save chan_order.mat chan_order chan_info_plot chanind_selected_expend chan_select_final_plot chan_select_final
% chan_plot_num=size(chan_order,2);
%--------------------------------------------------------%

%--------------------------------------------------------%
%load data
% for sub=1:length(subjects)
%     tmp_sub=num2str(subjects(sub));
%     load([pwd '\' input_folder '\' 'data_final_Conditions_S' tmp_sub '_all.mat']);
%     data_tmp(:,sub)=data_ave;
% end
% clear tmp_sub Data_ave EEG_final_clean data_final_clean;

for k=1:size(category_select,1)
    category_select_cnt=cell2mat(category_select(k,:));
    %      file_select=subjects;
    %      load([pwd '\' input_folder '\' 'data_final_Category_S' num2str(file_select) '_all.mat']);
    for cate_cnt=1:size(category_select_cnt,2)
        %         data=mean(data_final_clean{category_select_cnt(1,cate_cnt),1},3);
        data_all_tmp=[];
        % first level average
        for subject_cnt=1:size(subjects,2)
            data_subject_tmp=EEG_all_clean{category_select_cnt(1,cate_cnt),subjects(1,subject_cnt)}.data;
            data_subject_ave=mean(data_subject_tmp,3);
            data_all_tmp=cat(3,data_all_tmp,data_subject_ave);
            clear data_subject_ave data_subject_tmp
        end
        if subject_cnt==1
            data_ave_tmp=data_all_tmp;
        elseif subject_cnt > 1
            data_ave_tmp=mean(data_all_tmp,3);
        end
        clear data_all_tmp subject_cnt
        %-------------------------
        % %         for chan_tmp_cnt=1:size(chanind_selected,2)
        % %             data_tmp(chan_tmp_cnt,:)=data(chanind_selected(1,chan_tmp_cnt),:);
        % %         end
        % %         clear data
        % %         data=data_tmp;
        % %         clear data_tmp chan_tmp_cnt
        %-----------------------------
        % %         for bad_chan_cnt=1:size(bad_chan_idx,1)
        % %             data_chan_tmp=mean(data(bad_chan_replace_idx{bad_chan_cnt,1},:),1);
        % %             data(bad_chan_idx(bad_chan_cnt,1),:)=data_chan_tmp;
        % %             clear data_chan_tmp
        % %         end
        %             TF_style_command2=['temp=' TF_name '_category;'];
        eval(['temp' num2str(cate_cnt) '=data_ave_tmp;']);
        clear data_ave_tmp
    end
    
    if size(category_select_cnt,2)==2
        ERP_draw_final=temp1-temp2;
    else
        ERP_draw_final=temp1;
    end
    clear temp1 temp2
end


%==================================%
% plot function
chan_plot_num=size(chan_order,2);
for time_range_cnt=1:size(sample_select,1)
    for chan_cnt=1:chan_plot_num
        temp=ERP_draw_final(chan_order(1,chan_cnt),sample_select(time_range_cnt,1):sample_select(time_range_cnt,2));
        signal_topoplot(chan_cnt,:)=mean(temp,2);
        clear temp
    end
    
    %----------------------------------------------%
    %     plot_title=['Time window: ' num2str(time_window(time_range_cnt,1)) ' to ' num2str(time_window(time_range_cnt,2)) ' ms'];
    %     plot_title=[ time_window_name ' _ ' Cond_names{category_select_cnt(1)} '-' Cond_names{category_select_cnt(2)}];
    plot_title=[ 'TW' num2str(time_window(time_range_cnt,1)) '-' num2str(time_window(time_range_cnt,2)) ' _ ' Cond_names{category_select_cnt(1)} '-' Cond_names{category_select_cnt(2)}];
    
    if size(category_select_cnt,2)==1
        cond_name=['_cond_' num2str(category_select_cnt(1,1))];
    elseif size(category_select_cnt,2)==2
        cond_name=['_cond_' num2str(category_select_cnt(1,1)) '-' num2str(category_select_cnt(1,2))];
    end
    
    % %     if erp_tf_power==2
    % %         file_name=['TF_topographic_' num2str(time_window(time_range_cnt,1)) '_' num2str(time_window(time_range_cnt,2)) cond_name];
    % %     else
    file_name=['ERP_topographic_' num2str(time_window(time_range_cnt,1)) '-' num2str(time_window(time_range_cnt,2)) cond_name];
    % %     end
    
    %======================%
    %       figure,mytopoplotEEG(signal_topoplot(:,1),'myeloc66.txt','gridscale',150);
    % %     figure,mytopoplotEEG(signal_topoplot(:,1),eloc_file_name,'gridscale',150,'electrodes','labels');
    load([pwd '\' input_folder '\' 'EEG_template64.mat']);
    figure,topoplot(signal_topoplot(:,1),EEG_template.chanlocs([1:64]),'gridscale',150,'electrodes','labels'); %use all 64 channels;
    %======================%
    %
    if colorbar_enable==1         colorbar;    end
    if size(caxis_range,2)~=0         caxis(caxis_range);    end
    
    set (gcf, 'PaperPosition',[0.25,2, 17.85,15]); %11.9954/2, 10/2]);
    title([plot_title]);%'the topoplot of the EEG Signals ']);
    % print('-djpeg',[file_directiroy signal_name '.jpg']);
    
    if img_file_format==1
        print('-dtiffnocompression','-r300',[output_folder file_name '.tif']);
    elseif img_file_format==2
        print('-depsc2',[output_folder file_name '.eps']);
    elseif img_file_format==3
        print('-djpeg',[output_folder file_name '.jpg']);
    elseif img_file_format==4
        saveas(gcf,[output_folder plot_title '.fig']);
    end
    %----------------------------------%
end


