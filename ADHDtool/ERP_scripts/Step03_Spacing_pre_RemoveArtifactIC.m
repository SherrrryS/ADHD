%% Process pipeline
%---Aim: These serials of scripts were used for processing EEG signals to get CLEAN single trial EEG;
% Step01: down sampling and find intial bad channel
% Step02: filtering, epoch, run ICA
% Step03: Rejction artifact components
% Step04: bad channel rejection and interpolation;
%         reference and remove baseline;
%         bad trial rejection;
%---Modified by JingLiu, 2016/4/20;

% ======================= Step03 [manual] ========================= %
%Remove eyeblink or EMG, or other artifact component by visual examination,
% clear all; close all;clc;
load([pwd filesep 'param\Step1_40_param.mat'])
addpath([pwd filesep 'param']);
addpath([pwd filesep 'functions']);
%-----------------------------------------------------------%
% generate the file - name list
filename_tmp = dir('preprocess\ICA_40_*.mat');
file_num = length(filename_tmp);
for ii = 1:file_num
    file_names{ii,1} = filename_tmp(ii,1).name;
end
clear filename_tmp 
%-----------------------------------------------------------%


%% =======Run check loop to write down bad channels and set boundary=======

% preprocess steps subject by subjct:
for file_cnt = 1:file_num
    clear bad_chan_sub
    try bad_chan_sub=bad_chan{file_cnt,2}; bad_chan_sub=bad_chan_sub(~isnan(bad_chan_sub));  catch  bad_chan_sub=[];   end
    chan_sel=[1:66];
    chan_sel(bad_chan_sub)=[];
    
    load(['preprocess\' file_names{file_cnt,1}]);
    file_name=file_names{file_cnt,1};
    eeglab redraw
    
    
    if ~exist('D:\Graduate_study\spacing_JL\preprocess\IC_analyze_result_set40.mat','file')
        ic_analyze_result_set{file_cnt,1}=mf_eeg_ica_analyze(EEG, p.sr, p.ica_analyze_set, p.eye_sensitive_channel, p.eye_threhold, p.Seg_Start_Label, p.Seg_End_Label);%p.Trigger_Label_Onset,
    else
        if ~exist('D:\Graduate_study\spacing_JL\preprocess\IC_comp_remove.mat','file')
            load('D:\Graduate_study\spacing_JL\preprocess\IC_analyze_result_set40.mat');
        else
            load('D:\Graduate_study\spacing_JL\preprocess\IC_comp_remove_40.mat');
            %-------------------------------------------------%
            % Re-remove eye_sensitive_component based on IC_comp_remove
            EEG = eeg_checkset( EEG );
            comp_tmp=ic_analyze_result_set{file_cnt,1}.comp_remove;
            comp_cnt=[];
            for i=1:length(comp_tmp)
                idx=cell2mat(comp_tmp(1,i));
                comp_cnt=[comp_cnt str2num(idx)];
            end
            EEG = pop_subcomp( EEG, comp_cnt, 0);
            [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'gui','off');
            eeglab redraw;
            clear comp_tmp comp_cnt
            %-------------------------------------------------%
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if ~exist('D:\Graduate_study\spacing_JL\preprocess\IC_comp_remove.mat')
        %-----------------------------------------------------------%
        disp('----------------------');
        disp('The possible sensitive component(s) is(are):  ')
        disp([num2str(ic_analyze_result_set{file_cnt,1}.eye_sensitive_comp)]);
        disp('----------------------');
        disp('Breakpoint for removing eye-sensitive components');
        disp('----------------------');
        dbstop in breakpoint
        bk=breakpoint(1);
        %-----------------------------------------------------------%
        aa=ALLCOM{1,2};
        comp=regexp(aa,'\d+', 'match'); %find the componet(s) which was/were selected as eye movement;
        comp=comp(1,1:end-1);
        ic_analyze_result_set{file_cnt,1}.comp_remove=comp; 
        IC_remove{file_cnt,1}=comp;clear comp;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
%     %-----------------------------------------------------------%
%     % Reference the data;
%     % We have to reference the biosemi data to increase the SNR; For EGI, scan
%     % and BP data, they have been referred to a channel already.
%     % go after channel selection
%     % average: reref(data);    re-referred to channels  reref(data, [1,2..]);
%     % there is no need to manually stop here, data can be re-referred in processing steps
%     data_r=reref(EEG.data,reref_channels);
%     EEG.data=data_r;
%     clear data_r
%     %     [ALLEEG EEG CURRENTSET LASTCOM] = pop_newset(ALLEEG, EEG, CURRENTSET,'setname',['epoch_rm_bc_reref_' file_name(14:end)]);
%     [ALLEEG EEG CURRENTSET LASTCOM] = pop_newset(ALLEEG, EEG, CURRENTSET,'setname',['epoch_reref_' file_name(14:end)]);
%     eeglab redraw
%     %-----------------------------------------------------------%
%     
%     %-----------------------------------------------------------%
%     % Interpret bad channel
%     tmp=bad_chan{file_cnt,2}(3:end);bad_chan_sub=tmp(~isnan(tmp));tmp=[];
%     if ~isempty(bad_chan_sub)
%         EEG = pop_select(EEG, 'nochannel',bad_chan_sub);
%         EEG = eeg_interp(EEG, ALLEEG(1,CURRENTSET-1).chanlocs(bad_chan_sub));
%         %         [ALLEEG EEG CURRENTSET LASTCOM] = pop_newset(ALLEEG, EEG, CURRENTSET,'setname',['epoch_rm_bc_' file_name(14:end)]);
%         [ALLEEG EEG CURRENTSET LASTCOM] = pop_newset(ALLEEG, EEG, CURRENTSET,'setname',['epoch_reref_bc_' file_name(14:end)]);
%         chan_select_tmp = [setdiff(p.chanind_initial_selected, bad_chan_sub) bad_chan_sub];
%         tmp(chan_select_tmp,:,:)=double(EEG.data);
%         tmp_cha(chan_select_tmp,:,:) = EEG.chanlocs;
%         EEG.data=tmp;
%         EEG.chanlocs=tmp_cha;
%         clear tmp tmp_cha
%         eeglab redraw
%     else
%     end
%     %-----------------------------------------------------------%
%     
%     
%     %-----------------------------------------------------------%
%     % Remove baseline
%     [EEG tmp] = pop_rmbase(EEG,baseline_limits,[]);
%     %     [ALLEEG EEG CURRENTSET LASTCOM] = pop_newset(ALLEEG, EEG, CURRENTSET,'setname',['epoch_rm_' file_name(14:end)]);
%     [ALLEEG EEG CURRENTSET LASTCOM] = pop_newset(ALLEEG, EEG, CURRENTSET,'setname',['epoch_reref_bc_rb' file_name(14:end)]);
%     eeglab redraw
%     clear tmp
%     %-----------------------------------------------------------%
%     
    
    
    ALLEEG=[]; %EEG;
    ALLCOM{1,1}=['ALLEEG EEG CURRENTSET ALLCOM] = eeglab'];
    CURRENTSTUDY=0;
    CURRENTSET=1;
    LASTCOM=[];
    STUDY=[];
    
    save([pwd filesep preprocess_folder filesep 'IC_Remove_40' file_name(end-8:end-4)],'EEG','ALLEEG','ALLCOM','CURRENTSTUDY','CURRENTSET','LASTCOM','STUDY');    
    disp('----------------------');
    disp([file_names{file_cnt,1}(end-8:end-4) ' save done!']);
    disp('----------------------');
    
    % clear all variables (except global EEG, ALLEEG) except ...
%     keep('file_names','preprocess_folder','ic_analyze_result_set','reref_channels','baseline_limits','bad_chan');
    keep('file_names','preprocess_folder','ic_analyze_result_set','bad_chan','IC_remove');

end

% save([pwd filesep 'preprocess' filesep 'IC_comp_remove_40.mat'],'ic_analyze_result_set', 'IC_remove');


