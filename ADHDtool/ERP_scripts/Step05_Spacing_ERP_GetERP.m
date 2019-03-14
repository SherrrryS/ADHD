%% Process pipeline
%---Aim: These serials of scripts were used for processing EEG signals to get CLEAN single trial EEG;
% Step01 [manual]: set process parameters, load biosemi data, downsampling, replace trigger, and reject bad periods
% Step02 [auto]: Input bad channels, filtering, eyeblink detect, epoch
% Step03 [manual]: Remove eyeblink component by visual examination, Rereference, Interpret bad channel and baseline correction
% Step04 [manual]: Reject bad trials by visual examination
%---Modified by XiaoZhao, Jun-Nov, 2015;

% ======================= Step05 [auto] ========================= %  
%everage epochs in each condition to get ERP;
clear all
addpath([pwd '\param']);
addpath([pwd '\functions']);
load([pwd '\param\Step1_40_param.mat']);
if ~exist('results'); mkdir('results'); end
input_folder_name='process';
output_folder_name='results';
output_folder='ERP_results'; 
if isempty(output_folder); mkdir(output_folder); end
% comments='conditions:';                  % decribe your results
%%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
% MUST BE UPDATED
Conditions = {
    {events_select(1:12)};{events_select(13:24)};{events_select(25:36)}; %lag: Short, Media, Long;
    {events_select([1:3 7:9 13:15 19:21 25:27 31:33])};{events_select([4:6 10:12 16:18 22:24 28:30 34:36])}; %memory: Forg, Rem
    {events_select([1:6 13:18 25:30])};{events_select([7:12 19:24 31:36])}; %Repetition: 1 2
    {events_select([1:3 7:9])};{events_select([13:15 19:21])};{events_select([25:27 31:33])};{events_select([4:6 10:12])}; {events_select([16:18 22:24])};{events_select([28:30 34:36])};%Lag&Mem: SF,MF,LF;
    {events_select(1:6)};{events_select(7:12)};{events_select(13:18)};{events_select(19:24)};{events_select(25:30)};{events_select(31:36)};%Lag&Rep: S1,S2,M1,M2,L1,L2
    {events_select([1:3 13:15 25:27])};{events_select([7:9 19:21 31:33])}; {events_select([4:6 16:18 28:30])};{events_select([10:12 22:24 34:36])};%Mem&Rep: F1,F2,R1,R2
    {events_select(1:3)};  {events_select(7:9)}; {events_select(4:6)};{events_select(10:12)}; %['SF1'];['SF2'];['SR1'];['SR2']
    {events_select(13:15)}; {events_select(19:21)}; {events_select(16:18)}; {events_select(22:24)}; %['MF1'];['MF2']; ['MR1'];['MR2'];
    {events_select(25:27)}; {events_select(31:33)}; {events_select(28:30)}; {events_select(34:36)}; %['LF1'];['LF2']; ['LR1'];['LR2'];
    };
% for epoching and removing bad trials
events_all = events_select;

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
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
filename_tmp = dir('process\Clean_40_S*.mat');
file_num = length(filename_tmp);
for ii = 1:file_num
    file_names{ii,1} = filename_tmp(ii).name;
end
save([pwd '\' folder '\file_names4'],'file_names'); clear ii

%% =======everage each event======= %%
for file_cnt=[1:39]%1:file_num
    file_name=file_names{file_cnt,1};
    clear ALLEEG STUDY CURRENTSTUDY CURRENTSET EEG LASTCOM ALLCOM
    eeglab   
    
    % epoch
    for i=1:size(Conditions,1)
        %-----------------------------------------------------------%
    load([pwd '\' input_folder_name '\' file_name]);  eeglab redraw
    CURRENTSET_tmp=CURRENTSET;
    %-----------------------------------------------------------%
        events_for_pop=Conditions{i,1}{1,1};
        if size(Cond_names,1)==size(Conditions,1)
            setname_ep=[file_name '_' 'Cond' int2str(i) '_' Cond_names{i,1}];
        else
            setname_ep=[file_name '_' 'Cond' int2str(i) '_' Cond_names{i,1}]; %  Conditions{1,i}];
        end
        
        try [EEG tmp LASTCOM]=pop_epoch(EEG, events_for_pop,epoch_limits); catch eeglab_error; LASTCOM= ''; clear tmp; end; EEG = eegh(LASTCOM, EEG);if ~isempty(LASTCOM) & ~isempty(EEG),[ALLEEG EEG CURRENTSET LASTCOM] = pop_newset(ALLEEG, EEG, CURRENTSET,'setname',setname_ep, 'study', ~isempty(STUDY)+0); eegh(LASTCOM);disp('Done.'); end; eeglab('redraw');
        % using new remove baseline  avoiding popping up new windows (default clicking OK)
        [EEG LASTCOM] = pop_rmbase(EEG,baseline_limits,[]);  % or leave the last two empty   'timerange'
        eeglab redraw
        
        %save data
        EEG_final_clean{i,1}=EEG;
        data_final_clean{i,1}=EEG.data;

% %         if save_all_subject_average==0
% %             EEG_all_clean{i,file_cnt}=EEG;
% %         elseif save_all_subject_average==1
            EEG_all_tmp.data=mean(EEG.data,3);
            EEG_all_tmp.trials=1;
            EEG_all_tmp.epoch=EEG.epoch(1,1);
            EEG_all_tmp.event=EEG.event(1,1);
            EEG_all_tmp.urevent=EEG.urevent(1,1);
    
            EEG_all_clean{i,file_cnt}=EEG_all_tmp;
            clear EEG_all_tmp   
% %         end    
%         
        clear setname_ep events_for_pop
        ALLEEG=pop_delset_new(ALLEEG,CURRENTSET);  % delete the last one! or the current one
        EEG=ALLEEG(1,CURRENTSET_tmp);
        CURRENTSET=CURRENTSET_tmp;
        eeglab redraw
        
        %     % to save memory , we could remove the latest datasets
        %      dataset_clear=size(ALLEEG,2);  % the latest dataset generated by epoching
        %     try,[ALLEEG LASTCOM] = pop_delset(ALLEEG, dataset_clear);catch, eeglab_error; LASTCOM= ''; clear EEGTMP ALLEEGTMP STUDYTMP; end;eegh(LASTCOM);eeglab redraw;
    end
    
% %     clear time_clk_coef_current_seg
    clear CURRENTSET_tmp
    disp('----------------------');
    disp([file_name(7:10) ' epoch done!']);
    disp('----------------------');
    
    %-----------------------------------------------------------%
    %-----------------------------------------------------------%
% %     EEG_template=EEG;
% %     EEG_template.trials=1;
% %     EEG_template.data=EEG.data(:,:,1);
% %     EEG_template.event=EEG.event(1,1);
% %     EEG_template.urevent=EEG.urevent(1,1);
% %     EEG_template.epoch=EEG.epoch(1,1);
% %     % generate EEG templates for further analysis
% %     save([pwd '\' output_folder_name '\EEG_template64.mat'], 'EEG_template');%, 'trigger_list_set','MAonset_list_update_set']);
% %     clear EEG_template
    %-----------------------------------------------------------%
  
    % global average
    for i=1:size(Conditions,1)
        data_tmp=data_final_clean{i,1};
        data_ave{i,1}=mean(data_tmp,3);
    end    
    clear data_tmp    
%     disp('Grand average done!');
   %-----------------------------------------------------------%   
     save([pwd '\' output_folder_name '\Data_final_Conditions_' num2str(file_name(7:10)) '_all.mat'], 'data_final_clean', 'EEG_final_clean', 'data_ave');% 'event_selected',, 'chanlocs', 'chanind_selected','comments','COM_badrej_subject');
%     save([pwd '\' output_folder '\EEG_final_allcat_allsub.mat'],  'Data_final', 'EEG_final');    
%     save([pwd '\' output_folder '\Data_final_' num2str(file_name(7:10)) '_avg.mat'],  'Data_avg');     
    
    disp('----------------------');
    disp([file_name(7:10) ' save done!']);
    disp('----------------------');
    clear data_ave data_final data_ave_clean data_final_clean EEG_final EEG_final_clean COM_badrej_subject
    % save data_final_trials.mat data_final Conditions data_ave EEG.chanlocs chanind_selected
    %-----------------------------------------------------------%    
    
end

save([pwd '\' output_folder_name '\EEG_data_all.mat'], 'EEG_all_clean');
disp('Finally save done!');