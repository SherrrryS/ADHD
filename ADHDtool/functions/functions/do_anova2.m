function stats=do_anova2(y,f1_num,f2_num,fac)
%%% do annova;
%function do_annova(y,f1_num,f2_num,fac)
%f1_num=2;
%f2_num=3;
%fac={'hem','task'}; %% factor name

% assumes:
% f1 f2
% 1  1
% 1  2
% 2  1
% 2  2
  
aa=reshape(y,size(y,1)*size(y,2),1); %%% dependent variable. in one row
bb=kron(ones(1,size(y,2)),[1:size(y,1)])'; %%%subjects 
f1=kron([1:f1_num],ones(1,size(y,1)*size(y,2)/f1_num))'; % factor 1; 
f2=kron(ones(1,f1_num),kron([1:f2_num],ones(1,size(y,1)*size(y,2)/(f1_num*f2_num))))'; % factor 2
%fac={'hem','task'}; %% factor name
stats=rm_anova2(aa,bb,f1,f2,fac) %% annova
