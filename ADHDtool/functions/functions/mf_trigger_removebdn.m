function [EEG]=mf_trigger_removebdn(EEG,removed_idx_disp)
% remove unnecessary events to match event numbers
% e.g. 'epoc' 'boundary' 65535


if exist('removed_idx_disp')==0
    removed_idx_disp=0;
end
%     trigger_label_boundary = {'boundary',65535};    % can be others
%     trigger_label_num
event_tmp=[];
%     for trg_cnt=1:size(trigger_label,2)

for event_cnt=1:size(EEG.event,2)
    if strcmpi(EEG.event(1,event_cnt).type,'boundary')
        event_tmp=[event_tmp event_cnt];
    end
end
%     end
%     for event_cnt=1:size(EEG.event,2)     % 65535 only happen at the first trigger
%         if (isstr(EEG.event(1,event_cnt).type)==1 && strcmp(EEG.event(1,event_cnt).type,num2str(trigger_label_high))) || (isstr(EEG.event(1,event_cnt).type)==0 && EEG.event(1,event_cnt).type==trigger_label_high)
%                 event_tmp=[event_tmp event_cnt];
%         end
%     end


%     event_tmp=[];
%     for event_cnt=1:2  % 0(65280) only happen at the first two positions
%         if (isstr(EEG.event(1,event_cnt).type)==1 && strcmp(EEG.event(1,event_cnt).type,num2str(trigger_label_low))) || (isstr(EEG.event(1,event_cnt).type)==0 && EEG.event(1,event_cnt).type==trigger_label_low)
%                 event_tmp=[event_tmp event_cnt];
%         end
%     end
%     EEG.event(event_tmp)=[];
%     clear event_tmp event_cnt
%     ALLEEG(1,CURRENTSET).event=EEG.event;
% end
event_tmp=sort(event_tmp);
if isempty(event_tmp)==1
    if removed_idx_disp==1
        disp('No triggers removed');
    end
else
    if removed_idx_disp==1
        disp(['Triggers removed:' num2str(event_tmp)]);
    end
    
    %==================%
    % global
    
    EEG.event(event_tmp)=[];
    for event_cnt=1:size(EEG.event,2)
        if ischar(EEG.event(1,event_cnt).type)
            EEG.event(1,event_cnt).type=str2num(EEG.event(1,event_cnt).type);
        end
    end
    %         ALLEEG(1,CURRENTSET).event=EEG.event;
    %==================%
end

clear event_tmp event_cnt
end