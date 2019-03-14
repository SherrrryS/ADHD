function data_f=mf_eeg_firfilter(EEG,filtering_set,sr,lp_start,lp_end,hp_start,hp_end)

% filtering 
if filtering_set==1
    disp('Filtering EEG data of channel:  ');
    data=EEG.data;  % noise-free data
    for i=1:size(data,1)
        if mod(i,16)==0
            fprintf('\n');
        end
        fprintf('.');fprintf('.');fprintf('.');fprintf(num2str(i));
        data_f(i,:)=firfilt(data(i,:),sr,lp_start,lp_end,hp_start,hp_end);
     %      disp(num2str(i));
     %      disp(' ');
    end
    fprintf('\n');
    clear data 
    disp('----------------------');
    disp('Filtering done');
    disp('----------------------'); 
else
    data_f=EEG.data;    
end

end
