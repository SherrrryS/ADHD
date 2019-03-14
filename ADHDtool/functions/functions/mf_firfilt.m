function yfilt=mf_firfilt(x,fs,fsl,fpl,fph,fsh)
% adding instructions by wcm 2011.05.08 @ BNU
% Function:
% FIR bandpass filter by Hamming windows
% 
% Input:
% x: the signals to be filtered
% fs:sampling rate in hz
% fsl & fsh: stop band frequency 
% fpl & fph: pass band frequency
% Output:
% yfilter: the filtered signals
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% the design process of the ideal filter and the hamming window

% for hamming windows, order of fir 0.03 - 0.05  30 30.05 ==> 3.3/0.02=165 
% if the data size is too short, 0.05 0.1 - 30 30.05 is suggested

if nargin < 2
   error('Not enough input arguments.')
  
else
    if nargin == 2
         Wsl = 2*pi*0.05/fs;
         Wpl = 2*pi*0.1/fs;
         Wph = 2*pi*30/fs;           %19
         Wsh = 2*pi*30.5/fs;           %21
    else

        Wsl = 2*pi*fsl/fs;
        Wpl = 2*pi*fpl/fs;
        Wph = 2*pi*fph/fs;
        Wsh = 2*pi*fsh/fs;
    end
end

%--------------the initial parameter----------------%
% Wpl = 0.4*pi;
% Wph = 0.6*pi;
% Wsl = 0.2*pi;
% Wsh = 0.8*pi;
% for hamming window, 8xpai/N pangban, 6.6xpai/N guodudai - 41 db and - 53
% db guodudai minimum shuaijian
% so the length of N is determined by wc and wp

if fsl==0 && fpl==0
    tr_width = (Wsh-Wph);  % 过渡带宽度
    N = ceil(6.6*pi/tr_width); %; 滤波器长度  % hamming window length =6.6*pi
    n = 0:1:N-1;
%     Wcl = (Wsl+Wpl)/2; % 理想低通滤波器的下截止频率
    Wch = (Wsh+Wph)/2; % 理想低通滤波器的上截止频率
    hd = ideal_lp(Wch,N);%    ideal_bp1(Wcl,Wch,N); % 理想带通滤波器的单位冲激响应
    
else
    
    tr_width = min((Wpl-Wsl),(Wsh-Wph));  % 过渡带宽度
    N = ceil(6.6*pi/tr_width); %; 滤波器长度  % hamming window length =6.6*pi
    n = 0:1:N-1;
    Wcl = (Wsl+Wpl)/2; % 理想低通滤波器的下截止频率
    Wch = (Wsh+Wph)/2; % 理想低通滤波器的上截止频率
    hd = ideal_bp1(Wcl,Wch,N); % 理想带通滤波器的单位冲激响应
   
end

w_ham = (hamming(N))'; % 汉宁窗
h = hd.*w_ham; % 截取得到实际的单位脉冲响应
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

y=conv(h,x);
ylength=size(x,2);
hlength=N;%size(h,2);
yfilt(1:ylength)=y((round((hlength-1)/2)+1):(round((hlength-1)/2)+ylength));

end

function hd=ideal_bp1(Wcl,Wch,N)
% compute the ideal bandpass fiter unit pulse respondence hd(n)
% wcl: low cutoff frequency
% wch: high cutoff frequency
% N: window length
% hd: unit pulse respondence 

alpha = (N-1)/2;
n=0:1:N-1;
m=n-alpha+eps;
hd=[sin(Wch*m)-sin(Wcl*m)]./(pi*m);
end


function hd=ideal_lp(Wc,N)
% compute the ideal lowpass fiter unit pulse respondence hd(n)
% wc: cutoff frequency
% N: window length
% hd: unit pulse respondence 

alpha = (N-1)/2;
n=0:1:N-1;
m=n-alpha+eps;
hd=sin(Wc*m)./(pi*m);
end