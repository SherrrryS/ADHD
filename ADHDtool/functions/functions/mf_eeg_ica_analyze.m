function [ic_analyze_result]=mf_eeg_ica_analyze(EEG, sr, ica_analyze_set, eye_sensitive_channel, eye_threhold, segment_start_label, segment_end_label)

% this is not open to the user
%------------------------------%
lp_start_eye_removal=0.5;
lp_end_eye_removal=1.5;
hp_start_eye_removal=10;
hp_end_eye_removal=12;
%------------------------------%

if ica_analyze_set==1
    
    if exist('eye_threhold')==0
        eye_threhold=0.75;  % default
    end
    clear eye_sensitive_comp eye_coef eye_sensitive_comp_num
    
%     if size(trigger_label_onset,2)~=0
%         [EEG]=mf_trigger_remove(EEG,trigger_label_onset,1);
%     end
    if iscell(segment_start_label) 
        segment_start_label=str2num(cell2mat(segment_start_label));
        segment_end_label=str2num(cell2mat(segment_end_label)); 
    end
    % the start of the first epoch
    event_start_cnt=1;
    for event_cnt=1:size(EEG.event,2)
        switch EEG.event(1,event_cnt).type
            case segment_start_label
                if event_start_cnt==1
                    % select the second epoch
                    event_start=round(EEG.event(1,event_cnt+1).latency); %% find first exp. trigger
                end
                event_start_cnt=event_start_cnt+1;
        end
    end
    
    event_end_cnt=1;
    for event_cnt=1:size(EEG.event,2)
        switch EEG.event(1,event_cnt).type
            case segment_end_label
                if event_end_cnt==1
                    % select the second epoch
                    event_end=round(EEG.event(1,event_cnt-1).latency);
                end
                event_end_cnt=event_end_cnt+1;
        end
    end    
    
    % segment labels not defined or not sent OR event_triggers not detected
    %-------------------------------------------%
    % OR ALTERNATIVELY
    %start from the 10th event until the end of the last event
    %-------------------------------------------%
%     if size(segment_start_label,2)==0 || size(segment_end_label,2)==0 || exist('segment_start_label')==0 || exist('segment_end_label')==0 || exist('event_start')==0 || exist('event_end')==0 || event_start>=event_end
%         if size(EEG.event,2)~=0
%             if size(EEG.event,2)>=10
%                 event_start_cnt=10; % to avoid the first several test triggers
%                 %             event_end_cnt=size(EEG.event,2);
%             else
%                 event_start_cnt=1; % to avoid the first several test triggers
%                 %             event_end_cnt=size(EEG.event,2);
%             end
%             
%             if size(EEG.event,2)>=25
%                 event_end_cnt=25;
%                 %             event_end=round(EEG.event(1,event_end_cnt).latency);
%             else
%                 event_end_cnt=size(EEG.event,2);
%             end
%             
%             event_start=round(EEG.event(1,event_start_cnt).latency);
%             event_end=round(EEG.event(1,event_end_cnt).latency);
%         else
%             
%             
%             % Or event_end = 2*60*sr+event_start;
%             if size(EEG.data,2)/sr>(3*60+1)  % seconds
%                 event_start=round(1*60*sr);   % 60 seconds
%                 event_end=event_start+round(2*60*sr);
%                 %             event_end=size(EEG.data,2);
%             else
%                 event_start=1;
%                 event_end=size(EEG.data,2);
%             end
%             
%         end
%     end
    
    clear event_start_cnt event_end_cnt event_cnt
    
    eye_signal=EEG.data(eye_sensitive_channel,:);
    source_signal=eeg_getdatact(EEG, 'component', [1:size(EEG.icaweights,1)]);

    eye_sensitive_comp=0;
    eye_signal_f=firfilt_iir(eye_signal, sr, lp_start_eye_removal, lp_end_eye_removal, hp_start_eye_removal, hp_end_eye_removal);  %%%?????
    
    disp('Detecting the eye-sensitive components:');
    tmp_cnt=1;
    for i=1:size(source_signal,1)
        
        if mod(i,15)==0
            fprintf('\n');
        end
        fprintf('.');fprintf('.');fprintf(num2str(i));
        
        source_signal_tmp=source_signal(i,:);
        source_signal_tmp_f=firfilt_iir(source_signal_tmp, sr, lp_start_eye_removal, lp_end_eye_removal, hp_start_eye_removal, hp_end_eye_removal);
        
        eye_coef_tmp=abs(Pearsoncorrcoef(eye_signal_f(1,event_start:event_end),source_signal_tmp_f(1,event_start:event_end)));
        
        if eye_coef_tmp>=eye_threhold            
            eye_sensitive_comp(tmp_cnt,1)=i;
            tmp_cnt=tmp_cnt+1;
        end
        if eye_sensitive_comp==0, eye_sensitive_comp=1; end
        eye_coef(1,i)=eye_coef_tmp;        
        clear eye_coef_tmp
        
    end
    
    fprintf('\n');
% %     if eye_sensitive_comp~=0
    eye_sensitive_comp_num=size(eye_sensitive_comp,1);
    eye_sensitive_comp_data=firfilt_iir(source_signal(eye_sensitive_comp,:), sr, lp_start_eye_removal, lp_end_eye_removal, hp_start_eye_removal, hp_end_eye_removal);
% %     else
% %         eye_sensitive_comp_num=0;
% %         eye_sensitive_comp_data=0;
% %     end
        
    clear source_signal eye_signal eye_signal_f tmp_cnt eye_coef_tmp source_signal_tmp source_signal_tmp_f lp_start_eye_removal lp_end_eye_removal hp_start_eye_removal hp_end_eye_removal
    clear event_start event_end
    disp('----------------------');
    disp('The sensitive components are:  ')
    disp([num2str(eye_sensitive_comp)]);
    disp('----------------------');
    
end

ic_analyze_result.eye_sensitive_comp=eye_sensitive_comp;
ic_analyze_result.eye_coef=eye_coef;
ic_analyze_result.eye_sensitive_comp_num=eye_sensitive_comp_num;
ic_analyze_result.eye_sensitive_comp_data=eye_sensitive_comp_data;

end