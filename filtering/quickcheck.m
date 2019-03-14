%quick check%

[a b c]=xlsread('G:\tDCS_EXP2.xlsx');
ff(1)=mean(Capacity(a==1,1));
ff(2)=mean(Capacity(a==2,1));
ff(3)=mean(Capacity(a==3,1));
ss2(1)=mean(Capacity(a==1,2));
ss2(2)=mean(Capacity(a==2,2));
ss2(3)=mean(Capacity(a==3,2));
ss4(1)=mean(Capacity(a==1,3));
ss4(2)=mean(Capacity(a==2,3));
ss4(3)=mean(Capacity(a==3,3));
figure
bar([ff;ss2;ss4])
figure
bar([ff;ss4])
figure
bar([ff;ss4]')