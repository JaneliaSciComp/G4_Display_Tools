%%%%I have changed the format of the commenting in this file so that only
%%%%appropriate text shows up in the .pdf file being published from this. -
%%%%Lisa, 7/10/19

function G4_Plot_Data_flyingdetector_pdf(exp_folder, trial_options, metadata_for_publishing, CL_conds, OL_conds, TC_conds)
%FUNCTION G4_Plot_Data_flyingdetector(exp_folder, trial_options, CL_conds, OL_conds, TC_conds)
% 
% Inputs:
% exp_folder: path containing G4_Processed_Data.mat file
% trial_options: 1x3 logical array [pre-trial, intertrial, post-trial]
% CL_conds: matrix of closed-loop (CL) conditions to plot as histograms
% OL_conds: matrix of open-loop (OL) conditions to plot as timeseries
% TC_conds: matrix of open-loop conditions to plot as tuning curves (TC)


%% Metadata
%%%%%SECTION ADDED BY LISA TAYLOR 7/10/19
% This function must be published using the publish command in order for
% the plots to show up in the .pdf. Therefore, any metadata we want in the
% .pdf must also be part of this function. The disp commands below will
% list the metadata in the .pdf before the graphs.

     disp("Timestamp:   " + metadata_for_publishing.timestamp + newline);
    disp("Experimenter:   " + metadata_for_publishing.experimenter + newline);
    disp("Experiment Name:   " + metadata_for_publishing.experiment_name + newline);
    disp("Experiment Type:   " + metadata_for_publishing.experiment_type + newline);
    disp("Experiment Protocol Used:   " + metadata_for_publishing.experiment_protocol + newline);
    disp("Fly Name:   " + metadata_for_publishing.fly_name + newline);
    disp("Fly Genotype:   " + metadata_for_publishing.genotype + newline);
    disp("Processing performed?   " + metadata_for_publishing.do_processing + newline);
    disp("Plotting performed?   " + metadata_for_publishing.do_plotting + newline);
    disp("Processing Protocol Used:   " + metadata_for_publishing.processing_protocol + newline);
    disp("Plotting Protocol Used:   " + metadata_for_publishing.plotting_protocol + newline);

%%%% user-defined parameters
%datatype options: 'LmR_chan', 'L_chan', 'R_chan', 'F_chan', 'Frame Position', 'LmR', 'LpR'
CL_datatypes = {'Frame Position','LmR','LpR'}; %datatypes to plot as histograms
OL_datatypes = {'LmR','LpR'}; %datatypes to plot as timeseries
TC_datatypes = {'LmR','LpR'}; %datatypes to plot as tuning curves

%specify plot properties
rep_Color = [0.5 0.5 0.5];
mean_Color = [0 0 0];
rep_LineWidth = 0.05;
mean_LineWidth = 1;
subtitle_FontSize = 8;
ylimits = [-6 6; -1 6; -1 6; -1 6; 1 192; -6 6; 2 10]; %[min max] y limits for each datatype

%%%% load data and prepare for plotting
%load G4_Processed_Data
if nargin==0
    exp_folder = uigetdir('C:/','Select a folder containing a G4_Processed_Data file');
    trial_options = [1 1 1];
end
files = dir(exp_folder);
try
    Data_name = files(contains({files.name},{'G4_Processed_Data'})).name;
catch
    error('cannot find G4_Processed_Data file in specified folder')
end
load(fullfile(exp_folder,Data_name));

%create default matrices for plotting all conditions
if nargin<5 
    CL_conds = find(Data.conditionModes(:,1)==4); %all closed-loop modes
    OL_conds = find(Data.conditionModes(:,1)~=4); %all open-loop modes
    TC_conds = []; %by default, don't plot any tuning curves
    CL_tmp = nan([round(sqrt(numel(CL_conds))) ceil(sqrt(numel(CL_conds)))]);
    CL_tmp(1:length(CL_conds)) = CL_conds;
    CL_conds = CL_tmp';
    %CL_conds = reshape(CL_conds,[round(sqrt(numel(CL_conds))) ceil(sqrt(numel(CL_conds)))])';
    OL_tmp = nan([round(sqrt(numel(OL_conds))) ceil(sqrt(numel(OL_conds)))]);
    OL_tmp(1:length(OL_conds)) = OL_conds;
    OL_conds = OL_tmp';
    %OL_conds = reshape(OL_conds,[round(sqrt(numel(OL_conds))) ceil(sqrt(numel(OL_conds)))])';
end

%get datatype indices
num_OL_datatypes = length(OL_datatypes);
OL_inds = nan(1,num_OL_datatypes);
for d = 1:num_OL_datatypes
    OL_inds(d) = find(strcmpi(Data.channelNames.timeseries,OL_datatypes{d}));
end
num_CL_datatypes = length(CL_datatypes);
CL_inds = nan(1,num_CL_datatypes);
for d = 1:num_CL_datatypes
    CL_inds(d) = find(strcmpi(Data.channelNames.timeseries,CL_datatypes{d}));
end
num_TC_datatypes = length(TC_datatypes);
TC_inds = nan(1,num_TC_datatypes);
for d = 1:num_TC_datatypes
    TC_inds(d) = find(strcmpi(Data.channelNames.timeseries,TC_datatypes{d}));
end


%%%% plot data
%calculate overall measurements and plot basic histograms
%% Basic Histograms
figure()
for d = 1:num_TC_datatypes
    subplot(2,num_TC_datatypes,1)
    datastr = TC_datatypes{d};
    datastr(strfind(datastr,'_')) = '-'; %convert underscores to dashes to prevent subscripts
    data_vec = reshape(Data.timeseries(TC_inds(d),:,:,:),[1 numel(Data.timeseries(TC_inds(d),:,:,:))]);
    text(0.1, 0.9-0.2*d, ['Mean ' datastr ' = ' num2str(nanmean(data_vec))]);
    axis off
    hold on
    
    subplot(2,num_TC_datatypes,num_TC_datatypes+d)
    avg = length(data_vec)/100;
    hist(data_vec,100)
    hold on
    xl = xlim;
    plot(xl,[avg avg],'--','Color',rep_Color','LineWidth',mean_LineWidth)
    title([datastr ' Histogram'],'FontSize',subtitle_FontSize);
    
    snapnow; %%%LT 7/10
end
if trial_options(2)==1
    subplot(2,num_TC_datatypes,num_TC_datatypes)
    plot(Data.interhistogram','Color',rep_Color,'LineWidth',rep_LineWidth)
    hold on
    plot(nanmean(Data.interhistogram),'Color',mean_Color,'LineWidth',mean_LineWidth)
    title('Intertrial Pattern Frame Histogram','FontSize',subtitle_FontSize)
    
    snapnow; %%%LT 7/10
end

%% plot histograms for closed-loop trials
if ~isempty(CL_conds)
    num_figs = size(CL_conds,3);
    for d = CL_inds
        for fig = 1:num_figs
            num_plot_rows = max(nansum(CL_conds(:,:,fig)>0));
            num_plot_cols = max(nansum(CL_conds(:,:,fig)>0,2));
            figure()
            for row = 1:num_plot_rows
                for col = 1:num_plot_cols
                    cond = CL_conds(row,col,fig);
                    if cond>0
                        subplot(num_plot_rows, num_plot_cols, col+num_plot_cols*(row-1))
                        [~, ~, num_reps, num_positions] = size(Data.histograms);
                        x = circshift(1:num_positions,[1 num_positions/2]);
                        x(x>x(end)) = x(x>x(end))-num_positions;
                        tmpdata = circshift(squeeze(Data.histograms(d,cond,:,:)),[1 num_positions/2]);
                        plot(repmat(x',[1 num_reps]),tmpdata','Color',rep_Color,'LineWidth',rep_LineWidth);
                        hold on
                        plot(x,nanmean(tmpdata),'Color',mean_Color,'LineWidth',mean_LineWidth)
                        ylim(ylimits(d,:));
                        title(['Condition #' num2str(cond)],'FontSize',subtitle_FontSize)
                        
                        snapnow;  %%%LT 7/10
                    end
                end
            end
        end
    end
end

%% plot timeseries data for open-loop trials
if ~isempty(OL_conds)
    num_figs = size(OL_conds,3);
    num_reps = size(Data.timeseries,3);
    %loop for different data types
    for d = 1:OL_inds
        for fig = 1:num_figs
            num_plot_rows = max(nansum(OL_conds(:,:,fig)>0));
            num_plot_cols = max(nansum(OL_conds(:,:,fig)>0,2));
            figure()
            for row = 1:num_plot_rows
                for col = 1:num_plot_cols
                    cond = OL_conds(row,col,fig);
                    if ~isnan(cond)
                        subplot(num_plot_rows, num_plot_cols, col+num_plot_cols*(row-1))
                        subplot(num_plot_rows, num_plot_cols, col+num_plot_cols*(row-1))
                        plot(repmat(Data.timestamps',[1 num_reps]),squeeze(Data.timeseries(d,cond,:,:))','Color',rep_Color,'LineWidth',rep_LineWidth);
                        hold on
                        plot(Data.timestamps,squeeze(nanmean(Data.timeseries(d,cond,:,:),3)),'Color',mean_Color,'LineWidth',mean_LineWidth);
                        ylim(ylimits(d,:));
                        title(['Condition #' num2str(cond)],'FontSize',subtitle_FontSize)
                        
                        snapnow; %%%LT 7/10
                    end
                end
            end
            
            %put snapnow here instead? 
        end
    end
end

%% plot tuning-curves for specified open-loop trials
if ~isempty(TC_conds)
    num_figs = size(TC_conds,3);
    %loop for different data types
    for d = 1:TC_inds
        for fig = 1:num_figs
            num_plot_rows = max(nansum(TC_conds(:,:,fig)>0));
            figure()
            for row = 1:num_plot_rows
                conds = TC_conds(row,:,fig);
                conds(isnan(conds)) = [];
                subplot(num_plot_rows, 1, row)
                plot(squeeze(Data.summaries(d,conds,:)),'Color',rep_Color,'LineWidth',rep_LineWidth);
                hold on
                plot(nanmean(Data.summaries(d,conds,:),3),'Color',mean_Color,'LineWidth',mean_LineWidth);
                ylim(ylimits(d,:));
                title(['Condition #' num2str(cond)],'FontSize',subtitle_FontSize)
                
                snapnow; %%%LT 7/10
            end
        end
    end
end