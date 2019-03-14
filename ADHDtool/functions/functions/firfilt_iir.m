function yfilt=firfilt_iir(x,fs,fsl,fpl,fph,fsh)
% by wcm 2012.06.25 @ BNU
% Function:
% IIR bandpass filter by chebyshev I filter
% 
% Input:
% x: the signals to be filtered
% fs:sampling rate in hz
% fsl & fsh: stop band frequency 
% fpl & fph: pass band frequency
% Output:
% yfilter: the filtered signals
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% % the design process of the ideal filter and the hamming window
% 
% % for hamming windows, order of fir 0.03 - 0.05  30 30.05 ==> 3.3/0.02=165 
% % if the data size is too short, 0.05 0.1 - 30 30.05 is suggested

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


%--------------the initial parameter for IIR filters----------------%
% exa4-16_cheb1low.m , for example 4-16
% using chebyshev I filter to design lowpass DF

%===============%
% default parameters for IIR filters
rp=0.05; % dB (EEGLAB)
rs=30;  % dB
%===============%
% clear all;
% Wp=100;
% Ws=200;
% Fs=1000;

% use eeglab framework: bandpass=lp+hp

   %first part LPF
    wplp=fph/(fs/2); %(hicutoff)/nyq;
    wslp=fsh/(fs/2); %(hicutoff+trans_bw)/nyq;

    [Nlp,wnlp] = ellipord(wplp,wslp,rp,rs);
%     fprintf('BPF has been designed.\n');
%     fprintf('LPF has cutoff of %1.1f Hz, transition bandwidth of %1.1f Hz and its order is %1.1f\n',hicutoff, trans_bw,N);
    %[zl, pl, kl]=ellip(N,rp,rs,wn);
    %[lpf_sos,lpf_g] = zp2sos(zl,pl, kl);
    [blp,alp]=ellip(Nlp,rp,rs,wnlp);
   
    %second part HPF
    wphp=fpl/(fs/2); %(locutoff)/nyq;
    wshp=fsl/(fs/2); %(locutoff-trans_bw)/nyq;

    [Nhp,wnhp] = ellipord(wphp,wshp,rp,rs);
%     fprintf('HPF has cutoff of %1.1f Hz, transition bandwidth of %1.1f Hz and its order is %1.1f\n',locutoff, trans_bw,N);
    %[zh, ph, kh]=ellip(N,rp,rs,wn);
    %[hpf_sos,hpf_g] = zp2sos(zh,ph, kh);
    [bhp,ahp]=ellip(Nhp,rp,rs,wnhp,'high');
    %help fvtool
    %b=conv(bh,bl);a=conv(ah,al);
%     b.bl=bl;b.bh=bh; a.al=al;a.ah=ah;
    
    y1= filter(blp,alp,x);
    yfilt = filter(bhp,ahp,y1);
    clear y1  

%%%================don't recommend a direct Bandpass filter================%%%

% if fsl==0 && fpl==0
%     Wp=Wph;
%     Ws=Wsh;
% else
% %     Wp=[Wpl Wph];
% %     Ws=[Wsl Wsh];
%     Fp=[fpl fph];
%     Fs=[fsl fsh];
% end
% % [N,Wn]=cheb1ord(Wp,Ws,Rp,Rs,'s');
% [N,Wn]=cheb1ord(Fp/(fs/2),Fs/(fs/2),Rp,Rs);
% % [N,Wn]=cheb1ord(Wp/(Fs/2),Ws/(Fs/2),Rp,Rs);
% % [N,Wn]=cheb1ord(fp*2*pi/Fs,fs*2*pi/Fs,Rp,Rs,'s');
% % %     [N, Wp] = CHEB1ORD(Wp, Ws, Rp, Rs, 's') does the computation for an 
% % %     analog filter, in which case Wp and Ws are in radians/second.
%     
% [b,a] = cheby1(N,Rp,Wn);
% freqz(b,a,N,250);
% 
% h=impz(b,a);
% 
% y=filter(b,a,x)

% % %--------------the initial parameter----------------%
% % % Wpl = 0.4*pi;
% % % Wph = 0.6*pi;
% % % Wsl = 0.2*pi;
% % % Wsh = 0.8*pi;
% % % for hamming window, 8xpai/N pangban, 6.6xpai/N guodudai - 41 db and - 53
% % % db guodudai minimum shuaijian
% % % so the length of N is determined by wc and wp
% % 
% % if fsl==0 && fpl==0
% %     tr_width = (Wsh-Wph);  % 过渡带宽度
% %     N = ceil(6.6*pi/tr_width); %; 滤波器长度  % hamming window length =6.6*pi
% %     n = 0:1:N-1;
% % %     Wcl = (Wsl+Wpl)/2; % 理想低通滤波器的下截止频率
% %     Wch = (Wsh+Wph)/2; % 理想低通滤波器的上截止频率
% %     hd = ideal_lp(Wch,N);%    ideal_bp1(Wcl,Wch,N); % 理想带通滤波器的单位冲激响应
% %     
% % else
% %     
% %     tr_width = min((Wpl-Wsl),(Wsh-Wph));  % 过渡带宽度
% %     N = ceil(6.6*pi/tr_width); %; 滤波器长度  % hamming window length =6.6*pi
% %     n = 0:1:N-1;
% %     Wcl = (Wsl+Wpl)/2; % 理想低通滤波器的下截止频率
% %     Wch = (Wsh+Wph)/2; % 理想低通滤波器的上截止频率
% %     hd = ideal_bp1(Wcl,Wch,N); % 理想带通滤波器的单位冲激响应
% %    
% % end
% % 
% % w_ham = (hamming(N))'; % 汉宁窗
% % h = hd.*w_ham; % 截取得到实际的单位脉冲响应
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%

% y=conv(h,x);
% ylength=size(x,2);
% hlength=N;%size(h,2);
% yfilt(1:ylength)=y((round((hlength-1)/2)+1):(round((hlength-1)/2)+ylength));

end
% % 
% % function hd=ideal_bp1(Wcl,Wch,N)
% % % compute the ideal bandpass fiter unit pulse respondence hd(n)
% % % wcl: low cutoff frequency
% % % wch: high cutoff frequency
% % % N: window length
% % % hd: unit pulse respondence 
% % 
% % alpha = (N-1)/2;
% % n=0:1:N-1;
% % m=n-alpha+eps;
% % hd=[sin(Wch*m)-sin(Wcl*m)]./(pi*m);
% % end
% % 
% % 
% % function hd=ideal_lp(Wc,N)
% % % compute the ideal lowpass fiter unit pulse respondence hd(n)
% % % wc: cutoff frequency
% % % N: window length
% % % hd: unit pulse respondence 
% % 
% % alpha = (N-1)/2;
% % n=0:1:N-1;
% % m=n-alpha+eps;
% % hd=sin(Wc*m)./(pi*m);
% % end