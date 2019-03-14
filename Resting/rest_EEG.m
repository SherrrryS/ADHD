% Resting EEG
% Open 1min Close 1min *4 runs
% interval=1s
% rest_EEG for ADHD recording
% modified by Ying Cai, May,2016
trigger_start=1;
trigger_close=2;
trigger_open=3;
trigger_end=4;

blocks=4;
dur_close=60;
dur_open=60;

% connect to EGI
%host
netStationHostName = '10.10.10.42';
%start=GetSecs;
%Connect to Netstation
NetStation('Connect',netStationHostName);

%% sound prepare
InitializePsychSound;
%sound('open');
pause(0.5);
samp = 22254.545454;
aud_stim = sin(1:0.25:1000);
aud_delay = [];
aud_padding = [ zeros(1, round(0.005*samp)) ];	%%% Padding lasts for 5ms
aud_vec = [  aud_delay  aud_padding  aud_stim  0 ];	% Vector fed into SND

%%prepare screen
res=Screen (0,'rect');
xcenter=res(3)/2;
ycenter=res(4)/2;
black=[0 0 0]; white=[1 1 1]*255; gray=[0.5 0.5 0.5]*255;red=[1 0 0]*255; bkGround=gray;
w=Screen(0,'OpenWindow',bkGround,[],32);
HideCursor;
textSize=48;
closescr=Screen(w,'OpenoffscreenWindow');
openscr=Screen(w,'OpenoffscreenWindow');
% Screen(w,'FillRect',bkGround);
% Screen(w,'TextFont','Arial');
% Screen(w,'TextSize',textSize);

% instru={{['Rest']}...
%         {''}...
%         {'two sounds, open eyes                                           '}...
%         {''}...
%         {'one sound, close eyes                                  '}...
%         {''}...
%         };
%
% Screen(w,'TextSize',ceil(textSize/2));
% for i=1:size(instru,2)
%     Screen(w,'DrawText', instru{i}{:}, 100, 100+i*(textSize-10), black);
% end

Screen(w,'FillRect',white);

ins= imread('ins.jpg');
ins1=Screen('MakeTexture',w,ins);

iw=size(ins,2);
ih=size(ins,1);
Screen('DrawTexture',w,ins1,[],[xcenter-iw/3,ycenter-ih/3,xcenter+iw/3,ycenter+ih/3]);

Screen('Flip',w);
KbWait;

%Synchronize
NetStation('Synchronize',w);

WaitSecs(.5);

NetStation('StartRecording');

time1=clock;

NetStation('Event','STAR',GetSecs,0.05,'type',1);

%lptwrite(888,trigger_start);WaitTill(start+0.025);lptwrite(888,0);
% RTBox('TTL',trigger_start);
start=GetSecs;
for block_no=1:blocks
    
    
    WaitTill(start+(block_no-1)*(dur_close+dur_open)+3)
    
    sound(aud_vec,samp)
    WaitSecs(0.5)
    sound(aud_vec,samp)
    
    Screen(w,'FillRect',gray);
    
    open = imread('open.jpg');
    Screen(w,'FillRect',gray);
    img=Screen('MakeTexture',w,open);
    Screen('DrawTexture',w,img,[],[xcenter-iw/4,ycenter-ih/4,xcenter+iw/4,ycenter+ih/4]);
    %Screen(w,'DrawText','+',xcenter,ycenter,red);
    Screen('Flip',w);
    
    NetStation('Event','OPEN',GetSecs,0.05,'block',block_no,'type',3);
    
    
    
    %     lptwrite(55513,trigger_open);
    %     tmpSecs=GetSecs;
    %     WaitTill(tmpSecs+0.025);
    %     lptwrite(55513,0);
    
    WaitSecs(dur_open);
    
    %WaitSecs(1);
    
    sound(aud_vec,samp)
    Screen(w,'FillRect',gray);
    close = imread('close.jpg');
    Screen(w,'FillRect',gray);
    img=Screen('MakeTexture',w,close);
    Screen('DrawTexture',w,img,[],[xcenter-iw/4,ycenter-ih/4,xcenter+iw/4,ycenter+ih/4]);
    %Screen(w,'DrawText','+',xcenter,ycenter,red);
    Screen('Flip',w);
    
    
    NetStation('Event','CLOS',GetSecs,0.05,'block',block_no,'type',4);
    
    
    %     lptwrite(888,trigger_close);
    %     tmpSecs=GetSecs;
    %     WaitTill(tmpSecs+0.025);
    %     lptwrite(888,0);
    %RTBox('TTL',trigger_close);
    WaitSecs(dur_close);
end

%RTBox('TTL',trigger_end);
finish=GetSecs;
time2=clock;
NetStation('Event','ENDS',GetSecs,0.05,'type',2);

NetStation('StopRecording');

%lptwrite(888,trigger_end); tmpSecs=GetSecs;WaitTill(tmpSecs+0.025);lptwrite(888,0);
WaitSecs(1);

NetStation('Disconnect');

Screen('closeall');

