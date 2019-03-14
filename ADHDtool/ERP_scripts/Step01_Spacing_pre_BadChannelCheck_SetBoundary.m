%% Process pipeline
%---Aim: These serials of scripts were used for processing EEG signals to get CLEAN single trial EEG;
% Step01: down sampling and find intial bad channel
% Step02: filtering£¬epoch£¬run ICA
% Step03: Rejction artifact components
% Step04: bad channel rejection and interpolation;
%         reference and remove baseline;
%         bad trial rejection;
%---Modified by JingLiu, 2016/4/20;

% ===================== Step01 [manual] ========================= %  
%Input process parameters, down-sampling, Trigger replacement

clear all
addpath([pwd '\param']);
addpath([pwd '\functions']);

%% ==========Input process parameters==========

PumpOutWindow1

%--------------------------------------------------------------%
% generate the task-related file name list under DATA folder
mkdir('.',preprocess_folder)
file_name_tmp = dir([folder '\' taskname '*.bdf']);
file_num = length(file_name_tmp);
for ii = 1:file_num
    file_names{ii,1} = file_name_tmp(ii).name;
end
save([pwd '\' folder '\file_names0'],'file_names')
%---------------------------------------------------------------%

%---------------------------------------------------------------%
% generate innitial bad channel matrix
bad_chan(:,1)=file_names;
bad_chan(:,2)=mat2cell([65 66]);  %remove reference automatically
save([pwd '\param\Step0_param60.mat'],'bad_chan','chaninfo','chanlocs','folder','p','param_folder','param_name','preprocess_folder','taskname');
%---------------------------------------------------------------%


%% =======Run check loop to write down bad channels and set boundary=======

% preprocess steps subject by subjct:
for file_cnt=1:file_num
    load([pwd '\' param_folder '\' param_name]);  % P.xx
    clear bad_chan_sub
    try bad_chan_sub=bad_chan{file_cnt,2};  catch    bad_chan_sub=[];   end
    
    file_name=file_names{file_cnt,1};
    
    setfilename=file_name;
%     clear data data_refer data_f
%     clear ALLEEG STUDY CURRENTSTUDY CURRENTSET EEG LASTCOM ALLCOM
    eeglab
    
    %-----------------------------------------------------------%
    % load the EEG data (biosemi)
    hdrfile=[file_name]; %'2011071301.vhdr';
    folder_path=[pwd '\' folder];    
    mf_eeg_import    % need: folder_path,hdrfile,p.data_format_device,p.chanind_initial_selected
    %-----------------------------------------------------------%
        
    EEG.chanlocs=chanlocs;
    EEG.chaninfo=chaninfo;
    ALLEEG(1,CURRENTSET)=EEG;
    
    %-----------------------------------------------------------%
    % Downsampling
    mf_eeg_downsample
    %-----------------------------------------------------------%
    %filtering
    
% %  %-----------------------------------------------------------%
% %     % check stimulus trigger, needed when RTbox was used
% %     for i=1:size(EEG.event,2),events(i)=EEG.event(i).type;end
% %     events_cnt=[];
% %     for i=1:length(p.Stimulus_Label),events_cnt=[events_cnt find(events==p.Stimulus_Label(i))];end
% %     if p.Stimulus_cnt==length(events_cnt)
% %         disp('----------------------');
% %         disp('Stimulus trigger checked, go on...');
% %         disp('----------------------');
% %     else
% %         disp('----------------------');
% %         disp('Lack of Stimulus trigger');
% %         disp('----------------------');
% %     end
% %     %-----------------------------------------------------------%
        
    
     
    %-----------------------------------------------------------%
    %Trigger replacement, especially for spacing_RSA experiment
    file=file_name(1:end-4);
    load([pwd '\' folder '\Trigger_replacement\' file '_Trigger.mat']);
    x=length(Trigger)/3; k=0;
    for i = 1:length(EEG.event)
        if EEG.event(i).type<200 & EEG.event(i).type>0;
            if EEG.event(i).type==1, k=k+1;end
            idx=find(Trigger(((k-1)*x+1):(k*x),1)==EEG.event(i).type);
            EEG.event(i).type=Trigger(idx+(k-1)*x,3);
        end
    end
    ALLEEG(1,CURRENTSET).event=EEG.event;
    eeglab redraw
    %-----------------------------------------------------------%    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %-----------------------------------------------------------%
    if isempty(dir(sprintf('preprocess\''rj_bad_period%4s.mat',file_name(1:4))))
        disp('----------------------');
        disp('Stop here and reject bad period!');
        dbstop in breakpoint
        bk=breakpoint(1);
%         dbstep
%         dbquit
        disp('----------------------');
%             bk=breakpoint(0);
%             dbstep
%             dbquit
    end
    %-----------------------------------------------------------%    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
    
    %-----------------------------------------------------------%
    % remove useless boundary triggers
    [EEG]=mf_trigger_removebdn(EEG,1);  %removed_idx_disp=1=> disp, 0=> not disp detection results
    ALLEEG(1,CURRENTSET).event=EEG.event;    
    %-----------------------------------------------------------%
   
    
    
    ALLEEG=[]; %EEG;
    ALLCOM{1,1}=['ALLEEG EEG CURRENTSET ALLCOM] = eeglab'];
    CURRENTSTUDY=0;
    CURRENTSET=1;
    LASTCOM=[];
    STUDY=[];
    
    save([pwd '\' preprocess_folder '\' 'rj_bad_period60_' file_name(1:end-4) '.mat'],'EEG','ALLEEG','ALLCOM','CURRENTSTUDY','CURRENTSET','LASTCOM','STUDY');  % save every thing

    disp('----------------------');
    disp('Save done');
    disp('----------------------');    
    
    % clear all variables (except global EEG, ALLEEG) except ...
    keep('preprocess_folder','file_names','file_cnt','file_num','bad_chan','param_folder','param_name','ic_analyze_result_set'); %,'event_erp_update_set');

end


