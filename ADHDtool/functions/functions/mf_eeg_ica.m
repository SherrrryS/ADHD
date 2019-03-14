% mf_eeg_ica: decompose  (ica2 back projection)

% default using all the EEG channels
chanind_ica=p.chanind_ica;

%================================%
idx_remove=[];
for i=1:size(bad_chan_sub,2)
    idx_remove=[idx_remove find(chanind_ica==bad_chan_sub(1,i))];
    %     bd_ch_idx=find(chanind_ica==bad_chan_sub(1,i));
    %     if size(bd_ch_idx)~=0
    %         idx_remove=[idx_remove bd_ch_idx];
end
clear i
chanind_ica(idx_remove)=[];
clear idx_remove
%================================%

pca_set=p.pca_set;
pca_num=p.pca_num;


if p.ica_set==1
    
    ica_chan_selection_tmp='ICA_channels: ';
    disp([num2str(size(chanind_ica,2)) ' channels selected for ICA!']);
    
    for i=1:size(chanind_ica,2)
        if mod(i,12)==0
            fprintf('\n');
        end
        fprintf('.');fprintf('.');fprintf('.');fprintf(EEG.chanlocs(1,chanind_ica(i)).labels);        
    end

    
    chan_num=size(EEG.data,1);
    chan_select_num=size(chanind_ica,2);
    
    for chan_cnt=1:chan_num
        search_tmp=find(chanind_ica==chan_cnt);
        if size(search_tmp,2)~=0
            chan_unselected(chan_cnt,1)=1;
        else
            chan_unselected(chan_cnt,1)=0;
        end
    end
    
    chan_unselected_index=find(chan_unselected==0);
    
    if size(chan_unselected_index,1)~=0
        disp('Channels for ICA unselected: ')
        for i=1:size(chan_unselected_index,1)
            fprintf('Channnel: ');fprintf(num2str(i));fprintf('.');fprintf('.');fprintf(EEG.chanlocs(1,chan_unselected_index(i)).labels);fprintf('\n');            
        end
    else
        disp('All channels unselected! ');
    end
    
    clear chan_num chan_select_num chan_cnt chan_unselected search_tmp chan_unselected_index i
    
    if exist('pca_num')==0
        pca_num=20;  % default
    end

    if pca_set~=1
        [EEG LASTCOM] = eeg_checkset(EEG, 'data');if ~isempty(LASTCOM), if LASTCOM(1) == -1, LASTCOM = ''; return; end; end; eegh(LASTCOM);try,[EEG LASTCOM] = pop_runica(EEG, 'icatype','runica','chanind',chanind_ica);catch, eeglab_error; LASTCOM= ''; clear EEGTMP ALLEEGTMP STUDYTMP; end;EEG = eegh(LASTCOM, EEG);if ~isempty(LASTCOM) & ~isempty(EEG) & ~isempty(findstr('=',LASTCOM)),[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET); eegh('[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);');disp('Done.'); end; eeglab('redraw');
    else
        [EEG LASTCOM] = eeg_checkset(EEG, 'data');if ~isempty(LASTCOM), if LASTCOM(1) == -1, LASTCOM = ''; return; end; end; eegh(LASTCOM);try,[EEG LASTCOM] = pop_runica(EEG, 'icatype','runica','chanind',chanind_ica,'pca', pca_num);catch, eeglab_error; LASTCOM= ''; clear EEGTMP ALLEEGTMP STUDYTMP; end;EEG = eegh(LASTCOM, EEG);if ~isempty(LASTCOM) & ~isempty(EEG) & ~isempty(findstr('=',LASTCOM)),[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET); eegh('[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);');disp('Done.'); end; eeglab('redraw');
    end
    
    ALLEEG(1,CURRENTSET)=EEG;
    
    disp('----------------------');
    disp('ICA done');
    disp('----------------------');
    
end

clear chanind_ica ica_chan_selection_tmp
clear pca_num pca_set