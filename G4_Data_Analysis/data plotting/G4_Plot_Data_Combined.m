function G4_Plot_Data_Combined(exp_folder, trial_options, CL_conds, OL_conds, TC_conds, overlap, frame_superimpose)
%FUNCTION G4_Plot_Data_Combined(exp_folder, trial_options, CL_conds, OL_conds, TC_conds, overlap, frame_superimpose)
% 
% Inputs:
% exp_folder: cell array of paths containing G4_Processed_Data.mat files
% trial_options: 1x3 logical array [pre-trial, intertrial, post-trial]
% CL_conds: matrix of closed-loop (CL) conditions to plot as histograms
% OL_conds: matrix of open-loop (OL) conditions to plot as timeseries
% TC_conds: matrix of open-loop conditions to plot as tuning curves (TC)
% overlap: logical (0 default); plots every 2 rows of conditions on a single row of axes in different colors
% frame_superimpose: logical (0 default) plots the frame position underneath each timeseries plot


%% user-defined parameters
%datatype options for flying data: 'LmR_chan', 'L_chan', 'R_chan', 'F_chan', 'Frame Position', 'LmR', 'LpR'
%datatype options for walking data: 'Vx0_chan', 'Vx1_chan', 'Vy0_chan', 'Vy1_chan', 'Frame Position', 'Turning', 'Forward', 'Sideslip'
CL_datatypes = {'Frame Position'}; %datatypes to plot as histograms
OL_datatypes = {'LmR'}; %datatypes to plot as timeseries
TC_datatypes = {'LmR'}; %datatypes to plot as tuning curves

%specify plot properties
rep_Colors = [0.5 0.5 0.5; 1 0.5 0.5; 0.5 0.5 1]; %default 3 colors supports up to 3 groups (add more colors for more groups)
mean_Colors = [0 0 0;1 0 0; 0 0 1]; %default 3 colors supports up to 3 groups (add more colors for more groups)
frame_color = [0.7 0.7 0.7]; %color of the frame position timeseries (if frame_superimpose=1)
frame_scale = 0.5; %sets the y-size of the superimposed frame timeseries, relative to the y-size of the timeseries data
rep_LineWidth = 0.05;
mean_LineWidth = 1;
patch_alpha = 0.3; %sets the level of transparency for patch region around timeseries data
subtitle_FontSize = 8;
timeseries_ylimits = [-1.1 1.1; -1 6; -1 6; -1 6; 1 192; -1.1 1.1; 2 20; -1.1 1.1]; %[min max] y limits for each datatype (including 1 additional for 'faLmR' option)
timeseries_xlimits = [0 4];
histogram_ylimits = [0 100; -6 6; 2 10];

%set data normalization options
normalize_option = 0; %0 = don't normalize, 1 = normalize every fly, 2 = normalize every group
normalize_to_baseline = {'LpR'}; %datatypes to normalize by setting the baseline value to 1
baseline_startstop = [0 1]; %start and stop times to use for baseline normalization
normalize_to_max = {'LmR'}; %datatypes to normalize by setting the maximum (or minimum) values to +1 (or -1)
max_startstop = [1 3]; %start and stop times to use for max normalization
max_prctile = 98; %percentile to use as a more robust estimate of the maximum value


%% load first data file and prepare for plotting
%load G4_Processed_Data
files = dir(exp_folder{1,1});
try
    Data_name = files(contains({files.name},{'G4_Processed_Data'})).name;
catch
    error('cannot find TDMSlogs file in specified folder')
end
load(fullfile(exp_folder{1,1},Data_name),'Data');
[num_groups, num_exps] = size(exp_folder);
CombData.timestamps = Data.timestamps;
CombData.channelNames = Data.channelNames;
CombData.conditionModes = Data.conditionModes;
CombData.histograms = nan([num_groups, num_exps, size(Data.histograms)]);
CombData.interhistogram = nan([num_groups, num_exps, size(Data.interhistogram)]);
CombData.timeseries = nan([num_groups, num_exps, size(Data.timeseries)]);
CombData.summaries = nan([num_groups, num_exps, size(Data.summaries)]);
            
%create default matrices for plotting all conditions
if nargin<5 
    default_W = [2 2 2 2 3 3 3 3 3 3 3 3 4 4 4 4 4 4 4 4 5 5 5 5 5 5 5 5 5 5]; %width of figure by number of subplots
    default_H = [1 1 2 2 2 2 3 3 3 4 4 4 4 4 4 4 5 5 5 5 5 5 5 5 5 6 6 6 6 6]; %height of figure by number of subplots
    
    %find all open-loop conditions, organize into block
    conds_vec = find(Data.conditionModes~=4); 
    num_conds = length(conds_vec);
    W = default_W(min([num_conds length(default_W)])); %get number of subplot columns (up to default limit)
    H = default_H(min([num_conds length(default_W)])); %get number of subplot rows
    D = ceil(num_conds/length(default_W)); %number of figures
    OL_conds = nan([W H D]);
    OL_conds(1:num_conds) = conds_vec;
    OL_conds = permute(OL_conds,[2 1 3]);
    
    %find all closed-loop conditions, organize into block
    conds_vec = find(Data.conditionModes==4); 
    num_conds = length(conds_vec);
    W = default_W(min([num_conds length(default_W)])); %get number of subplot columns (up to default limit)
    H = default_H(min([num_conds length(default_W)])); %get number of subplot rows
    D = ceil(num_conds/length(default_W)); %number of figures
    CL_conds = nan([W H D]);
    CL_conds(1:num_conds) = conds_vec;
    CL_conds = permute(CL_conds,[2 1 3]);
    
    TC_conds = []; %by default, don't plot any tuning curves
end
if nargin<6
    overlap = 0; %by default, don't overlap multiple conditions on same plot
    frame_superimpose = 0; %by default, don't superimpose frame position on same plot
end
overlap = logical(overlap);

%get datatype indices
Frame_ind = find(strcmpi(Data.channelNames.timeseries,'Frame Position'));
for i = 1:length(OL_datatypes)
    ind = find(strcmpi(Data.channelNames.timeseries,OL_datatypes{i}));
    assert(~isempty(ind),['could not find ' OL_datatypes{i} ' datatype'])
    OL_inds(i) = ind;
end
for i = 1:length(CL_datatypes)
    ind = find(strcmpi(Data.channelNames.histograms,CL_datatypes{i}));
    assert(~isempty(ind),['could not find ' CL_datatypes{i} ' datatype'])
    CL_inds(i) = ind;
end
for i = 1:length(TC_datatypes)
    ind = find(strcmpi(Data.channelNames.timeseries,TC_datatypes{i}));
    assert(~isempty(ind),['could not find ' TC_datatypes{i} ' datatype'])
    TC_inds(i) = ind;
end


%% load all data files
for g = 1:num_groups
    for e = 1:num_exps
        if ~isempty(exp_folder{g,e})
            %load Data file
            files = dir(exp_folder{g,e});
            try
                Data_name = files(contains({files.name},{'G4_Processed_Data'})).name;
            catch
                error(['cannot find G4_Processed_Data file in ' exp_folder{g,e}])
            end
            load(fullfile(exp_folder{g,e},Data_name),'Data');

            %check Data file for consistency with previously loaded Data files
            num_datapoints = size(Data.timeseries,4);
            if num_datapoints>size(CombData.timeseries,6)
                CombData.timeseries(:,:,:,:,:,size(CombData.timeseries,6)+1:num_datapoints) = nan;
                CombData.timestamps = Data.timestamps;
            end
            num_positions = size(Data.histograms,4);
            if num_positions>size(CombData.histograms,6)
                CombData.timeseries(:,:,:,:,:,size(CombData.histograms,6)+1:num_positions) = nan;
            end
            assert(all(size(Data.timeseries(:,:,:,1))==size(squeeze(CombData.timeseries(1,1,:,:,:,1)))),...
                ['Data in ' exp_folder{g,e} 'appears to be the incorrect size']);

            %load Data file into larger struct
            try
                CombData.histograms(g,e,:,:,:,1:num_positions) = Data.histograms; %[group, exp, type, cond, rep, position]
                CombData.interhistogram(g,e,:,:) = Data.interhistogram; %[group, exp, rep, position]
                CombData.timeseries(g,e,:,:,:,1:num_datapoints) = Data.timeseries; %[group, exp, type, cond, rep, data]
                CombData.summaries(g,e,:,:,:) = Data.summaries; %[group, exp, type, cond, rep]
            catch
                error(['could not load exp ' exp_folder{g,e}])
            end
        end
    end
end
[~, ~, num_datatypes, num_conds, num_reps, num_datapoints] = size(CombData.timeseries);
num_positions = size(CombData.histograms,6);


%% normalize data
if normalize_option>0
    base_start = find(CombData.timestamps>=baseline_startstop(1),1);
    base_stop = find(CombData.timestamps<=baseline_startstop(2),1,'last');
    max_start = find(CombData.timestamps>=max_startstop(1),1);
    max_stop = find(CombData.timestamps<=max_startstop(2),1,'last');
    if normalize_option==1
        datalen = numel(CombData.timeseries(1,1,1,:,:,base_start:base_stop));
        tmpdata = reshape(CombData.timeseries(:,:,:,:,:,base_start:base_stop),[num_groups num_exps num_datatypes datalen]);
        baselines = repmat(nanmean(tmpdata,4),[1 1 1 num_conds num_reps num_datapoints]);
        datalen = numel(CombData.timeseries(1,1,1,:,:,max_start:max_stop));
        tmpdata = reshape(CombData.timeseries(:,:,:,:,:,max_start:max_stop),[num_groups num_exps num_datatypes datalen]);
        maxs = repmat(prctile(tmpdata,max_prctile,4),[1 1 1 num_conds num_reps num_datapoints]);
    elseif normalize_option==2
        tmptimeseries = permute(CombData.timeseries,[1 3 2 4 5 6]); %[group type exp cond rep datapoint]
        datalen = numel(tmptimeseries(1,1,:,:,:,base_start:base_stop));
        tmpdata = reshape(tmptimeseries(:,:,:,:,:,base_start:base_stop),[num_groups num_datatypes datalen]);
        baselines = repmat(nanmean(tmpdata,3),[1 1 num_exps num_conds num_reps num_datapoints]);
        baselines = permute(baselines,[1 3 2 4 5 6]); %[group exp type cond rep datapoint]
        datalen = numel(tmptimeseries(1,1,:,:,:,max_start:max_stop));
        tmpdata = reshape(tmptimeseries(:,:,:,:,:,max_start:max_stop),[num_groups num_datatypes datalen]);
        maxs = repmat(prctile(tmpdata,max_prctile,3),[1 1 num_exps num_conds num_reps num_datapoints]);
        maxs = permute(maxs,[1 3 2 4 5 6]); %[group exp type cond rep datapoint]
    end
    for datatype = normalize_to_baseline
        d = find(strcmpi(Data.channelNames.timeseries,datatype));
        CombData.timeseries(:,:,d,:,:,:) = CombData.timeseries(:,:,d,:,:,:)./baselines(:,:,d,:,:,:);
        CombData.summaries(:,:,d,:,:) = CombData.summaries(:,:,d,:,:)./baselines(:,:,d,:,:,1);
        d = find(strcmpi(Data.channelNames.histograms,datatype));
        CombData.histograms(:,:,d,:,:,:) = CombData.histograms(:,:,d,:,:,:)./repmat(baselines(:,:,d,:,:,1),[1 1 1 1 1 num_positions]);
    end
    for datatype = normalize_to_max
        d = find(strcmpi(Data.channelNames.timeseries,datatype));
        CombData.timeseries(:,:,d,:,:,:) = CombData.timeseries(:,:,d,:,:,:)./maxs(:,:,d,:,:,:);
        CombData.summaries(:,:,d,:,:) = CombData.summaries(:,:,d,:,:)./maxs(:,:,d,:,:,1);
        d = find(strcmpi(Data.channelNames.histograms,datatype));
        CombData.histograms(:,:,d,:,:,:) = CombData.histograms(:,:,d,:,:,:)./repmat(maxs(:,:,d,:,:,1),[1 1 1 1 1 num_positions]);
    end
end


%% plot data
%calculate overall measurements and plot basic histograms
figure()
num_TC_datatypes = length(TC_datatypes);
for g = 1:num_groups
    for d = 1:num_TC_datatypes
        data_vec = reshape(CombData.timeseries(g,:,TC_inds(d),:,:,:),[1 numel(CombData.timeseries(g,:,d,:,:,:))]);
        datastr = TC_datatypes{d};
        datastr(strfind(datastr,'_')) = '-'; %convert underscores to dashes to prevent subscripts
    
        subplot(2+num_TC_datatypes,num_groups,g)
        text(0.1, 1.25-0.3*d, ['Mean ' TC_datatypes{d} ' = ' num2str(nanmean(data_vec))]);
        axis off
        hold on
        title(['Group ' num2str(g)],'FontSize',subtitle_FontSize);
        
        subplot(2+num_TC_datatypes,num_groups,d*num_groups+g)
        avg = length(data_vec)/100;
        hist(data_vec,100)
        hold on
        xl = xlim;
        plot(xl,[avg avg],'--','Color',rep_Colors(g,:)','LineWidth',mean_LineWidth)
        title([datastr ' Histogram'],'FontSize',subtitle_FontSize);
    end
    
    if trial_options(2)==1
        subplot(2+num_TC_datatypes,num_groups,(1+num_TC_datatypes)*num_groups+g)
        plot(squeeze(nanmean(CombData.interhistogram(g,:,:,:),3))','Color',rep_Colors(g,:),'LineWidth',rep_LineWidth)
        hold on
        plot(squeeze(nanmean(nanmean(CombData.interhistogram(g,:,:,:),3),2)),'Color',mean_Colors(g,:),'LineWidth',mean_LineWidth)
        title('Intertrial Pattern Frame Histogram','FontSize',subtitle_FontSize)
    end
end


%plot histograms for closed-loop trials
if ~isempty(CL_conds)
    num_figs = size(CL_conds,3);
    for d = CL_inds
        for fig = 1:num_figs
            num_plot_rows = (1-overlap/2)*max(nansum(CL_conds(:,:,fig)>0));
            num_plot_cols = max(nansum(CL_conds(:,:,fig)>0,2));
            figure('Position',[100 100 540 540*(num_plot_rows/num_plot_cols)])
            for row = 1:num_plot_rows
                for col = 1:num_plot_cols
                    cond = CL_conds(1+(row-1)*(1+overlap),col,fig);
                    if cond>0
                        better_subplot(num_plot_rows, num_plot_cols, col+num_plot_cols*(row-1))
                        hold on
                        [~, num_exps, ~, ~, ~, num_positions] = size(CombData.histograms);
                        x = circshift(1:num_positions,[1 floor(num_positions/2)]);
                        x(x>x(end)) = x(x>x(end))-num_positions;
                        for g = 1:num_groups
                            tmpdata = circshift(squeeze(nanmean(CombData.histograms(g,:,d,cond,:,:),5)),[1 num_positions/2]);
                            if num_groups==1 && overlap==0 %plot individual trials only if plotting one data group (otherwise it's too messy)
                                plot(repmat(x',[1 num_exps]),tmpdata','Color',rep_Colors(g,:),'LineWidth',rep_LineWidth);
                            end
                            plot(x,nanmean(tmpdata),'Color',mean_Colors(g,:),'LineWidth',mean_LineWidth)
                        end
                        ylim(histogram_ylimits(d,:));
                        titlestr = ['\fontsize{' num2str(subtitle_FontSize) '} Condition #{\color[rgb]{' num2str(mean_Colors(g,:)) '}' num2str(cond)]; 
                        if overlap==1
                            cond = CL_conds(row*2,col,fig);
                            if cond>0
                                titlestr = [titlestr ' \color[rgb]{' num2str(rep_Colors(g,:)) '}(' num2str(cond) ')'];
                                for g = 1:num_groups
                                    tmpdata = circshift(squeeze(nanmean(CombData.histograms(g,:,d,cond,:,:),5)),[1 num_positions/2]);
                                    plot(x,nanmean(tmpdata),'Color',rep_Colors(g,:),'LineWidth',mean_LineWidth)
                                end
                            end
                        end
                        title([titlestr '}'])
                    end
                end
            end
        end
    end
end

%plot timeseries data for open-loop trials
if ~isempty(OL_conds)
    num_figs = size(OL_conds,3);
    num_exps = size(CombData.timeseries,2);
    %loop for different data types
    for d = OL_inds
        for fig = 1:num_figs
            num_plot_rows = (1-overlap/2)*max(nansum(OL_conds(:,:,fig)>0));
            num_plot_cols = max(nansum(OL_conds(:,:,fig)>0,2));
            figure('Position',[100 100 540 540*(num_plot_rows/num_plot_cols)])
            for row = 1:num_plot_rows
                for col = 1:num_plot_cols
                    cond = OL_conds(1+(row-1)*(1+overlap),col,fig);
                    if cond>0
                        better_subplot(num_plot_rows, num_plot_cols, col+num_plot_cols*(row-1))
                        hold on
                        for g = 1:num_groups
                            tmpdata = squeeze(nanmean(CombData.timeseries(g,:,d,cond,:,:),5));
                            meandata = nanmean(tmpdata);
                            nanidx = isnan(meandata);
                            stddata = nanstd(tmpdata);
                            semdata = stddata./sqrt(sum(max(~isnan(tmpdata),[],2)));
                            timestamps = CombData.timestamps(~nanidx);
                            meandata(nanidx) = []; 
                            semdata(nanidx) = []; 
                            plot(timestamps,meandata,'Color',mean_Colors(g,:),'LineWidth',mean_LineWidth);
                            patch([timestamps fliplr(timestamps)],[meandata+semdata fliplr(meandata-semdata)],'k','FaceColor',mean_Colors(g,:),'EdgeColor','none','FaceAlpha',patch_alpha)
                        end
                        titlestr = ['\fontsize{' num2str(subtitle_FontSize) '} Condition #{\color[rgb]{' num2str(mean_Colors(g,:)) '}' num2str(cond)]; 
                        ylim(timeseries_ylimits(d,:));
                        xlim(timeseries_xlimits)
                        if frame_superimpose==1
                            yrange = diff(timeseries_ylimits(d,:));
                            framepos = squeeze(nanmedian(nanmedian(nanmedian(CombData.timeseries(:,:,Frame_ind,cond,:,:),5),2),1))';
                            framepos = (frame_scale*framepos/max(framepos))+timeseries_ylimits(d,1)-frame_scale*yrange;
                            ylim([timeseries_ylimits(d,1)-frame_scale*yrange timeseries_ylimits(d,2)])
                            plot(CombData.timestamps,framepos,'Color',frame_color,'LineWidth',mean_LineWidth);
                        end
                        if overlap==1
                            cond = OL_conds(row*2,col,fig);
                            if cond>0
                                titlestr = [titlestr ' \color[rgb]{' num2str(rep_Colors(g,:)) '}(' num2str(cond) ')'];
                                for g = 1:num_groups
                                    tmpdata = squeeze(nanmean(CombData.timeseries(g,:,d,cond,:,:),5));
                                    meandata = nanmean(tmpdata);
                                    nanidx = isnan(meandata);
                                    stddata = nanstd(tmpdata);
                                    semdata = stddata./sqrt(sum(max(~isnan(tmpdata),[],2)));
                                    timestamps = CombData.timestamps(~nanidx);
                                    meandata(nanidx) = []; 
                                    semdata(nanidx) = []; 
                                    plot(timestamps,meandata,'Color',mean_Colors(g,:),'LineWidth',mean_LineWidth);
                                    patch([timestamps fliplr(timestamps)],[meandata+semdata fliplr(meandata-semdata)],'k','FaceColor',mean_Colors(g,:),'EdgeColor','none','FaceAlpha',patch_alpha)
                                end
                            end
                        end
                        title([titlestr '}'])
                    end
                end
            end
        end
    end
end

%plot tuning-curves for specified open-loop trials
if ~isempty(TC_conds)
    num_figs = size(TC_conds,3);
    %loop for different data types
    for d = TC_inds
        for fig = 1:num_figs
            num_plot_rows = (1-overlap/2)*max(nansum(TC_conds(:,:,fig)>0));
            figure('Position',[100 100 540/num_plot_rows 540])
            for row = 1:num_plot_rows
                conds = TC_conds(1+(row-1)*(1+overlap),:,fig);
                conds(isnan(conds)|conds==0) = [];
                better_subplot(num_plot_rows, 1, row)
                hold on
                for g = 1:num_groups
                    tmpdata = squeeze(nanmean(CombData.summaries(g,:,d,conds,:),5));
                    if num_groups==1 && overlap==0 
                        plot(tmpdata','Color',rep_Colors(g,:),'LineWidth',rep_LineWidth);
                    end
                    plot(nanmean(tmpdata),'Color',mean_Colors(g,:),'LineWidth',mean_LineWidth);
                end
                ylim(timeseries_ylimits(d,:));
                titlestr = ['\fontsize{' num2str(subtitle_FontSize) '} Condition #{\color[rgb]{' num2str(mean_Colors(g,:)) '}' num2str(cond)]; 
                if overlap==1
                    conds = TC_conds(row*2,:,fig);
                    conds(isnan(conds)|conds==0) = [];
                    titlestr = [titlestr ' \color[rgb]{' num2str(rep_Colors(g,:)) '}(' num2str(cond) ')'];
                    for g = 1:num_groups
                        tmpdata = squeeze(nanmean(CombData.summaries(g,:,d,conds,:),5));
                        plot(nanmean(tmpdata),'Color',rep_Colors(g,:),'LineWidth',mean_LineWidth);
                    end
                end
                title([titlestr '}'])
            end
        end
    end
end

