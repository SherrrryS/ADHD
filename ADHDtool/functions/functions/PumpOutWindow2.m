%PumpOutWindow2
%Get epoch parameters
%By Siyao 20150129

c=clock;

prompt={'Trigger of interest','Baseline (in ms)','Epoch start (in ms)','Epoch end (in ms)','Rereference channels'};
name='Input for answer';
numlines=1;
defaultanswer={'','-200','-500','1500',''};
answer=inputdlg(prompt,name,numlines,defaultanswer);

response=str2double(answer);
% events_select_input=mod(answer{1,1},16)*16+15; % if use RTbox
events_select_input=[1:192]; %answer{1,1};  % if use keyboard
baseline=response(2);
epochs=response(3);
epoche=response(4);
reref_channels=answer{5,1};

epoch_limits=[(epochs/1000), epoche/1000];
chan_select=p.chanind_ica;
for ii = 1:length(events_select_input)
    events_select{ii} = num2str(events_select_input(ii));
end
% baseline_limits = [(roundn((1/p.sr*baseline),-3)-baseline),0];
baseline_limits=[baseline 0];

param_name2=sprintf('Param2_Spacing_RSA_%s_%s_%02.0f-%02.0f',taskname,date,c(4),c(5));
save([pwd '\param\' param_name2 '.mat']);
    
    
    