% function mf_proc_eeg_import(folder_path,hdrfile,Data_Format_Device_Set,chanind_initial_selected)
% not a function but a macro

% for biosemi data, readbdf is better than biosig, the first and last events will not be missed
% normally, [EEG, LASTCOM,dat] = pop_biosig([folder_path '\'hdrfile]); else for extreme large data, use the following batch.
% % not recommended, but can load parts of the channels to speed up the
% loading process
try
    chanind_initial_selected=p.chanind_initial_selected;
end

switch p.Data_Format_Device
    case {'biosemi','Biosemi','BIOSEMI','bio','b'}
        if exist('chanind_initial_selected')==0
            try,[EEG, LASTCOM,dat] = pop_biosig([folder_path '\'  hdrfile]);catch, eeglab_error; LASTCOM= ''; clear EEGTMP ALLEEGTMP STUDYTMP; end;EEG = eegh(LASTCOM, EEG);if exist('EEGTMP') == 1, EEG = EEGTMP; clear EEGTMP; end;if ~isempty(LASTCOM) & ~isempty(EEG),[ALLEEG EEG CURRENTSET LASTCOM] = pop_newset(ALLEEG, EEG, CURRENTSET, 'setname',setfilename, 'study', ~isempty(STUDY)+0); eegh(LASTCOM);disp('Done.'); end; eeglab('redraw');
        else
            try,[EEG, LASTCOM,dat] = pop_biosig([folder_path '\'  hdrfile],'channels',p.chanind_initial_selected);catch, eeglab_error; LASTCOM= ''; clear EEGTMP ALLEEGTMP STUDYTMP; end;EEG = eegh(LASTCOM, EEG);if exist('EEGTMP') == 1, EEG = EEGTMP; clear EEGTMP; end;if ~isempty(LASTCOM) & ~isempty(EEG),[ALLEEG EEG CURRENTSET LASTCOM] = pop_newset(ALLEEG, EEG, CURRENTSET, 'setname',setfilename, 'study', ~isempty(STUDY)+0); eegh(LASTCOM);disp('Done.'); end; eeglab('redraw');
        end
%         try,[EEG, LASTCOM,dat] = pop_biosig([folder_path '\'  hdrfile],'channels',chanind_initial_selected);catch, eeglab_error; LASTCOM= ''; clear EEGTMP ALLEEGTMP STUDYTMP; end;EEG = eegh(LASTCOM, EEG);if exist('EEGTMP') == 1, EEG = EEGTMP; clear EEGTMP; end;if ~isempty(LASTCOM) & ~isempty(EEG),[ALLEEG EEG CURRENTSET LASTCOM] = pop_newset(ALLEEG, EEG, CURRENTSET, 'setname',setfilename, 'study', ~isempty(STUDY)+0); eegh(LASTCOM);disp('Done.'); end; eeglab('redraw');
%-----------------------------------------------------%
    case {'egi','EGI','e'}
        try,[EEG, LASTCOM] = pop_readegi([folder_path '\'  hdrfile]);catch, eeglab_error; LASTCOM= ''; clear EEGTMP ALLEEGTMP STUDYTMP; end;EEG = eegh(LASTCOM, EEG);if exist('EEGTMP') == 1, EEG = EEGTMP; clear EEGTMP; end;if ~isempty(LASTCOM) & ~isempty(EEG),[ALLEEG EEG CURRENTSET LASTCOM] = pop_newset(ALLEEG, EEG, CURRENTSET, 'setname',setfilename, 'study', ~isempty(STUDY)+0); eegh(LASTCOM);disp('Done.'); end; eeglab('redraw');
% % recommended to import .cnt data
% % if you need the keystroke, add ,'keystroke','off'
    case {'scan','neuroscan','Neuroscan','NEUROSCAN','n'}
        try,[EEG, LASTCOM] = pop_loadcnt([folder_path '\'  hdrfile],'dataformat', 'int16');catch, eeglab_error; LASTCOM= ''; clear EEGTMP ALLEEGTMP STUDYTMP; end;EEG = eegh(LASTCOM, EEG);if exist('EEGTMP') == 1, EEG = EEGTMP; clear EEGTMP; end;if ~isempty(LASTCOM) & ~isempty(EEG),[ALLEEG EEG CURRENTSET LASTCOM] = pop_newset(ALLEEG, EEG, CURRENTSET, 'setname',setfilename, 'study', ~isempty(STUDY)+0); eegh(LASTCOM);disp('Done.'); end; eeglab('redraw');

    case {'BP','bp','BrainProducts','BRAINPRODUCTS','brainproducts','p'}
        try,[EEG LASTCOM] = pop_loadbv(path, hdrfile);catch, eeglab_error; LASTCOM= ''; clear EEGTMP ALLEEGTMP STUDYTMP; end;EEG = eegh(LASTCOM, EEG);if exist('EEGTMP') == 1, EEG = EEGTMP; clear EEGTMP; end;if ~isempty(LASTCOM) & ~isempty(EEG),[ALLEEG EEG CURRENTSET LASTCOM] = pop_newset(ALLEEG, EEG, CURRENTSET, 'setname',setfilename, 'study', ~isempty(STUDY)+0); eegh(LASTCOM);disp('Done.'); end; eeglab('redraw');
    
    case {'set','eeglab','EEGLAB','SET','s'}

% clear dat
%-----------------------------------------------------%
% % to load the saved eeglab .set files
        try,[EEG, LASTCOM] = pop_loadset([folder_path '\'  hdrfile]);catch, eeglab_error; LASTCOM= ''; clear EEGTMP ALLEEGTMP STUDYTMP; end;EEG = eegh(LASTCOM, EEG);if exist('EEGTMP') == 1, EEG = EEGTMP; clear EEGTMP; end;if ~isempty(LASTCOM) & ~isempty(EEG),[ALLEEG EEG CURRENTSET LASTCOM] = pop_newset(ALLEEG, EEG, CURRENTSET, 'setname',setfilename, 'study', ~isempty(STUDY)+0); eegh(LASTCOM);disp('Done.'); end; eeglab('redraw');
        
    otherwise
        error('You should load an EEG file!');
end
clear dat


% end