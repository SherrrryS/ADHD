% For Gene Data, 2015,1,26
function mf_file_names_parse(file_type,input_folder,output_folder)

file_dir=dir(input_folder);
file_num=size(file_dir,1)-2;
file_num_cnt=1;
for file_cnt=1:file_num
    file_tmp=file_dir(file_cnt+2,1).name;
    if (file_dir(file_cnt+2,1).isdir==0) && (size(file_tmp,2)>size(file_type,2)) % or >=
        %if strcmp(file_tmp(1,(size(file_tmp,2)-(size(file_type,2)-1):size(file_tmp,2))),file_type)==1  % for '.set' extremely important
            file_names{file_num_cnt,1}=file_tmp;
            file_num_cnt=file_num_cnt+1;
        %end
    end
end
file_num=file_num_cnt-1;
save([pwd '\' output_folder '\file_names.mat'], 'file_names','file_num');
end