% mf_downsample
% for Gene_EEG datdasets
sr=p.sr;
if p.downsample_set==1
    setname_sr=['rs_',file_name];
    [EEG LASTCOM] = eeg_checkset(EEG, 'data');
    if ~isempty(LASTCOM)
        if LASTCOM(1) == -1, LASTCOM = ''; return; end; 
    end; 
    eegh(LASTCOM);
    try
        [EEG LASTCOM] = pop_resample(EEG,sr);
    catch
        eeglab_error; LASTCOM= ''; clear EEGTMP ALLEEGTMP STUDYTMP
    end;
    EEG = eegh(LASTCOM, EEG);
    if exist('EEGTMP','var') == 1, 
        EEG = EEGTMP; clear EEGTMP; 
    end
    if ~isempty(LASTCOM) && ~isempty(EEG)
        [ALLEEG EEG CURRENTSET LASTCOM] = pop_newset(ALLEEG, EEG, CURRENTSET,'setname',setname_sr, 'study', ~isempty(STUDY)+0); 
        eegh(LASTCOM);disp('Done.')
    end
    eeglab('redraw')
end
% % % clear dataset (optional)
% % % clear unused dataset to save memory (such as the original dataset with 500hz )
% % % go with change sr
% 
% if p.downsample_set==1
%     dataset_clear=1;  % usually the first loaded file (sr=500)
%     try
%         [ALLEEG LASTCOM] = pop_delset(ALLEEG, dataset_clear);
%     catch
%         eeglab_error; LASTCOM= ''; clear EEGTMP ALLEEGTMP STUDYTMP
%     end;
%     eegh(LASTCOM);
%     eeglab redraw;
% end

clear dataset_clear
clear sr
disp('----------------------');
disp('Downsample done');
disp('----------------------');