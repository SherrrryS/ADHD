% to generate randomly No-go trails
% 20 no-go(type=1); 60 go(type2) for each run.
clear,clc

%% parameters
n=10000;
trial=80;
per=0.25;

%% creat seq
% for i=1:n
%     cnt=randperm(trial);
%     cnt_nogo=sort(cnt(1:trial*per));
%     
%     for j=1:trial
%         if find(j==cnt_nogo)~=0
%         seq(i,j)=1;
%         else
%         seq(i,j)=2;
%         end
%     end
%     seq(i,j+1)=sum(cnt_nogo)-sum(cnt)/4;
%   
% end
% 
% % distributed equally among 80 trial;
%   seq_good1= seq(find(abs(seq(:,trial+1))==0),:);
% % no subsequent 3 no-go trials
% 
% for c=1:size(seq_good1,1)
%     sum_dis=0;
%     for d=1:trial-1
%     dis=abs(seq_good1(c,d+1)-seq_good1(c,d));
%     sum_dis=dis+sum_dis;
%     end
%     seq_good1(c,trial+2)=sum_dis
% end
% 
%  seq_good2= seq_good1(find(seq_good1(:,trial+2)>30),:);
%  seq_final=seq_good2([1:9],[1:trial])';
%  save seq_final seq_final
%  

%% creat onset time

%  onset_tmp=[ones(1,16)*1.1,ones(1,16)*1.3,ones(1,16)*1.5,ones(1,16)*1.7,ones(1,16)*1.9]';
%  onset_tmp=onset_tmp(randperm(length(onset_tmp)));
%  sum_onset=3;
%  for i=1:trial
%      onset(1,1)=3;
%      sum_onset=sum_onset+0.5+onset_tmp(i,1);
%      onset(i+1,1)=sum_onset;
%  end
%  save onset onset
%  