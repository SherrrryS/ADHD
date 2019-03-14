%PumpOutWindow1
%Get innitial parameters
%By Siyao 20150129
load([pwd '\param\Param_Spacing_RSA'])
c=clock;

prompt={'Task name','Down sampling rate','Low-pass filter start','Low-pass filter end','High-pass filter start','High-pass filter end','Trigger Removed','Task Start Trigger','Task End Trigger'};
    name='Input for answer';
    numlines=1;
    defaultanswer={'S','512','0.1','0.5','29.8','30.2','0','241','246'};
    answer=inputdlg(prompt,name,numlines,defaultanswer);
    response=str2double(answer);    
    taskname=answer{1};
    
    p.sr=response(2);
    p.lp_start=response(3);
    p.lp_end=response(4);
    p.hp_start=response(5);
    p.hp_end=response(6);
% %     p.Trigger_Removed=mat2cell((mod(str2double(answer(7)),16)*16+15),1,ones(length(answer(7)),1)); %RTbox
% %     p.Seg_Start_Label=mat2cell((mod(str2double(answer(8)),16)*16+15),1,ones(length(answer(8)),1)); %RTbox
% %     p.Seg_End_Label=mat2cell((mod(str2double(answer(9)),16)*16+15),1,ones(length(answer(9)),1)); %RTbox
    p.Trigger_Removed=answer(7); %keyboard
    p.Seg_Start_Label=answer(8); %keyboard
    p.Seg_End_Label=answer(9); %keyboard
    
    param_name=sprintf('Param_Spacing_RSA_%s_%s_%02.0f-%02.0f',taskname,date,c(4),c(5));

    save([pwd '\param\' param_name '.mat']);

    
    