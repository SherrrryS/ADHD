% 2015.03.31
% change detection
% setSize = [2 4]; stimulusduration=0.1;retentionduration=0.9;
% testduration=2;
% nBlocks = 4 (1_practice;2-4_test)
% variable: p.nTarget(row 35);pracTrialsPerSetSize(row49);TrialsPerSetSize(row50);

%2016.1.14

% connect to EGI
% %host
netStationHostName = '10.10.10.42';%syx
% %start=GetSecs;
% %Connect to Netstation
NetStation('Connect',netStationHostName);%syx


clear,clc;

%% Subject informatiomn
try
    prompt={'Enter subject code:','Which RUN(1-4) ?','Which TYPE(1-3)?'};
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

if mod(subjectID,2)
    p.keys={'1','4'};%4_different;1_same
else
    p.keys={'4','1'};%1_different;4_same
end
upKey=upper(p.keys);

filedir=fileparts(mfilename('fullpath'));
%
% %define trigger
trigger_start=1;%syx
trigger_end=2;%syx

trigger_ss22=22; %load 2 with distractor
trigger_ss2=20;%syx
trigger_ss4=40;%syx
% trigger_ss42=42;%load 4 with distractor
%
%
trigger_ss22_probe=23; %load 2 with distractor
trigger_ss2_probe=21;%syx
trigger_ss4_probe=41;%syx
% trigger_ss42_probe=43; %load 4 with distractor
%
%
trigger_resp_right=3;%syx
trigger_resp_wrong=4;%syx



%%%% define stimuli parameter
p.nTarget = [2 4 3];
p.ISI = 1;
p.cueDur = 0.2;
p.stimDur = 0.1;
p.retentionDur = 0.9;
p.testDur = 2;
p.fixLen = 11;
p.width = 16; % smaller dim of rectangle. The other is 4x
ht = p.width * 5;
rg = ht*4; % disp range
nTarget=numel(p.nTarget);


epoch=60;%collect 60 epochs for each condition
prac_epoch=4;
nBlock=3;
if run==1
    nTrial = nTarget*prac_epoch;% Practice: 3 trials per setSize, 12 trials in total
else
    %     p.randseed = ClockRandSeed(6);
    nTrial = nTarget*epoch/nBlock;% Test: 90 trials per setSize; 3 Blocks 90*3/3=90
end



%% rec information

p.recLabel = {'iTrial' 'rotated' 'nTarget' 'nDistractor' 'keyPressed' 'respCorrect' 'RT' 'ActualOnset'};
rec = nan(nTrial, length(p.recLabel));
rec(:,1) = 1:nTrial;
rec(1:nTrial,2) = repmat(0:1, 1, nTrial/2);
foo = repmat(p.nTarget, nTrial/nTarget, 1);
[foo, ind] = Shuffle(foo(:));
rec(1:nTrial,3) = foo;%random setSize
rec(1:nTrial,2) = rec(ind,2);

for i=1:nTrial
    if mod(rec(i,3),2)==1
        rec(i,4)=2;
    else
        rec(i,4)=0;
    end
end



%% prepare screen
s=max(Screen('Screens'));
black=BlackIndex(s); white=WhiteIndex(s); gray=GrayIndex(s); bkGround=gray; % mean luminance
pixelSize = 32;
[w, ScreenRect]=Screen('OpenWindow', s, bkGround,[], pixelSize,2);
xcenter=ScreenRect(3)/2;
ycenter=ScreenRect(4)/2;
Screen('BlendFunction', w, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
ct = 'center';
rect=Screen (0,'rect');
xy = [[[-1 1]*p.fixLen 0 0]+rect(3)/2; [0 0 [-1 1]*p.fixLen]+rect(4)/2];% fixation position

%% Instruction screen
HideCursor;
Priority(MaxPriority(w));
%define bars of the piture
ind = round([3 5]/8 * ht); ind = ind(1):ind(2);
% distractor:blue
img = ones(ht, ht, 4)*255;
img(:,:,4) = 0;
img(:,ind,1:2) = 0; img(:, ind, [3,4]) = 255; % blue
tex(2) = Screen('MakeTexture', w, img);
% target:red
img = ones(ht, ht, 4)*255;
img(:,:,4) = 0;
img(:,ind,[2,3]) = 0; img(:, ind, [1,4]) = 255; % red
tex(1) = Screen('MakeTexture', w, img);
% % non-probed items:gray
% img = ones(ht, ht, 4)*255;
% img(:,:,4) = 0;
% img(:,ind,[1,2,3]) = gray;%img(:, ind, [4]) = 255; % gray
% tex(3) = Screen('MakeTexture', w, img);

% str = sprintf(['指导语\n' ...
%     '请只关注红色条形的方向，忽略蓝色条形的方向\n'...
%     '转动了请按%s , 没有变化请按%s\n'...
%     ], upKey{:});
%
% DrawFormattedText(w, str, ct, ct, 255, [], 0, 0, 2);


Screen(w,'FillRect',white);

if mod(subjectID,2)
    ins= imread('ins1.jpg');%same4, rotate 1
    ins1=Screen('MakeTexture',w,ins);
    iw=size(ins,2);
    ih=size(ins,1);
    Screen('DrawTexture',w,ins1,[],[xcenter-iw/2,ycenter-ih/2,xcenter+iw/2,ycenter+ih/2]);
    
else
    ins= imread('ins2.jpg');%same1,rotate 4
    ins2=Screen('MakeTexture',w,ins);
    iw=size(ins,2);
    ih=size(ins,1);
    Screen('DrawTexture',w,ins2,[],[xcenter-iw/2,ycenter-ih/2,xcenter+iw/2,ycenter+ih/2]);
end
Screen('Flip', w);
%KbReleaseWait;
WaitTill('s');

% KbWait;
% Screen('Flip', w);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Start trigger
Screen(w,'FillRect',gray);
Screen('DrawLines', w, xy, 3, 0);% fixation
Screen(w,'Flip');
%%%
%p.start=RTBox('TTL',trigger_start);
p.start=GetSecs;
%lptwrite(888,trigger_start);WaitTill(p.start+0.025);lptwrite(888,0);
%Synchronize
NetStation('Synchronize',w);%syx

WaitSecs(.5);%syx

NetStation('StartRecording');%syx

time1=clock;%syx

NetStation('Event','STAR',GetSecs,0.05,'idx',1);%syx

WaitSecs(3);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% i=startpoint;

%% First fixation
Screen('DrawLines', w, xy, 3, 0);% fixation
% KbWait;
vbl = Screen('Flip', w);

load FixRand.mat
% try

try
    for i = 1:nTrial
        if rec(i,4)==2
            rec(i,3)=rec(i,3)-1;
            p.nDistractor=2;
            n = rec(i,3) + p.nDistractor; % distractors + target
        else
            p.nDistractor=0;
            n = rec(i,3);
        end
        
        xPos = randi(rg, [1 n+1]); % random (x,y) positions
        yPos = randi(rg, [1 n+1]);
        xPos(1) = rg/2; yPos(1) = rg/2; % reserved for fixation
        dg = diag(ones(n+1,1)) * ht*2; % large val for dist diag
        dg(1,:) = dg(1,:) + ht*0.3; % allow smaller dist to fixation
        dg(:,1) = dg(:,1) + ht*0.3;
        
        for nIters = 1:5000
            [x1, x2] = meshgrid(xPos);
            [y1, y2] = meshgrid(yPos);
            dist = sqrt((x1-x2).^2 + (y1-y2).^2) + dg;
            [~, col] = find(dist<(ht+2)); % 2-pixel space
            if isempty(col), break; end
            j = numel(col);
            ind = unique(col(j/2+1:j)); % half of col
            j = numel(ind);
            xPos(ind) = randi(rg, [1 j]);
            yPos(ind) = randi(rg, [1 j]);
        end
        % fprintf('%g\n', nIters);
        
        xPos(1) = []; yPos(1) = []; % fixation
        rects = zeros([4 n]);
        rects(1,:) = xPos + rect(3)/2 - ht/2 - rg/2;
        rects(2,:) = yPos + rect(4)/2 - ht/2 - rg/2;
        rects(3,:) = rects(1,:) + ht;
        rects(4,:) = rects(2,:) + ht;
        
        iTarget= randsample(n, (n-p.nDistractor));
        texs = ones(1,n)*tex(2); texs(iTarget) = tex(1);
        ori = rand([n 1]) * 180; % rand rotations
        Screen('DrawTextures', w, texs, [], rects, ori);
        Screen('DrawLines', w, xy, 3, 0);
        vbl = Screen('Flip', w, vbl+p.ISI+FixRand(i));
        
        index=rec(i,3)*10+rec(i,7); % 3 load 7 target [0 2] 8 left=0,right=1
        switch index
            case 22
                trigger_exp=trigger_ss22; %load 2 with distractor
                NetStation('Event','22S',GetSecs,0.05,'run',run,'targ',rec(i,3),'disr',rec(i,4),'idx',trigger_exp);      
            case 20
                trigger_exp=trigger_ss2; %load 2
                NetStation('Event','20S',GetSecs,0.05,'run',run,'targ',rec(i,3),'disr',rec(i,4),'idx',trigger_exp);
                
%             case 42
%                 trigger_exp=trigger_ss42;%load 4 with 2 dis
%                 NetStation('Event','s4d2_s',GetSecs,0.05,'run',run,'targ',rec(i,3),'disr',rec(i,7),'idx',trigger_exp);
                
            case 40
                trigger_exp=trigger_ss4;%load 4
                NetStation('Event','40S',GetSecs,0.05,'run',run,'targ',rec(i,3),'disr',rec(i,4),'idx',trigger_exp);
                %         case 600
                %             trigger_exp=trigger_ss6;%load 6
                %         case 800
                %             trigger_exp=trigger_ss8;%load 8
        end
        

        rec(i,8) = vbl-p.start;
        Screen('DrawLines', w, xy, 3, 0);
        vbl = Screen('Flip', w, vbl+p.stimDur-0.007);
        
      
        
        if rec(i,2)
            i0 = randsample(iTarget, 1);
            ori(i0) = ori(i0) + 45 * randsample([-1 1],1);
        end
        
        % probe
        Screen('DrawTextures', w, texs, [], rects, ori);
        Screen('DrawLines', w, xy, 3, 0);
        t0 = Screen('Flip', w, vbl+p.retentionDur-0.007);
       
        index=rec(i,3)*10+rec(i,7)+1; % 3 load 7 target [0 2] 8 left=0,right=1
        switch index
            case 23
                trigger_probe=trigger_ss22_probe; %load 2 with distractor
                NetStation('Event','22P',GetSecs,0.05,'run',run,'targ',rec(i,3),'disr',rec(i,4),'idx',trigger_probe);
            case 21
                trigger_probe=trigger_ss2_probe; %load 2
                NetStation('Event','20P',GetSecs,0.05,'run',run,'targ',rec(i,3),'disr',rec(i,4),'idx',trigger_probe);
%             case 43
%                 trigger_probe=trigger_ss42_probe;%load 4
%                 NetStation('Event','s4d2_p',GetSecs,0.05,'run',run,'targ',rec(i,3),'disr',rec(i,7),'idx',trigger_probe);
                
            case 41
                trigger_probe=trigger_ss4_probe;%load 4
                NetStation('Event','40P',GetSecs,0.05,'run',run,'targ',rec(i,3),'disr',rec(i,4),'idx',trigger_probe);
                
                %         case 600
                %             trigger_probe=trigger_ss6_probe;%load 4
                %         case 800
                %             trigger_probe=trigger_ss8_probe;%load 4
        end
        rec(i,9)=GetSecs-p.start;
        
        
        %%%% detect response
        t=[];
        key=[];
        
        %     while isempty(key) && GetSecs<(t0+p.testDur)
        %   [t, btn]=RTBox;
        [key, t] = WaitTill(p.keys, t0+p.testDur);
        RT_tmp=t-t0;
        if isempty(key)
            key = char(48);
        end
        rec(i,5)=key-48;
        rec(i,7) = RT_tmp;
       
        
        
        if mod(subjectID,2)
            if rec(i,2)==0 && rec(i,5)==4 || rec(i,2)==1 && rec(i,5)==1
                ok=1;
                NetStation('Event','RER',GetSecs,0.05,'run',run,'targ',rec(i,3),'disr',rec(i,4),'idx',trigger_resp_right);
            elseif rec(i,2)==1 && rec(i,5)==4 || rec(i,2)==0 && rec(i,5)==1
                ok=0;
                NetStation('Event','REW',GetSecs,0.05,'run',run,'targ',rec(i,3),'disr',rec(i,4),'idx',trigger_resp_wrong);
            else
                ok=0;
            end
        else
            if rec(i,2)==1 && rec(i,5)==4 || rec(i,2)==0 && rec(i,5)==1
                ok=1;
                NetStation('Event','RER',GetSecs,0.05,'run',run,'targ',rec(i,3),'disr',rec(i,4),'idx',trigger_resp_right);
            elseif rec(i,2)==0 && rec(i,5)==4 || rec(i,2)==1 && rec(i,5)==1
                ok=0;
                NetStation('Event','REW',GetSecs,0.05,'run',run,'targ',rec(i,3),'disr',rec(i,4),'idx',trigger_resp_wrong);
            else
                ok=0;
            end
        end
        rec(i,6)=ok(1,1);
            

        
        Screen('DrawLines', w, xy, 3, 0);
        %         if isempty(key)
        %             WaitTill(t0+p.testDur);%
        %         else
        %             WaitTill(t0+RT_tmp+testDur);
        %         end
        vbl = Screen('Flip', w);
        
    end
    
    
    
    % end while, end collect response
    
    % i=i+1;
    % present cue
    
    
catch
    c=clock;
    d=date;
    outfile=fullfile('results', sprintf('tmp_ADHD_filtering_sub%03d_block%d_run%02d_%s_%02.0f-%02.0f',subjectID,block,run,date,c(4),c(5)));
    save(outfile, 'rec');
end % end trial


Screen('Flip', w);
p.finish=GetSecs;
time2=clock;
NetStation('Event','ENDS',GetSecs,0.05,'idx',2);%syx

NetStation('StopRecording');
WaitSecs(1);%syx

NetStation('Disconnect');%syx

%lptwrite(888,trigger_end); tmpSecs=GetSecs;WaitTill(tmpSecs+0.025);lptwrite(888,0);
WaitSecs(1);
%p.finish=RTBox('TTL',trigger_end);
Screen('CloseAll');
Priority(0);
ShowCursor;

%% Save run results
c=clock;
d=date;
outfile=fullfile('results',sprintf('ADHD_filtering_sub%03d_block%d_run%02d_%s_%02.0f-%02.0f',subjectID,block,run,date,c(4),c(5)));
save(outfile, 'rec');


%%% print summary result:
fprintf('-------------------------------\n');
fprintf('Result summary: \n');
fprintf('Filtering speed: %5.1fms\n', nanmean(rec(:,7))*1000);
fprintf('Filtering accuracy: %5.2f%%\n', mean(rec(:,6)==1)*100);





