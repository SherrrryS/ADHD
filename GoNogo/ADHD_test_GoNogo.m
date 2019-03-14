% Go Nogo task for training program for ADHD.
% Go: badwolf, 75%; No-go:sheep 25%
% each trial: 3s= 0.5s +2.5s ISI(from 2.1~2.9)
% 3 runs, 80 trails per run
% Created by syx,20160523


%% 
%modified by Zifang
%each trial: 3s = 0.5 + 2.5s  ISI(2.1-2.9)
%3 runs, 80 trilas per run
%the columns of VWM:
%1=ID( the sequence number of trial), 
%2=type (go:2-badwolf;nogo:1-sheep),
%3=onset
%4= actual onset
%5=response key, 6=RT<=500 (tap the keyboard during the peorid of stimulus presentation)
%7=correct (make a judgment, feedback)
%8=key, 9= RT (tap the key for the second time or tap the key in the following secs)


%% Preparing
warning('off');
close all;
clear all;
clc;

folder = fileparts(mfilename('fullpath'));
load seq_test
load onset

% connect to EGI
%host
netStationHostName = '10.10.10.42'; %cheack whether IP is right.
%start=GetSecs;
%Connect to Netstation
NetStation('Connect',netStationHostName);


%% Subject informatiomn
try
    prompt={'Enter subject code:','Which RUN(1-3) ?','Which TYPE(1-3)?'};
    name='Input for experimental information';
    numlines=1;
    defaultanswer={'99','1','1'};
    answer=inputdlg(prompt,name,numlines,defaultanswer);
    subjectID=str2double(answer{1});
    run=str2double(answer{2});
    block=str2double(answer{3});
catch
    sprintf('error! input the parameters again!')
end

% response key
key_go={'4'};
other_key={'1','2','3','4'};


%% create results file
mkdir('.','results');
c=clock;
d=date;
tmp_file=sprintf('sub%03d_ADHD_test_block%d_run%d_%s_%02.0f-%02.0f',subjectID,block,run,d(1:6),c(4),c(5));
outfile=fullfile(folder,'results',tmp_file);


% generate sequence for storing the results in a single mat file
MID=1; %trial No.
Mtype=2; %go:2, badwolf; nogo:1, sheep
Monset=3; %designed onset time
Maonset=4; %actual study onset
Mresp=5; %response key press;
Mrt=6; %reaction time=key press- actual probe onset
Mcorrect=7;%response is right or wrong.
order=randperm(9);

VWM(:,MID)=1:80;
VWM(:,Mtype)=seq_final(:,order(1,1));
VWM(:,Monset)=onset([1:80],:);

% %define trigger
trigger_start=1;
trigger_end=2;
trigger_nogo_onset=3;
trigger_nogo_resp_wrong=4;
trigger_go_onset=5;
trigger_go_resp_right=6;

%% prepare Screen
%RTBox('ClockRatio');

%Screen('Preference', 'SkipSyncTests', 1)
pixelSize = 32; % You might change to 8 if 32 not working, depending on Mac or Windows.
%dos('FlipSS /off'); % To disable screensaver temporally.
sca;
s=max(Screen('Screens'));
black=BlackIndex(s); white=WhiteIndex(s); gray=GrayIndex(s); bkGround=black; % mean luminance
[win, ScreenRect]=Screen('OpenWindow', s, bkGround,[], pixelSize,2);

[width, height] = Screen('DisplaySize', win);
[screenXpixels, screenYpixels] = Screen('WindowSize', win);

HideCursor;
HZ=FrameRate(win);
%Priority(MaxPriority(win));
% set up Screen positions for stimuli
xcenter=ScreenRect(3)/2;
ycenter=ScreenRect(4)/2;
textSize=round(48/1024*ScreenRect(3)/2)*2;
%theFont='Arial';
% theFont='Times New Roman';
% Screen(win,'TextFont',theFont);


% %press to start(s)
% WaitTrigger;

%% Instruction Screen
%FlushEvents('keyDown');	 % clear any keypresses out of the buffer ??????????
%Screen(win,'TextSize',40);
baselinepos=1;

Screen(win,'FillRect',white);

ins= imread('ins.jpg');
ins1=Screen('MakeTexture',win,ins);

iw=size(ins,2);
ih=size(ins,1);
Screen('DrawTexture',win,ins1,[],[xcenter-iw/3,ycenter-ih/3,xcenter+iw/3,ycenter+ih/3]);
Screen('Flip',win);

keys='s';
WaitTill(keys);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Start trigger

%lptwrite(888,trigger_start);WaitTill(start+0.025);lptwrite(888,0);

%Synchronize
     NetStation('Synchronize',win);

     WaitSecs(.5);

     NetStation('StartRecording');

     time1=clock;

     NetStation('Event','STAR',GetSecs,0.05,'idx',1);

%WaitSecs(3);
start=GetSecs;

%% experiment
try
for i=1:80
    type=VWM(i,Mtype);
    % present the
    if type==2
        go_trial = imread('badwolf.jpg');
        Screen(win,'FillRect',gray);
        img=Screen('MakeTexture',win,go_trial);
        Screen('DrawTexture',win,img,[],[xcenter-iw/4,ycenter-ih/4,xcenter+iw/4,ycenter+ih/4]);
        WaitTill(VWM(i,Monset)+start);
        Screen('Flip',win);
        VWM(i,Maonset)=GetSecs-start;
        
        NetStation('Event','GO',GetSecs,0.05,'run',run,'idx',5);
        
        %             lptwrite(888,trigger_go_onset);
        tmpSecs=GetSecs;
        %             WaitTill(tmpSecs+0.025);
        %             lptwrite(888,0);
        
    else
        nogo_trial = imread('sheep.jpg');
        Screen(win,'FillRect',gray);
        img=Screen('MakeTexture',win,nogo_trial);
        Screen('DrawTexture',win,img,[],[xcenter-iw/4,ycenter-ih/4,xcenter+iw/4,ycenter+ih/4]);
        WaitTill(VWM(i,Monset)+start);
        Screen('Flip',win);
        VWM(i,Maonset)=GetSecs-start;
        
        
        NetStation('Event','NG',GetSecs,0.05,'run',run,'idx',3);
        
        %             lptwrite(888,trigger_nogo_onset);
        tmpSecs=GetSecs;
        %             WaitTill(tmpSecs+0.025);
        %             lptwrite(888,0);
        
        
    end
    
    %    WaitSecs(0.4);
    
    
    %%%% detect response
    t=[];
    key=[];
    [key,t] = WaitTill(other_key,tmpSecs+0.5);
    RT_tmp=t-tmpSecs;
    if isempty(key)
        key = char(48);
    end
    VWM(i,Mresp)=key-48;
    VWM(i,Mrt) = RT_tmp;
    
    
    if VWM(i,Mtype)==2
        if  VWM(i,Mresp)==4
            ok=1;
            NetStation('Event','GORE',GetSecs,0.05,'run',run,'idx',6);
        else 
            ok=0;
        end
    end
    
    if VWM(i,Mtype)==1
        if  VWM(i,Mresp)==0
            ok=1;
 %           NetStation('Event','NGRE',GetSecs,0.05,'run',run,'idx',4);
        else 
            ok=0;
            NetStation('Event','NGRE',GetSecs,0.05,'run',run,'idx',4);
        end
    end
    VWM(i,Mcorrect)=ok(1,1);
    

    
    Screen(win,'FillRect',gray);
    Screen('Flip',win);
    
    key_later=[];
    t_later=[];
    [key_later,t_later] = WaitTill(other_key,VWM(i+1,Monset)+start);
    RT_latertmp=t_later-tmpSecs;
    if isempty(key_later)
        key_later = char(48);
    end
    VWM(i,Mresp+3)=key_later-48;
    VWM(i,Mrt+3) = RT_latertmp;
    
    %    WaitTill(onset(i+1,1));%
end
catch
    c=clock;
    d=date;
    outfile=fullfile('results', sprintf('tmp_ADHD_GoNogo_EGI_sub%03d_block%d_run%02d_%s_%02.0f-%02.0f',subjectID,block,run,date,c(4),c(5)));
    save(outfile, 'VWM');
end


finish=GetSecs;
time2=clock;
NetStation('Event','ENDS',GetSecs,0.05,'idx',2);
NetStation('StopRecording');

%lptwrite(888,trigger_end); tmpSecs=GetSecs;WaitTill(tmpSecs+0.025);lptwrite(888,0);
WaitSecs(1);

NetStation('Disconnect');

%lptwrite(888,trigger_end);tmpSecs=GetSecs;WaitTill(tmpSecs+0.025);lptwrite(888,0);
% p.finish=RTBox('TTL',trigger_end);
Screen('CloseAll');
Priority(0);
%ShowCursor;

fprintf('-------------------------------\n');
fprintf('Accuracy in this run: %5.1f%\n', mean(VWM(:,7))*100);
%% Save run results
c=clock;
d=date;
outfile=fullfile('results',sprintf('ADHD_GoNogo_EGI_sub%03d_block%d_run%02d_%s_%02.0f-%02.0f',subjectID,block,run,date,c(4),c(5)));
save(outfile, 'VWM');


% catch
%     fprintf('%s',lasterr);
%     sca
% end










