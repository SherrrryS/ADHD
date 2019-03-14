%% Process pipeline
%---Aim: These serials of scripts were used for processing EEG signals to get CLEAN single trial EEG;
% Step01: down sampling and find intial bad channel
% Step02: filtering, epoch, run ICA
% Step03: Rejction artifact components
% Step04: bad channel rejection and interpolation;
%         reference and remove baseline;
%         bad trial rejection;
%---Modified by JingLiu, 2016/4/20;

% ======================= Step04 [manual] ========================= %
%Reject bad trials by visual examination

clear all; close all;clc;
addpath([pwd '\param']);
addpath([pwd '\functions']);
load([pwd '\param\Step1_40_param.mat']);
%-----------------------------------------------------------%
input_folder_name='preprocess';
output_folder_name='process';  
mkdir(output_folder_name); 
%-----------------------------------------------------------%
% generate the file - name list
filename_tmp = dir('preprocess\IC_Remove_40_*.mat');
file_num = length(filename_tmp);
for file_cnt = 1:file_num
    file_names{file_cnt,1} = filename_tmp(file_cnt,1).name;
end
%-----------------------------------------------------------%

%% =======Run check loop to reject bad trials=======
for file_cnt =1:2
        
    file_name = file_names{file_cnt,1};
    load ([preprocess_folder '\' file_names{file_cnt,1}]);
    %     try bad_chan_sub=bad_chan{file_cnt,2};  bad_chan_sub=bad_chan_sub(bad_chan_sub>0); catch    bad_chan_sub=[];   end
    
    %     chanind_initial_selected = p.chanind_initial_selected;
    %     chan_order_set{file_cnt,1} = [setdiff(chanind_initial_selected, bad_chan_sub) bad_chan_sub];
    %--------------------------------------------------------------%
    % Interpolate bad channel
    tmp=bad_chan{file_cnt,2}(3:end);
    bad_chan_sub=tmp(~isnan(tmp));tmp=[];
    if ~isempty(bad_chan_sub)
        EEG = pop_select(EEG, 'nochannel',bad_chan_sub);
        EEG = eeg_interp(EEG, chanlocs(bad_chan_sub));
        [ALLEEG EEG CURRENTSET LASTCOM] = pop_newset(ALLEEG, EEG, CURRENTSET,'setname',['epoch_bc_' file_name(end-7:end-4)]);
        chan_select_tmp = [setdiff(p.chanind_initial_selected, bad_chan_sub) bad_chan_sub];
        tmp(chan_select_tmp,:,:)=double(EEG.data);
        tmp_cha(chan_select_tmp,:,:) = EEG.chanlocs;
        EEG.data=tmp;
        EEG.chanlocs=tmp_cha;
        clear tmp tmp_cha
        eeglab redraw
    else
    end
    %-----------------------------------------------------------%
    % Reference the data;
    % We have to reference the biosemi data to increase the SNR; For EGI, scan
    % and BP data, they have been referred to a channel already.
    % go after channel selection
    % average: reref(data);    re-referred to channels  reref(data, [1,2..]);
    % there is no need to manually stop here, data can be re-referred in processing steps
    datatmp=EEG.data(1:64,:,:);
    EEG.data=datatmp;
    chanloc_tmp=EEG.chanlocs(1:64);
    EEG.chanlocs=chanloc_tmp;
    clear datatmp chanloc_tmp
    reref_channels=[];
    data_r=reref(EEG.data,reref_channels);
    EEG.data=data_r;
    clear data_r
    [ALLEEG EEG CURRENTSET LASTCOM] = pop_newset(ALLEEG, EEG, CURRENTSET,'setname',['epoch_bc_reref_' file_name(end-7:end-4)]);
    eeglab redraw
    %-----------------------------------------------------------%
    % Remove baseline
    [EEG tmp] = pop_rmbase(EEG,baseline_limits,[]);
    [ALLEEG EEG CURRENTSET LASTCOM] = pop_newset(ALLEEG, EEG, CURRENTSET,'setname',['epoch_bc_reref_rb' file_name(end-7:end-4)]);
    eeglab redraw
    clear tmp
    %-------------------------------------------------------------%
    epoch_original=[];
    for kk = 1:size(EEG.epoch,2)   
        
        eventlatency=cell2mat(EEG.epoch(kk).eventlatency);
        eventtype=cell2mat(EEG.epoch(kk).eventtype);
        eventurevent=cell2mat(EEG.epoch(kk).eventurevent);
        
        EEG.epoch(kk).eventlatency={eventlatency(eventlatency==0)};
        EEG.epoch(kk).eventtype={eventtype(eventlatency==0)};
        EEG.epoch(kk).eventurevent={eventurevent(eventlatency==0)};
        
        epoch_original(kk)=cell2mat(EEG.epoch(kk).eventtype);
        EEG.epoch(kk).eventtype={kk};
    end
    %     data_all_clean(chan_order_set{file_cnt,1},:,:) = double(EEG.data);
    data_all_clean = double(EEG.data);
    eeglab redraw
    CURRENTSET_tmp=CURRENTSET;
    
    %     if ~exist([pwd '\' output_folder_name '\' 'Clean_' file_name(12:end)],'file') || ~exist([pwd '\' output_folder_name '\' 'Clean_data_' file_name(12:end)],'file')
%     if ~exist([pwd '\preprocess\trial_remove101-139.mat'])
%         % %     if isempty(dir('preprocess\trial_remove.mat'))
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %-----------------------------------------------------------%
        disp('----------------------');
        disp('Breakpoint for removing bad trials');
        disp('----------------------');
        dbstop in breakpoint
        bk=breakpoint(1);
%         %% semi-automaticly reject bad trials
%         % automatically detect the bad trial (-75, 75)
%         input_bt_break=1;
%         p.bad_trial_thresh = 75;
%         p.epoch_range=epoch_limits;
%         EEG_all=EEG;
%         [EEG Indexes] = pop_eegthresh(EEG_all,1,[1:64],-p.bad_trial_thresh,p.bad_trial_thresh,p.epoch_range(1,1),p.epoch_range(1,2),0,0);
%         % calculate the automatically detected trials time limits for plot
%         auto_markedtrial = [];
%         epoch_index = [EEG.event.epoch];
%         for bti=1:length(Indexes)
%             tmpi = find(epoch_index == Indexes(bti));
%             auto_markedtrial(bti,:) = [EEG.event(tmpi(1,1)).latency + epoch_limits(1,1)*EEG.srate EEG.event(tmpi(1,1)).latency + epoch_limits(1,2)*EEG.srate ...
%                 0.7 1 0.9 1:64];
%         end
% 
%         pop_eegplot(EEG,1,1,1,'','winrej',auto_markedtrial, 'winlength',5);
% 
%         %   alternatively, input a string to continue
%         if input_bt_break == 1
%             input_char=input('We stop here and please remove bad trials manually! To proceed, press c!','s');
%             while input_char~='c'
%                 input_char=input('We stop here and please remove bad trials manually! To proceed, press c!','s');
%             end
%             disp('Now, we have removed them!')
%             clear input_char
%         end
        %-----------------------------------------------------------%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        try COM_badrej_subject{1,1}=ALLCOM{1,1}; catch,COM_badrej_subject{1,1}=[];end;  % usually should be pop_newset
        try COM_badrej_subject{1,2}=ALLCOM{1,2}; catch,COM_badrej_subject{1,2}=[];end;  % should be pop_rej
        try COM_badrej_subject{1,3}=ALLCOM{1,3}; catch,COM_badrej_subject{1,3}=[];end;  % should be eegplot
        try COM_badrej_set{file_cnt,1}=ALLCOM{1,1}; catch,COM_badrej_set{file_cnt,1}=[];end;  % usually should be pop_newset
        try COM_badrej_set{file_cnt,2}=ALLCOM{1,2}; catch,COM_badrej_set{file_cnt,2}=[];end;  % should be pop_rej
        try COM_badrej_set{file_cnt,3}=ALLCOM{1,3}; catch,COM_badrej_set{file_cnt,3}=[];end;  % should be eegplot
        
        clear bad_trial_removal_index TF_results_sub_folder bad_trial_removal_index_rep3 bad_trial_idx_cnt bad_trial_idx_event bad_trial_idx_event_idx bad_trial_removal_index
        % labelling bad trials
        com_start=['EEG = pop_rejepoch( EEG, '];
        com_end=[',0);'];
        com_tmp=COM_badrej_subject{1,2}; %COM_badrej_set{file_cnt,2};
        
        if strcmp(com_tmp(1,(end-3):end),com_end)==1 && strcmp(com_tmp(1,1:25),com_start)==1  %%
            bad_trial_removal_index=eval(com_tmp(1,26:(end-3)));
            %--------------------------------------------------------------%
            %find the repeated item which was marked as badtrial, and remove
            %it togethter;
            file=file_names{file_cnt,1}((end-7):(end-4));
            load([pwd '\DATA\Trigger_replacement\' file '_Trigger.mat']);
            bad_trial_removal_index_rep=[];
            for i=1:length(Trigger)
                for j=1:length(bad_trial_removal_index)
                    idx=Trigger(bad_trial_removal_index(j),2);
                    bad_trial_removal_index_rep=[bad_trial_removal_index_rep find(Trigger(:,2)==idx)];
                end
            end
            bad_trial_removal_index_rep=unique(bad_trial_removal_index_rep);
            %--------------------------------------------------------------%
        else
            bad_trial_removal_index=[];
            bad_trial_removal_index_rep=[];
        end
        % %   bad_trial_removal_index_set{file_cnt,1}=bad_trial_removal_index;
        bad_trial_removal_index_set{file_cnt,1}=bad_trial_removal_index_rep;
        if size(bad_trial_removal_index_rep,1)~=0
            % reloading previous EEG data
            ALLEEG=pop_delset_new(ALLEEG,CURRENTSET);  % delete the last one! or the current one
            EEG=ALLEEG(1,CURRENTSET_tmp);
            CURRENTSET=CURRENTSET_tmp;
            clear CURRENTSET_tmp
            eeglab redraw
        end
        % %     else
        % %
        % %         load([pwd '\preprocess\trial_remove.mat']);
        % %         bad_trial_removal_index_rep=bad_trial_removal_index_set{file_cnt,1};
        % %     end
        %     elseif exist([pwd '\' output_folder_name '\' 'Clean_' file_name(12:end)],'file') || exist([pwd '\' output_folder_name '\' 'Clean_data_' file_name(12:end)],'file')
%     elseif exist([pwd '\preprocess\trial_remove101-139.mat'])
%         load([pwd '\preprocess\trial_remove101-139.mat']);
%         bad_trial_removal_index_rep=bad_trial_removal_index_set{file_cnt,1};
%     end
    
    %--------remove repeat-presented items--------%
    [EEG LASTCOM] = eeg_checkset(EEG, 'data');if ~isempty(LASTCOM), if LASTCOM(1) == -1, LASTCOM = ''; return; end; end; eegh(LASTCOM);try [EEG, com_tmp] = pop_rejepoch( EEG, bad_trial_removal_index_rep, 0);catch, eeglab_error; LASTCOM= '';  end;
    EEG = eegh(LASTCOM, EEG);
    % if ~isempty(LASTCOM) & ~isempty(EEG),[ALLEEG EEG CURRENTSET LASTCOM] = pop_newset(ALLEEG, EEG, CURRENTSET,'setname',bad_trial_removal_index_rep); eegh(LASTCOM);disp('Done.'); end;
    eeglab('redraw');
    
    bad_trial_removal_index_set{file_cnt,1}=bad_trial_removal_index_rep;
    events_nobt_clean=setdiff(1:length(epoch_original),bad_trial_removal_index_rep);
    data_nobt_clean = double(EEG.data);%data_all_clean;%(:,:,events_all_clean);
    
    %     if ~isempty(LASTCOM) & ~isempty(EEG),[ALLEEG EEG CURRENTSET LASTCOM] = pop_newset(ALLEEG, EEG, CURRENTSET,'setname','epoch_clean', 'study', ~isempty(STUDY)+0); eegh(LASTCOM);disp('Done.'); end;
    eeglab('redraw');
    ALLEEG=EEG;
    data_all_clean_set{file_cnt,1}=data_all_clean;  %clean data before rm bad_trial
    data_nobt_clean_set{file_cnt,1}=data_nobt_clean; %clean data after rm bad_trial
    events_nobt_clean_set{file_cnt,1} = events_nobt_clean; %clean event after rm bad_trial
    
    save([pwd '\' output_folder_name '\' 'Clean_40_' file_name(end-7:end-4)],'EEG','ALLEEG','ALLCOM','CURRENTSTUDY','CURRENTSET','LASTCOM','STUDY');
    save([pwd '\' output_folder_name '\' 'Clean_data_40_' file_name(end-7:end-4)], 'data_all_clean','events_nobt_clean','data_nobt_clean');%
    
    clear EEG ALLEEG ALLCOM CURRENTSTUDY CURRENTSET LASTCOM STUDY bad_trial_removal_index epoch_seq  bad_trial_removal_index_rep com_tmp
    keep('chan_order_set','file_names','preprocess_folder','p','output_folder_name','bad_trial_removal_index_set','data_all_clean_set', 'data_nobt_clean_set','events_nobt_clean_set','bad_chan','chanlocs','reref_channels','baseline_limits');
    
end

% save([pwd '\preprocess\trial_remove.mat'],'bad_trial_removal_index_set');
% save([pwd '\' output_folder_name '\Data_all_clean131-139'],'data_all_clean_set', 'events_nobt_clean_set','data_nobt_clean_set');
