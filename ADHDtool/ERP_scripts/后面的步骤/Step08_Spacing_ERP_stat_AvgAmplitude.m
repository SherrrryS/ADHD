% ERP data anlysis

clear all;clear all;clc;clear all;%close all;
%% input parameter
sub_selected=[1:8];
sub_unselect=[ ];
channel_selected=[25 62]; time_window={[210 240];};
% % time_window={[300 500];[500 800];[800 1000]; [1000 1200]};
% for i =1:450/50
%     time_window{i}=[(i-1)*50  i*50];
% end
event_selected=[24:35]'; %SML-FR-12;
% event_selected=[  25; 26; 27];
% event_selected=[  30; 31];
% event_selected=[  28; 29];
% event_selected=[1:12]';

%% analysis
% Cond_names = {['Short'];['Middle'];['Long'];               %1-3
%               ['Forg'];['Rem'];                            %4-5
%               ['P1'];['P2'];                               %6-7
%               ['SF'];['MF'];['LF'];['SR'];['MR'];['LR'];   %8-13
%               ['S1'];['S2'];['M1'];['M2'];['L1'];['L2'];   %14-19
%               ['F1'];['F2'];['R1'];['R2'];                 %20-23
%               ['SF1'];['SF2'];['SR1'];['SR2'];             %24-27
%               ['MF1'];['MF2']; ['MR1'];['MR2'];            %28-31
%               ['LF1'];['LF2']; ['LR1'];['LR2'];            %32-35
%              };
load('.\param\Step1_param.mat', 'p','epoch_limits');
load results\EEG_data_all.mat;
data1=[];
channel_no=size(channel_selected,2);
time_win_no=size(time_window,1);
event_no=size(event_selected,1);
sub_selected(sub_unselect)=[];
sub_no=size(sub_selected,2);

for time_win_cursor=1:time_win_no
    time_window_tmp=time_window{time_win_cursor};
%     point_start=round((1000+time_window_tmp(1))*0.500);
%     point_end=round((1000+time_window_tmp(2))*0.500);
    point_start=round((time_window_tmp(1)/1000-epoch_limits(1))*p.sr);
    point_end=round((time_window_tmp(2)/1000-epoch_limits(1))*p.sr);

    %     sample_select_start=1+round((time_window(j,1))*sr/1000)-before_stim_sample_limit;
    %     sample_select_end=1+round((time_window(j,2))*sr/1000)-before_stim_sample_limit;
    
    for event_cursor=1:event_no
        event_no_tmp=event_selected(event_cursor);
        %         event_name_tmp=event_names{event_selected(event_cursor)};
        for sub_cursor=1:sub_no
            sub_id_tmp=sub_selected(sub_cursor);
            data_all(:,sub_cursor,event_cursor,time_win_cursor)=mean(EEG_all_clean{event_no_tmp,sub_id_tmp}.data(1:64,point_start:point_end),2);  %[64*16sub*event*window]
            %             data_all(:,sub_cursor,event_cursor,time_win_cursor)=mean(EEG_all_analyze{event_no_tmp,sub_id_tmp}.data(event_selected(event_cursor),point_start:point_end),2);  %[64*16sub*event*window]
            data_tmp(:,sub_cursor,event_cursor,:)=EEG_all_clean{event_no_tmp,sub_id_tmp}.data;
        end
    end
    %% for analysis%%
    %%%%ready for data
    %method 01--for single channel analysis
    %     for channel_cursor=1:channel_no
    %         channel_tmp=channel_selected(channel_cursor);
    %         data=squeeze(data_all(channel_tmp,:,:,time_win_cursor));
    %         [stats F1 P1]=do_anova1(data);
    %         P_total(channel_cursor,time_win_cursor)=P1;
    %     end
    
    
    %method 02--for brain area analysis
    %
    %     for channel_cursor=1:channel_no
    %         channel_tmp=channel_selected(channel_cursor);
    %          data=data_all(channel_tmp,:,:,time_win_cursor);
    %          data1=[data1; data];    %[channel * sub * event]
    %     end
    %
    % %     %%%%% one factor ANOVA
    % %     figure
    % % %     data=squeeze(data1);    %[sub*event]
    % % data=squeeze(mean(data_all(channel_selected,:,:))); data=[mean(data(:,[1:6]),2) mean(data(:,[7:12]),2)];
    % %         [stats F1 P1]=do_anova1(data);
    % % %         P_total(channel_cursor,time_win_cursor)=P1;
    % %
    % % withsub_err=sqrt(stats/size(data,1));
    % %     F_all=F1; P_all=P1;
    % % meanmat=squeeze(mean(data));
    % % stdmat=ones(size(meanmat))*withsub_err;
    % %
    % %     h=bar(meanmat);
    % %     set(h(1),'facecolor','black') % use color name
    % %     box off
    % %     hold on
    % %     errorbar(meanmat,stdmat,'.','LineWidth',2,'color','black');
    % %     set(gca,'XTick',[1:2]);
    % %     set(gca,'Xticklabel','Remembered|Forgotten');
    % %     set(gca,'Ylim',[0,1.8])
    % %     set(gca,'FontSize',30);
    % %     ylabel('uv');
    % % text (0.3,-0.95,['F = ' num2str(F_all) '; P = ' num2str(P_all)]);
    
    
    
    %% ----------------two factors ANOVA---------------------%%
    if size(channel_selected,2)==1;
        data_tmp=data_all(channel_selected,:,:);
    elseif size(channel_selected,2)>=1
        data_tmp=squeeze(mean(data_all(channel_selected,:,:)));
    end
    
    figure  % Spacing(mass,space) &Rep(r1,r2,r3)
    %     data=squeeze(mean(data1));
    subplot(1,3,1)
    % data=[mean(data(:,[1 7]),2)  mean(data(:,[3 9]),2) mean(data(:,[5 11]),2) mean(data(:,[2 8]),2) mean(data(:,[4 10]),2)  mean(data(:,[6 12]),2)];  %r1m,r1s,r2m,r2s,r3m,r3s
    data_tmp01=[mean(data_tmp(:,[1 3]),2) mean(data_tmp(:,[5 7]),2)  mean(data_tmp(:,[9 11]),2) mean(data_tmp(:,[2 4]),2)  mean(data_tmp(:,[6 8]),2) mean(data_tmp(:,[10 12]),2)];  %1S,1M,1L; 2S,2M,2L;
    %     data=[data(:,1:3) data(:,4:6)];  %[mass1:3 space 1:3]
    stats=do_anova2(data_tmp01,2,3,{'Rep','Lag'});
    withsub_err=sqrt(stats{7,4}/size(data_tmp01,1));
    meanmat=squeeze(mean(data_tmp01));
    meanmat=[meanmat(:,1:3)' meanmat(:,4:6)'];
    stdmat=withsub_err*ones(size(meanmat));
    barerror(meanmat,stdmat,0.9,'k',{'r';'g';'b'})
    set(gca,'XTick',[1:3])
    set(gca,'Xticklabel','Short|Middle|Long');
%     set(gca,'Ylim',[-3,0])
    set(gca,'Ylim',[-10,-4])
    set(gca, 'Ydir', 'reverse')
    set(gca,'FontSize',18,'FontName','Arial')
    legend('P1','P2','location','northwest');
    ylabel('Repetition effect (\muv)', 'FontSize',20);
    % xlabel('Repetitions','FontSize',20);
    hold off
    orient tall
    box off
    
    %Rem&Lag
    subplot(1,3,2)
    data_tmp=squeeze(mean(data_all(channel_selected,:,:)));
    data_tmp02=[mean(data_tmp(:,[1 2]),2) mean(data_tmp(:,[5 6]),2) mean(data_tmp(:,[9 10]),2) mean(data_tmp(:,[3 4]),2)  mean(data_tmp(:,[7 8]),2)  mean(data_tmp(:,[11 12]),2)];  %FS,FM,FL;RS,RM,RL;
    %     data=[data(:,1:3) data(:,4:6)];  %[mass1:3 space 1:3]
    stats=do_anova2(data_tmp02,2,3,{'Rem','Lag'});
    withsub_err=sqrt(stats{7,4}/size(data_tmp02,1));
    meanmat=squeeze(mean(data_tmp02));
    meanmat=[meanmat(:,1:3)' meanmat(:,4:6)'];
    stdmat=withsub_err*ones(size(meanmat));
    barerror(meanmat,stdmat,0.9,'k',{'r';'g';'b'})
    set(gca,'XTick',[1:3])
    set(gca,'Xticklabel','Short|Middle|Long');
    set(gca,'Ylim',[-10,-4])
    set(gca, 'Ydir', 'reverse')
    set(gca,'FontSize',18,'FontName','Arial')
    legend('Forg','Rem','location','northwest');
    ylabel('SME (\muv)', 'FontSize',20);
    % xlabel('Spacing effect','FontSize',20);
    hold off
    orient tall
    box off
    
    % figure   % DM(forgot,remember) &Rep(r1,r2)
    subplot(1,3,3)
    data_tmp03=[mean(data_tmp(:,[1 5 9]),2)  mean(data_tmp(:,[2 6 10]),2) mean(data_tmp(:,[3 7 11]),2) mean(data_tmp(:,[4 8 12]),2)];
    stats=do_anova2(data_tmp03,2,2,{'SM','Rep'});
    withsub_err=sqrt(stats{7,4}/size(data_tmp03,1));
    meanmat=squeeze(mean(data_tmp03));
    meanmat=[meanmat(:,1:2)' meanmat(:,3:4)'];
    stdmat=withsub_err*ones(size(meanmat));
    barerror(meanmat,stdmat,0.9,'k',{'r';'g';'b'})
    set(gca,'XTick',[1:2]);
    set(gca,'Xticklabel','P1|P2');
    set(gca,'Ylim',[-10,-4])
    set(gca, 'Ydir', 'reverse')
    set(gca,'FontSize',18,'FontName','Arial')
    legend('Forg','Rem','location','northwest');
    ylabel('SME (\muv)', 'FontSize',20)
    % xlabel('Repetitions', 'FontSize',20)
    hold off
    orient tall
    box off
    
    
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












