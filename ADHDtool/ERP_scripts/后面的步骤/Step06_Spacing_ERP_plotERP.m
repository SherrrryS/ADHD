%% Step06:[auto]
% load data for plot ERP
% 'EEG_average_subs&conds.mat' will be generaged

% Cond_names = {['Short'];['Middle'];['Long'];               %1-3
%               ['Forg'];['Rem'];                            %4-5
%               ['P1'];['P2'];                               %6-7
%               ['SF'];['MF'];['LF'];['SR'];['MR'];['LR'];   %8-13
%               ['S1'];['S2'];['M1'];['M2'];['L1'];['L2'];   %14-19
%               ['F1'];['F2'];['R1'];['R2'];                 %20-23
%               ['SF1'];['SF2'];['SR1'];['SR2'];             %24-27
%               ['MF1'];['MF2']; ['MR1'];['MR2'];            %28-31
%               ['LF1'];['LF2']; ['LR1'];['LR2'];            %32-35
%              };

%-------------------------------------------%
input_folder='results';
output_folder='results';
load([pwd '\process\EEG_template64.mat']);
% EEG_template=EEG;
% clear EEG;
eeglab

% analyze the averaged results
load([pwd '\' input_folder '\' 'EEG_data_all.mat']);
EEG_all_analyze=EEG_all_clean;  % EEG_all_clean;  %EEG_all
[condition_num file_num]=size(EEG_all_analyze);
sub_unselect=[ ];

if ~isempty(dir([pwd '\' output_folder '\' 'EEG_average_subs&conds.mat']));
    load([pwd '\' output_folder '\' 'EEG_average_subs&conds.mat']);
    eeglab redraw
else
    
    for conditon_cnt=1:(condition_num)
        EEG_condition=EEG_template;
        EEG_condition.setname=['Cond ' num2str(conditon_cnt)];
        EEG_condition.icaact=[];
        EEG_condition.icawinv=[];
        EEG_condition.icasphere=[];
        EEG_condition.icaweights=[];
        EEG_condition.icachansind=[];
        
        cond_name=['Cond ' num2str(conditon_cnt)];
        
        EEG_tmp.data=[];
        EEG_tmp.trials=0;
        EEG_tmp.epoch=[];
        EEG_tmp.event=[];
        EEG_tmp.urevent=[];
        file_count=1;
        for file_select=1:file_num 
            EEG_sub=EEG_all_analyze{conditon_cnt,file_select};
            EEG_sub.event.type=file_select;
            % %         %-------------------------------------------%
            % %         % remember to replace the bad channels
            % %         %-------------------------------------------%
            % %         for bad_chan_cnt=1:size(bad_chan_idx,1)
            % %
            % %             if sum(file_select==bad_chan_sub{bad_chan_cnt,1})~=0
            % %                 data_chan_tmp=mean(EEG_sub.data(bad_chan_replace_idx{bad_chan_cnt,1},:),1);
            % %                 EEG_sub.data(bad_chan_idx(bad_chan_cnt,1),:)=data_chan_tmp;
            % %                 clear data_chan_tmp
            % %             end
            % %         end
            % %         clear bad_chan_cnt
            % %
            if sum(file_select==sub_unselect)==0   % don's use those data (==1)
                EEG_sub.event(1,1).latency=EEG_sub.event(1,1).latency+size(EEG_sub.data,2)*(file_count-1);
                EEG_sub.event(1,1).epoch=EEG_sub.event(1,1).epoch+(file_count-1);
                
                EEG_tmp.data=cat(3,EEG_tmp.data,EEG_sub.data);
                EEG_tmp.trials=EEG_tmp.trials+EEG_sub.trials;
                EEG_tmp.epoch=cat(2,EEG_tmp.epoch,EEG_sub.epoch);
                EEG_tmp.event=cat(2,EEG_tmp.event,EEG_sub.event);
                EEG_tmp.urevent=cat(2,EEG_tmp.urevent,EEG_sub.urevent);
                
                file_count=file_count+1;
            end
            clear EEG_sub
        end
        
        EEG_condition.data=EEG_tmp.data;
        EEG_condition.trials=EEG_tmp.trials;
        EEG_condition.epoch=EEG_tmp.epoch;
        EEG_condition.event=EEG_tmp.event;
        EEG_condition.urevent=EEG_tmp.urevent;
        
        EEG=EEG_condition;
        clear EEG_condition EEG_tmp
        if ~isempty(LASTCOM) & ~isempty(EEG),
            [ALLEEG EEG CURRENTSET LASTCOM] = pop_newset(ALLEEG, EEG, CURRENTSET,'setname',cond_name, 'study', ~isempty(STUDY)+0);
            eegh(LASTCOM);
            disp('Done.');
        end;
        eeglab('redraw');
        
    end
    
    save([pwd '\' output_folder '\' 'EEG_average_subs&conds.mat']);
    %-------------------------------------------%
end


% %
% %
% % %-------------------------------------------%
% % % please delete the unnecessary data
% % input_folder='preprocess';
% % output_folder='results_final';         % you'd better describe the purpose of this reprocessing step
% %
% % load([pwd '\' input_folder '\' 'EEG_template62.mat']);
% % EEG_template=EEG;
% % clear EEG;
% %
% % analyze_average_enable=0;  % averaged
% %
% % EEG_analyze_command='EEG_analyze=EEG_final_clean;';  % EEG_final_clean;   EEG_final
% % sub_unselect=[5,7,8,10,20];  % 26? with few trials
% % category_unselect=[32];  % 26? with few trials
% %
% % chanind_select = [1:30,33:64];
% %
% % freq_scal=[1:1:50];   % TF freq
% % sr=500;
% % ncw=6;
% % ncw_vary=1;
% % E_type='p';
% % TF_nonpl_istype2=1;
% %
% % file_ext='mat';
% % file_ini='data';
% %
% % file_dir=dir(output_folder);
% %
% % file_num=size(file_dir,1)-2;
% % file_num_cnt=1;
% %
% % for file_cnt=1:file_num
% %     file_tmp=file_dir(file_cnt+2,1).name;
% %     if strcmp(file_tmp(1,(size(file_tmp,2)-2:size(file_tmp,2))),file_ext)==1 && strcmp(file_tmp(1,1:4)),file_ini)==1    % 'mat'  'data'
% %         file_names{file_num_cnt,1}=file_tmp;
% %         file_num_cnt=file_num_cnt+1;
% %     end
% % end
% % file_num=file_num_cnt-1;
% %
% % file_cnt=1;
% % for file_select=1:file_num
% %
% %     file_name=file_names{file_select,1};
% %     if sum(file_select==sub_unselect)==0   % don's use those data (==1)
% %         load([pwd '\' output_folder '\' file_name]);  % save every thing
% %         eval(EEG_analyze_command);
% %         condition_num=size(EEG_analyze,1);
% %         category_count=1;
% %
% %         for conditon_cnt=1:condition_num
% %             EEG_all_tmp=EEG_template;
% %             EEG_tmp=EEG_analyze{conditon_cnt,1};
% %
% %             if analyze_average_enable==1
% %             % average
% %                 EEG_all_tmp.data=mean(EEG_tmp.data(chanind_select,:,:),3);
% %                 EEG_all_tmp.trials=1;
% %                 EEG_all_tmp.epoch=EEG_tmp.epoch(1,1);
% %                 EEG_all_tmp.event=EEG_tmp.event(1,1);
% %                 EEG_all_tmp.urevent=EEG_tmp.urevent(1,1);
% %                 EEG_all_tmp.setname=['Cond ' num2str(conditon_cnt)];
% %
% %                 EEG_all_average{conditon_cnt,file_cnt}=EEG_all_tmp;
% %             end
% %
% %             % TF
% %             if sum(conditon_cnt==category_unselect)==0
% %                 [TF_both,TFpl,TF_npl_type1,TF_npl_type2,plf] = mf_eegtf(EEG_tmp.data,freq_scal,sr,6,0,'p',1);
% %                 [chan_num,freq_num,time_num]=size(TF_both);
% %
% %                 TF_both_sub(:,:,:,category_count,file_cnt)=TF_both;
% %                 TFpl_sub(:,:,:,category_count,file_cnt)=TFpl;
% %                 TF_npl_type1_sub(:,:,:,category_count,file_cnt)=TF_npl_type1;
% %                 TF_npl_type2_sub(:,:,:,category_count,file_cnt)=TF_npl_type2;
% %                 plf_sub(:,:,:,category_count,file_cnt)=plf;
% %
% %                 category_count=category_count+1;
% %                 clear TF_both TFpl TF_npl_type1 TF_npl_type2 plf
% %             end
% %             clear EEG_tmp EEG_all_tmp
% %         end
% %         file_cnt=file_cnt+1;
% %     end
% %     clear EEG_analyze
% %     clear EEG_final EEG_final_clean data_ave data_ave_clean data_final data_final_clean COM_badrej_subject
% % end
% %
% %
% % TF_both_ave=mean(TF_both_sub,5);
% % TFpl_ave=mean(TFpl_sub,5);
% % TF_npl_type1_ave=mean(TF_npl_type1_sub,5);
% % TF_npl_type2_ave=mean(TF_npl_type2_sub,5);
% % plf_ave=mean(plf_sub,5);
% %
% % save([pwd '\' output_folder '\' 'EEG_TF_results.mat'],'TF_both_sub','TFpl_sub','TF_npl_type1_sub','TF_npl_type2_sub','plf_sub','TF_both_ave','TFpl_ave','TF_npl_type1_ave','TF_npl_type2_ave','plf_ave','chan_num','freq_num','time_num');
% %
% % if analyze_average_enable==1
% %     save([pwd '\' output_folder '\' 'EEG_all_subjects_average.mat'],'EEG_all_average');
% % end
% % %-------------------------------------------%
% %
% %
% %
% %
% %
% %
% %
% %
% % %-------------------------------------------%
% % % display the TF results
% % output_folder='results_final';         % you'd better describe the purpose of this reprocessing step
% %
% % TF_name='TF_both'; %TF_both,TFpl,TF_npl_type1,TF_npl_type2,plf
% %
% % TF_style_command=['TF_draw=' TF_name];
% % TF_style_command2=['TF_draw2=' TF_name];
% %
% % load([pwd '\' output_folder '\' 'EEG_TF_results.mat']);
% % category_select=1;   % from 1 to 31 (32)
% % subject_select=1;    % 0 = ave
% %
% % chanind_select = [1:30,33:64];
% %
% % freq_scal=[1:1:50];   % TF freq
% % sr=500;
% % ncw=6;
% % ncw_vary=1;
% % E_type='p';
% % TF_nonpl_istype2=1;
% %
% % [chan_num,freq_num,time_num]=size(TF_both);
% %
% % if size(category_select,2)>1
% %     if subject_select~=0
% %         TF_style_command=[TF_style_command '_ave' '(chanind_select,:,:,category_select);'];
% %         TF_style_command2=[TF_style_command2 '_ave' '(chanind_select,:,:,category_select);'];
% %     else
% %         TF_style_command=[TF_style_command '_sub' '(chanind_select,:,:,category_select,subject_select);'];
% %         TF_style_command2=[TF_style_command2 '_sub' '(chanind_select,:,:,category_select,subject_select);'];
% %     end
% %     TF_draw_final=abs(TF_draw-TF_draw2);  % plot their differences
% % else
% %     if subject_select~=0
% %         TF_style_command=[TF_style_command '_ave' '(chanind_select,:,:,category_select);'];
% %     else
% %         TF_style_command=[TF_style_command '_sub' '(chanind_select,:,:,category_select,subject_select);'];
% %     end
% %     TF_draw_final=TF_draw;
% % end
% %
% %
% % % TF_tmp=reshape(abs(TF_both(1,:,:)),freq_num,time_num);
% % % imagesc([1:tp], scal, real(TF_tmp));
% %
% % % time=1:1:sample_num;
% % % freq=1:1:freq_num;
% % % clim -- color clim, = [clow chigh]
% % % load  plot_chan_biosemi64.mat
% % % load plot_chan_scan64.mat
% % load plot_chan_scan62.mat
% % mf_drawtf_scan(TF_draw_final,0,ch_position,ch_label)
% %
% % % mf_drawtf(TF,0,ch_position,ch_label);
% % % mf_drawtf_scan(TF_draw_final,0,ch_position,ch_label,freq,time)
% % %-------------------------------------------%
% %
% %
% %
% %
% %
% %
% %
% %
% %
% % condition_num=size(EEG_final,1);
% % for cate_cnt=1:condition_num
% %     EEG_sub=EEG_all_clean{1,1};  % for temporary use
% % %      or  EEG_sub=EEG_all{1,1};  % for temporary use
% %
% %     % initialize
% %     EEG_sub.trials=0;
% %     EEG_sub.data=[];
% % %     EEG_sub.times=0;
% % %     EEG_sub.pnts=0;
% % %     EEG_sub.xmax=0;
% % %     EEG_sub.xmin=0;
% %     EEG_sub.event=[];
% %     EEG_sub.urevent=[];
% %     EEG_sub.setname=[];
% %     EEG_sub.epoch=[];
% %     EEG_sub.icaact=[];
% %     EEG_sub.icawinv=[];
% %     EEG_sub.icasphere=[];
% %     EEG_sub.icaweights=[];
% %     EEG_sub.icachansind=[];
% %
% %     for file_cnt=1:file_num
% %         EEG_tmp=EEG_all_clean{cate_cnt,file_cnt};
% %
% %         % update information
% %         EEG_sub.trials=EEG_sub.trials+EEG_tmp.trials;
% % %         EEG_sub.pnts=EEG_sub.pnts+EEG_tmp.pnts;
% % %         EEG_sub.xmax=EEG_sub.xmax+EEG_tmp.xmax;
% %         EEG_sub.data=cat(3,EEG_sub.data,EEG_tmp.data);  % trials 3
% %         EEG_sub.epoch=cat(2,EEG_sub.epoch,EEG_tmp.epoch);
% %         EEG_sub.event=cat(2,EEG_sub.event,EEG_tmp.event);
% %         EEG_sub.urevent=cat(2,EEG_sub.urevent,EEG_tmp.urevent);
% %         clear EEG_tmp
% %     end
% %     EEG_sub.setname=['Category ' num2str(cate_cnt)];
% %     EEG_sub_category{cate_cnt,1}=EEG_sub;
% %     clear EEG_sub
% % end
% %
% %
% %
% %
% %
% % eeglab
% %
% % condition_num=size(EEG_sub_category,1);
% %
% % for cate_cnt=1:condition_num
% %     cond_name=['C' num2str(cate_cnt)];
% %
% %
% % % [EEG LASTCOM] = eeg_checkset(EEG, 'data');
% % % if ~isempty(LASTCOM),
% % %     if LASTCOM(1) == -1, LASTCOM = '';
% % %         return;
% % %     end;
% % % end;
% % % eegh(LASTCOM);
% %
% % EEG=EEG_sub_category{cate_cnt,1};
% %
% % % try,EEG=EEG_final{cate_cnt,1},LASTCOM=['EEG=EEG_final{cate_cnt,1}'];catch, eeglab_error; LASTCOM= ''; clear EEGTMP ALLEEGTMP STUDYTMP; end;
% % % EEG = eegh(LASTCOM, EEG);
% % % if exist('EEGTMP') == 1, EEG = EEGTMP; clear EEGTMP; end;
% % if ~isempty(LASTCOM) & ~isempty(EEG),
% %     [ALLEEG EEG CURRENTSET LASTCOM] = pop_newset(ALLEEG, EEG, CURRENTSET,'setname',cond_name, 'study', ~isempty(STUDY)+0);
% %     eegh(LASTCOM);
% %     disp('Done.');
% % end;
% % eeglab('redraw');
% %
% %
% % end
