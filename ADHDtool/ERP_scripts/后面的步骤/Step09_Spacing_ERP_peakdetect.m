%find the peak and its latency of an erp component
clear all,clc

%Parameters
Cond_names = {['Short'];['Middle'];['Long'];               %1-3
              ['Forg'];['Rem'];                            %4-5
              ['P1'];['P2'];                               %6-7
              ['SF'];['MF'];['LF'];['SR'];['MR'];['LR'];   %8-13
              ['S1'];['S2'];['M1'];['M2'];['L1'];['L2'];   %14-19
              ['F1'];['F2'];['R1'];['R2'];                 %20-23
              ['SF1'];['SF2'];['SR1'];['SR2'];             %24-27
              ['MF1'];['MF2']; ['MR1'];['MR2'];            %28-31
              ['LF1'];['LF2']; ['LR1'];['LR2'];            %32-35
             };
load('.\param\Step1_param.mat', 'p', 'epoch_limits', 'chanlocs');
prompt = {'Channel:', 'Conditions:', 'TimeWindowBegin(ms):', 'TimeWindowEnd(ms):', 'TimePeak(ms):', 'DataFile:', 'Component(N/P):'};
dlg_title = 'Parameters';
num_lines = 1;
def = {'62,63,64', '24:35', '180', '255', '200','.\results\EEG_data_all.mat', 'P2'}; %PO8,PO4,O2
% def = {'24,25,62,61', '24:35', '120', '180', '147', '.\results\EEG_data_all.mat', 'N170'}; %P9,P07,PO8,P10
resp = inputdlg(prompt, dlg_title, num_lines, def);
eval(['Channel = [', resp{1}, '];']);
eval(['Conditions = [', resp{2}, '];']);
% Channel = cellfun(@str2double, regexp(resp{1}, '\d+', 'match'));
% Conditions = cellfun(@str2double, regexp(resp{2}, '\d+', 'match'));
TimeWindowBegin = str2double(resp{3});
TimeWindowEnd = str2double(resp{4});
TimePeak = str2double(resp{5});
DataFile = resp{6};
Component = resp{7};
if isempty(Channel)
    disp('-------------------------------');
    disp('No channel selected, exiting...');
    disp('-------------------------------');
    return
end
startpoint = ceil((TimeWindowBegin + 500) / 1000 * p.sr);
endpoint = ceil((TimeWindowEnd + 500) / 1000 * p.sr);
optpoint = ceil((TimePeak + 500)/ 1000 * p.sr);

%Loading datafile.
load(DataFile);
figure ('position',[100 100 960 660])
for isub = 1:size(EEG_all_clean, 2)
    for icond = 1:length(Conditions)
        usedPoints = unique(ceil(((-200:800) + 500) / 1000 * p.sr));
        thisData = EEG_all_clean{Conditions(icond), isub}.data(Channel, :);
        thisPeak = nan(length(Channel), 2);
        
        %Find all the local extremes.
        for ichan = 1:size(thisData, 1)
            tempPeakLoc = [];
            for ipoint = startpoint:endpoint
                switch Component(1)
                    case 'N'
                        if thisData(ichan, ipoint) < thisData(ichan, ipoint - 1) ...
                                && thisData(ichan, ipoint) < thisData(ichan, ipoint + 1)
                            tempPeakLoc = [tempPeakLoc, ipoint]; %#ok<*AGROW>
                        end
                    case 'P'
                        if thisData(ichan, ipoint) > thisData(ichan, ipoint - 1) ...
                                && thisData(ichan, ipoint) > thisData(ichan, ipoint + 1)
                            tempPeakLoc = [tempPeakLoc, ipoint];
                        end
                end
            end
            distToOpt = inf;
            for peakloc = tempPeakLoc
                if abs(peakloc - optpoint) < distToOpt
                    nearestPeak = peakloc;
                end
            end            
            
            if ~exist('nearestPeak', 'var')
                disp('------------------------------------------------------------------------------');
                disp('Please check parameters: Component, because no peak point detected. Exiting...');
                disp('------------------------------------------------------------------------------');
                return
            end
            peak_time = nearestPeak / p.sr * 1000 - 500;
            peak_val = thisData(ichan, nearestPeak);
            
            %Plot for preview.
            plot((usedPoints) / p.sr * 1000 - 500, thisData(ichan, usedPoints));
            hold on;
            plot((usedPoints) / p.sr * 1000 - 500, zeros(1, length(usedPoints)), 'k');
            plot([0 0], ylim, 'k');
            title(sprintf('Sub%d-%s-%s', isub, Cond_names{Conditions(icond)}, chanlocs(Channel(ichan)).labels));
            set(gca, 'xlim', [-200, 500]);  
            set(gca, 'xtick', [-200, 0:100:500, 800]);            
            plot(tempPeakLoc / p.sr * 1000 - 500, thisData(ichan, tempPeakLoc), '*g');
            plot(peak_time, peak_val, '*r');  
            hold off;
            %Decision of peak.
            choice = questdlg('Does this peak fit okay?', 'Confirmation', 'Yes', 'No', 'Yes');
            if strcmp(choice, 'Yes')
                thisPeak(ichan, :) = [peak_time, peak_val];
            else
                peaknumstr = inputdlg({'Please input the index of the correct peak'}, 'Which peak?');
                if ~isempty(peaknumstr{:})
                    peaknum = str2double(peaknumstr);
                    thisPeak(ichan, :) = [tempPeakLoc(peaknum) / p.sr * 1000 - 500, thisData(ichan, tempPeakLoc(peaknum))];
                else
                    thisPeak(ichan, :) = nan(1, 2);
                end
            end
        end
        %Sub * cond * chan * [peaktime, peakvalue]
        allPeak(isub, icond, :, :) = thisPeak;
    end
end
close(gcf);
save(sprintf('.\\results\\Peak_%s', Component), 'allPeak');