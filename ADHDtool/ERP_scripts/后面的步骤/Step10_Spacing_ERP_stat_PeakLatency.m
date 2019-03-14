% ERP Peak Latency anlysis

clear all;clear all;clc;clear all;%close all;
%% input parameter
sub_selected=[1:8];
sub_unselect=[ ];
peak_type=2; %1-peaklatency (ms);2-peakamplitude (\muv);
% % % N170-------------------------------------------
% % channel_selected=[1:4]; chan_name={'P9','P07','PO8','P10'}; %N170 --> P9,P07,PO8,P10
% % load results\Peak_N170.mat;
% P2---------------------------------------------
channel_selected=[1:3]; chan_name={'P08','PO4','O2'}; %P2 --> %PO8,PO4,O2
load results\Peak_P2.mat

event_selected=[1:12]'; %SML-FR-12;
% % Cond_names = {['Short'];['Middle'];['Long'];               %1-3
% %               ['Forg'];['Rem'];                            %4-5
% %               ['P1'];['P2'];                               %6-7
% %               ['SF'];['MF'];['LF'];['SR'];['MR'];['LR'];   %8-13
% %               ['S1'];['S2'];['M1'];['M2'];['L1'];['L2'];   %14-19
% %               ['F1'];['F2'];['R1'];['R2'];                 %20-23
%               ['SF1'];['SF2'];['SR1'];['SR2'];             %24-27
%               ['MF1'];['MF2']; ['MR1'];['MR2'];            %28-31
%               ['LF1'];['LF2']; ['LR1'];['LR2'];            %32-35
%              };
% load('.\param\Step1_param.mat', 'p','epoch_limits');

data1=[];
channel_no=size(channel_selected,2);
% time_win_no=size(time_window,1);
event_no=size(event_selected,1);
sub_selected(sub_unselect)=[];
sub_no=size(sub_selected,2);
%Sub * cond * chan * [peaktime, peakvalue]

for chan=1:channel_no
    data=allPeak(:,:,chan,peak_type);
    %% ----------------two factors ANOVA---------------------%%
    %     if size(channel_selected,2)==1;
    %         data_tmp=data_all(channel_selected,:,:);
    %     elseif size(channel_selected,2)>=1
    %         data_tmp=squeeze(mean(data_all(channel_selected,:,:)));
    %     end
    
    figure('position',[100 100 1360 656]);  %Rep(r1,r2) & Lag
    subplot(1,3,1)
    data_tmp01=[nanmean(data(:,[1 3]),2) nanmean(data(:,[5 7]),2)  nanmean(data(:,[9 11]),2) nanmean(data(:,[2 4]),2)  nanmean(data(:,[6 8]),2) nanmean(data(:,[10 12]),2)];  %1S,1M,1L; 2S,2M,2L;
    stats=do_anova2(data_tmp01,2,3,{'Rep','Lag'});
    withsub_err=sqrt(stats{7,4}/size(data_tmp01,1));
    meanmat=squeeze(nanmean(data_tmp01));
    meanmat=[meanmat(:,1:3)' meanmat(:,4:6)'];
    stdmat=withsub_err*ones(size(meanmat));
    barerror(meanmat,stdmat,0.9,'k',{'r';'g';'b'})
    set(gca,'XTick',[1:3])
    set(gca,'Xticklabel','Short|Middle|Long');
    %     set(gca,'Ylim',[-3,0])
    set(gca,'Ylim',[4,9])
    %     set(gca, 'Ydir', 'reverse')
    %     set(gca,'Ylim',[200,240])
    set(gca,'FontSize',18,'FontName','Arial')
    legend('P1','P2','location','northwest');
    if peak_type==1 ylabel('Repetition effect (ms)', 'FontSize',20);
    elseif peak_type==2 ylabel('Repetition effect (\muv)', 'FontSize',20); end
    % xlabel('Repetitions','FontSize',20);
    hold off
    orient tall
    box off
    
    %Rem&Lag
    subplot(1,3,2)
    %     data_tmp=squeeze(mean(data_all(channel_selected,:,:)));
    data_tmp02=[nanmean(data(:,[1 2]),2) nanmean(data(:,[5 6]),2) nanmean(data(:,[9 10]),2) nanmean(data(:,[3 4]),2)  nanmean(data(:,[7 8]),2)  nanmean(data(:,[11 12]),2)];  %FS,FM,FL;RS,RM,RL;
    %     data=[data(:,1:3) data(:,4:6)];  %[mass1:3 space 1:3]
    stats=do_anova2(data_tmp02,2,3,{'Rem','Lag'});
    withsub_err=sqrt(stats{7,4}/size(data_tmp02,1));
    meanmat=squeeze(nanmean(data_tmp02));
    meanmat=[meanmat(:,1:3)' meanmat(:,4:6)'];
    stdmat=withsub_err*ones(size(meanmat));
    barerror(meanmat,stdmat,0.9,'k',{'r';'g';'b'})
    set(gca,'XTick',[1:3])
    set(gca,'Xticklabel','Short|Middle|Long');
    set(gca,'Ylim',[4,9])
    %     set(gca, 'Ydir', 'reverse')
    %     set(gca,'Ylim',[200,240])
    set(gca,'FontSize',18,'FontName','Arial')
    legend('Forg','Rem','location','northwest');
    if peak_type==1 ylabel('SME (ms)', 'FontSize',20); title(['PeakLatency in channel ',chan_name{chan}],'FontSize',20);
    elseif peak_type==2  ylabel('SME (\muv)', 'FontSize',20); title(['PeakAmplitude in channel ',chan_name{chan}],'FontSize',20);  end
    % xlabel('Spacing effect','FontSize',20);
    %     title(['PeakLatency in channel ',chan_name{chan}],'FontSize',20);
    hold off
    orient tall
    box off
    
    % figure   % DM(forgot,remember) &Rep(r1,r2)
    subplot(1,3,3)
    data_tmp03=[nanmean(data(:,[1 5 9]),2)  nanmean(data(:,[2 6 10]),2) nanmean(data(:,[3 7 11]),2) nanmean(data(:,[4 8 12]),2)];
    stats=do_anova2(data_tmp03,2,2,{'SM','Rep'});
    withsub_err=sqrt(stats{7,4}/size(data_tmp03,1));
    meanmat=squeeze(nanmean(data_tmp03));
    meanmat=[meanmat(:,1:2)' meanmat(:,3:4)'];
    stdmat=withsub_err*ones(size(meanmat));
    barerror(meanmat,stdmat,0.9,'k',{'r';'g';'b'})
    set(gca,'XTick',[1:2]);
    set(gca,'Xticklabel','P1|P2');
    set(gca,'Ylim',[4,9])
    %     set(gca, 'Ydir', 'reverse')
    %     set(gca,'Ylim',[200,240])
    set(gca,'FontSize',18,'FontName','Arial')
    legend('Forg','Rem','location','northwest');
    if peak_type==1 ylabel('SME (ms)', 'FontSize',20); ylabel('SME (ms)', 'FontSize',20);
    elseif peak_type==2 ylabel('SME (\muv)', 'FontSize',20); ylabel('SME (\muv)', 'FontSize',20);end
    % xlabel('Repetitions', 'FontSize',20)
    hold off
    orient tall
    box off
    
    %% print and save the figures in tif format
    %     print('-dtiffnocompression','-r300',[output_folder file_name '.tif']);
    if peak_type==1 filename=['ERP_STATs_PeakLatency_P2_',chan_name{chan}]; elseif peak_type==2 filename=['ERP_STATs_PeakAmplitude_P2_',chan_name{chan}]; end
    print('-dtiffnocompression',[filename '.tif']);
    
    
    % % %% ----------------correlation analysis------------------ %%
    % % % %--------------------------neural P1 & RS-------------------------%
    % % data=squeeze(mean(data_all(channel_selected,:,:))); %sub_16*con_12: %1-6 mf1,sf1,mf2,sf2,mf3,sf3; 7-12 mr1,sr1,mr2,sr2,mr3,sr3;
    % % %mass
    % % figure,subplot(2,2,1)
    % % p1=mean(data(:,[1 7]),2); %m1
    % % RS_mass=(mean(data(:,[1 7]),2)-mean(data(:,[3 9 5 11]),2));
    % % [coeff,mass]=corr(p1,RS_mass)
    % % scatter(p1,RS_mass,'MarkerEdgeColor','k');
    % % set(gca,'Xlim',[-7 7],'Ylim',[-4 4])
    % % set(gca,'FontSize',20,'fontname','arial')
    % % xlabel('Neural P1')
    % % ylabel('Neural RS')
    % % legend('Massed','FontSize',14,'Location','Northeast')
    % %
    % % %space
    % % subplot(2,2,2)
    % % p1=mean(data(:,[2 8]),2); %s1
    % % RS_spac=(mean(data(:,[2 8]),2)-mean(data(:,[4 10 6 12]),2));
    % % [coeff,spac]=corr(p1,RS_spac)
    % % scatter(p1,RS_spac,'MarkerEdgeColor','k','MarkerFaceColor','k')
    % % set(gca,'Xlim',[-7 7],'Ylim',[-4 4])
    % % set(gca,'FontSize',20,'fontname','arial')
    % % xlabel('Neural P1')
    % % ylabel('Neural RS')
    % % legend('Spaced','FontSize',14,'Location','Northeast')
    % % clear mass spac
    % %
    % % %-------------------------behav_RP & neural RS----------------------%
    % % load behav_RP_erp.mat
    % % %mass
    % % subplot(2,2,3)
    % % [coeff,mas]=corr(mass,RS_mass)
    % % scatter(mass,RS_mass,'MarkerEdgeColor','k');
    % % set(gca,'Xlim',[-0.1 0.3],'Ylim',[-3 3])
    % % set(gca,'FontSize',20,'fontname','arial')
    % % xlabel('Behavioral RP')
    % % ylabel('Neural RS')
    % % legend('Massed','FontSize',14,'Location','Northeast')
    % %
    % % %space
    % % subplot(2,2,4)
    % % [coeff,spa]=corr(spac,RS_spac)
    % % scatter(spac,RS_spac,'MarkerEdgeColor','k','MarkerFaceColor','k');
    % % set(gca,'Xlim',[-0.1 0.3],'Ylim',[-3 3])
    % % set(gca,'FontSize',20,'fontname','arial')
    % % xlabel('Behavioral RP')
    % % ylabel('Neural RS')
    % % legend('Spaced','FontSize',14,'Location','Northeast')
    % %
    % % %% ---------------------three factors ANOVA--------------------%%
    % % figure
    % % data=squeeze(mean(data_all(channel_selected,:,:)));  %DM(f,r)*Rep(r1,r2,r3)*ms(m,s)
    % % data=double(data);
    % % stats=do_anova3(data,2,3,2);
    % % meanmat=mean(data);
    % % meanmat=[meanmat(1:6);meanmat(7:12)]';
    % % meanerr=sqrt(stats/size(data,1))*ones(size(meanmat));
    % % barerror(meanmat,meanerr,0.9,'black',{'r','g','b'});
    % % % set(gca,'fontsize',12);
    % % set(gca,'xtick',[1:6]);
    % % set(gca,'xticklabel','massed_P1|spaced_P1|massed_P2|spaced_P2|massed_P3|spaced_P3');
    % % % set(gca,'ylim',[0.5 0.8]);
    % % legend('Forg','Rem');
    % % ylabel('ERP(uv)');
end
