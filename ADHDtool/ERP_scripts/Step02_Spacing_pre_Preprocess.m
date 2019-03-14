%% Process pipeline
%---Aim: These serials of scripts were used for processing EEG signals to get CLEAN single trial EEG;
% Step01: down sampling and find intial bad channel
% Step02: filtering,channel_slection, epoch, run ICA
% Step03: Rejction artifact components
% Step04: bad channel rejection and interpolation;
%         re-reference and remove baseline;
%         bad trial rejection;
%---Modified by JingLiu, 2016/4/20;

% ===================== Step02  [auto] ========================= %  
%Input bad channels, filtering,epoch, ICA
clear all

addpath([pwd filesep 'param']);
addpath([pwd filesep 'functions']);

%-----------------------------------------------------------%
% loading parameter files and updating bad channels
load([pwd filesep 'param' filesep 'Step0_40_param.mat']);
folder_path=[pwd filesep preprocess_folder];
bad_chan_tmp=xlsread([filesep 'param' filesep 'bad_chan_jl.xlsx']);
bad_chan_tmp(bad_chan_tmp==0)=NaN;
bad_chan(:,2)=mat2cell(bad_chan_tmp,ones(size(bad_chan,1),1),[size(bad_chan_tmp,2)]);
%-----------------------------------------------------------%


%-----------------------------------------------------------%
% generate the file - name list
file_name_tmp = dir(['preprocess' filesep 'rj_bad_period_*']);
file_num = length(file_name_tmp);
for ii = 1:file_num
    file_names{ii,1} = file_name_tmp(ii).name;
end
save([pwd filesep preprocess_folder filesep 'file_names1.mat'],'file_names');
%-----------------------------------------------------------%


%-----------------------------------------------------------%
% Input epoch information (default to use previous generated one)

PumpOutWindow2

load([pwd filesep 'param' filesep 'events_select.mat']); %updata events;
save([pwd filesep 'param' filesep 'Step1_40_param.mat'],'bad_chan','chaninfo','chanlocs','folder','p','param_folder','preprocess_folder','events_select','chan_select','epoch_limits','baseline_limits','reref_channels','taskname');
%-----------------------------------------------------------%


%% =======Run check loop to write down bad channels and set boundary======= %%

% preprocess steps subject by subjct:
for file_cnt=1:file_num
    %--------------------------------------%
%     clear bad_chan_sub
    try bad_chan_sub=bad_chan{file_cnt,2}; bad_chan_sub=bad_chan_sub(~isnan(bad_chan_sub));  catch  bad_chan_sub=[];   end
    bad_chan_num=size(bad_chan_sub);
    %--------------------------------------%
    file_name=file_names{file_cnt,1};
%     hdrfile=[file_name];
%     setfilename=file_name;
    
%     clear data data_f data_r
%     clear ALLEEG STUDY CURRENTSTUDY CURRENTSET EEG LASTCOM ALLCOM
    eeglab    
    load([folder_path filesep file_names{file_cnt,1}])
    EEG.chanlocs=chanlocs;
    EEG.chaninfo=chaninfo;

        
    %-----------------------------------------------------------%
    % Filtering
    data_f=mf_eeg_firfilter(EEG,p.filtering_set,p.sr,p.lp_start,p.lp_end,p.hp_start,p.hp_end);
    EEG.data=data_f;      clear data_f
    eeglab redraw
    %-----------------------------------------------------------%
    
%     % check filtering 
%     N=length(EEG.data(1,:));
%     fftdata=fft(EEG.data(1,:))/N;
%     frequency=linspace(0, EEG.srate/2, N/2+1);
%     plot(frequency, abs(fftdata(1:(N/2+1))).^2);
    %-----------------------------------------------------------%
    %re-reference 
%     if bad_chan_num~=0
%         bad_chan_idx=find(chanind_selected==bad_chan_sub);
%         chanind_selected_rereference=chanind_selected;
%         for bad_chan_cnt=bad_chan_num:-1:1
%             chanind_selected_rereference(bad_chan_idx(bad_chan_cnt))=[];
%             disp(['Chan ' num2str(bad_chan_idx(bad_chan_cnt)) ' will be excluded from re-reference!']);
%         end
%         data_rerefer = reref(data_f,chanind_selected_rereference,'keepref','on');%data_chansel);  % or (,[ch1,ch2])
%     else
%         data_rerefer = reref(data_f);
%     end
%     
%     
%     EEG.data=data_rerefer;
%     ALLEEG(1,CURRENTSET).data=data_rerefer;
%     EEG.data=data_rerefer;
%     clear data_rerefer data_f
    %-----------------------------------------------------------%
    % Epoch data    
    [EEG tmp] = pop_epoch( EEG, events_select, epoch_limits);
    [ALLEEG EEG CURRENTSET LASTCOM] = pop_newset(ALLEEG, EEG, CURRENTSET,'setname',['epoch_' file_name(14:end)]);
    eeglab redraw   

    
    %-----------------------------------------------------------%
    % Run ICA to decomposite the data
    mf_eeg_ica
    
     % eyeblink_detect
    ic_analyze_result_set{file_cnt,1}=mf_eeg_ica_analyze(EEG, p.sr, p.ica_analyze_set, p.eye_sensitive_channel, p.eye_threhold, p.Seg_Start_Label, p.Seg_End_Label);
    %-----------------------------------------------------------%     
        
          
  
    %-----------------------------------------------------------%
    % % save current EEG
    ALLEEG=[]; %EEG;
    ALLCOM{1,1}=['ALLEEG EEG CURRENTSET ALLCOM] = eeglab'];
    CURRENTSTUDY=0;
    CURRENTSET=1;
    LASTCOM=[];
    STUDY=[];    
    save([pwd filesep preprocess_folder filesep 'ICA_40_' file_name(14:end)],'EEG','ALLEEG','ALLCOM','CURRENTSTUDY','CURRENTSET','LASTCOM','STUDY');  % save every thing
    %-----------------------------------------------------------%
    
    
    disp('----------------------');
    disp([file_names{file_cnt,1}(15:18) ' save done!']);
    disp('----------------------');        
    % clear all variables (except global EEG, ALLEEG) except ...
    keep('preprocess_folder','file_names','file_cnt','file_num','folder_path','bad_chan','p','param_folder','param_name','ic_analyze_result_set','events_select','epoch_limits','baseline_limits','chanlocs','chaninfo');
    % ,'stim_type','stim_set','event_erp_update_set','seg_limits_set','seg_type_set','stim_type','stim_set','event_erp_update_set'   % depends
end

%========================================================================%
% save([pwd filesep preprocess_folder filesep 'IC_analyze_result_set40.mat'], 'ic_analyze_result_set');
