function U_topoplot(vector,layout_file,chn_names,image_file,zlim,highlight_chns)

cfg=[];

if(nargin==4)
    cfg.image=image_file;
end
if(nargin<5)
    zlim=-1;
end
if(nargin<6)
    highlight_chns=[];
end
cfg.layout=layout_file;
cfg.marker='off';
%cfg.markersize=8;
cfg.colorbar='no';
data.powspctrm = vector; % [N x 1]
data.label = chn_names; % {1 x N}

%if the layout_file is a structure (not a file), exclude the channels not included in layout_file
if(~isstr(cfg.layout))
    chn_includes=ones(1,length(data.label));
    for i=1:length(data.label)
        tmp=strfind(cfg.layout.label,data.label{i});
        data_found=0;
        for j=1:length(tmp)
            if(~isempty(tmp{j}))
                data_found=1;
              break;
            end
        end
        if(data_found==0)
            chn_includes(i)=0;
        end
    end
    chn_includes=find(chn_includes==1);
    data.powspctrm = data.powspctrm(chn_includes,1); % [N x 1]
    data.label = data.label(1,chn_includes); % {1 x N}
end
data.freq = 1;
data.dimord = 'chan_freq';
if(zlim~=-1)
    cfg.zlim = [-zlim zlim];%codes for customized view
end

if(~isempty(highlight_chns))
    cfg.highlight='on';
    cfg.highlightchannel=chn_names(highlight_chns);
    cfg.highlightsymbol='.';
    cfg.highlightsize=15;
%     cfg.highlightfontsize=10;
end

ft_topoplotER(cfg,data);
