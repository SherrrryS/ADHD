function [stats F1 P1]=do_anova1(y)
sub=size(y,1);
cond=size(y,2);

a=reshape(y,sub*cond,1);
b=kron([1:cond], ones(1,sub))';
c=kron(ones(1,cond),[1:sub])';

[stats F1 P1]=rm_anova1([a b c]);
