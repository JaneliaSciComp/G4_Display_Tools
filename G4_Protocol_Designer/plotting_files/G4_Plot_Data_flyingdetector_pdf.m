% This function must be run using the publish command in order to create
% the .pdf file. The syntax is
% publish(G4_Plot_Data_flyingdetector(exp_folder, trial_options,
% metadata),options) where "options" contains the following:
%options.format = 'pdf';
%options.outputDir = path to the fly's results folder;
%options.showCode = false;

function G4_Plot_Data_flyingdetector_pdf(exp_folder, trial_options, metadata_for_publishing, CL_conds, OL_conds, TC_conds, overlap)
% Inputs:
% exp_folder: path containing G4_Processed_Data.mat file
% trial_options: 1x3 logical array [pre-trial, intertrial, post-trial]
% metadata_for_publishing: a struct of all metadata from an experiment
% which displays on the first page of the pdf report.
% CL_conds: matrix of closed-loop (CL) conditions to plot as histograms
% OL_conds: matrix of open-loop (OL) conditions to plot as timeseries
% TC_conds: matrix of open-loop conditions to plot as tuning curves (TC)
% overlap: logical (0 default); plots every 2 rows of conditions on a single row of axes in different colors

%% Metadata
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
    disp("Fly Age:  " + metadata_for_publishing.fly_age + newline);
    disp("Fly Sex:  " + metadata_for_publishing.fly_sex + newline);
    disp("Experiment Temperature:  " + metadata_for_publishing.experiment_temp + newline);
    disp("Fly Rearing Protocol:  " + metadata_for_publishing.rearing_protocol + newline);
    disp("Light Cycle:  " + metadata_for_publishing.light_cycle + newline);
    disp("Processing performed?   " + metadata_for_publishing.do_processing + newline);
    disp("Plotting performed?   " + metadata_for_publishing.do_plotting + newline);
    disp("Processing Protocol Used:   " + metadata_for_publishing.processing_protocol + newline);
    disp("Plotting Protocol Used:   " + metadata_for_publishing.plotting_protocol + newline);
    disp("Results Folder Location:  " + metadata_for_publishing.fly_results_folder + newline);
    
    disp("Other Metadata Comments:  " + metadata_for_publishing.comments + newline);
    
%%%% user-defined parameters
%datatype options: 'LmR_chan', 'L_chan', 'R_chan', 'F_chan', 'Frame Position', 'LmR', 'LpR'
CL_datatypes = {'Frame Position','LmR','LpR'}; %datatypes to plot as histograms
OL_datatypes = {'LmR','LpR'}; %datatypes to plot as timeseries
TC_datatypes = {'LmR','LpR'}; %datatypes to plot as tuning curves

%specify plot properties
rep_Color = [0.5 0.5 1];
mean_Color = [0 0 1];
rep_Color2 = [1 0.5 0.5];
mean_Color2 = [1 0 0];
rep_LineWidth = 0.05;
mean_LineWidth = 1;
subtitle_FontSize = 8;
timeseries_ylimits = [-6 6; -1 6; -1 6; -1 6; 1 192; -6 6; 2 20]; %[min max] y limits for each datatype
histogram_ylimits = [0 100; -6 6; 2 10];

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
load(fullfile(exp_folder,Data_name),'Data');

%create default matrices for plotting all conditions
if nargin<6 
    default_W = [2 2 2 2 3 3 3 3 3 3 3 3 4 4 4 4 4 4 4 4 5 5 5 5 5 5 5 5 5 5]; %width of figure by number of subplots
    default_H = [1 1 2 2 2 2 3 3 3 4 4 4 4 4 4 4 5 5 5 5 5 5 5 5 5 6 6 6 6 6]; %height of figure by number of subplots
    
    %find all open-loop conditions, organize into block
    OL_conds_vec = find(Data.conditionModes~=4); %changed conds_vec to OL_conds_vec
    num_conds = length(OL_conds_vec);
    if num_conds > 0
        W = default_W(min([num_conds length(default_W)])); %get number of subplot columns (up to default limit)
        H = default_H(min([num_conds length(default_W)])); %get number of subplot rows
        D = ceil(num_conds/length(default_W)); %number of figures
        OL_conds = nan([W H D]);
        OL_conds(1:num_conds) = OL_conds_vec;
        OL_conds = permute(OL_conds,[2 1 3]);
    else
        OL_conds = [];
    end
      
    
    %find all closed-loop conditions, organize into block
    CL_conds_vec = find(Data.conditionModes==4); %changed single equal sign to double and conds_vec to CL_conds_vec
    num_conds = length(CL_conds_vec);
    if num_conds > 0
        W = default_W(min([num_conds length(default_W)])); %get number of subplot columns (up to default limit)
        H = default_H(min([num_conds length(default_W)])); %get number of subplot rows
        D = ceil(num_conds/length(default_W)); %number of figures
        CL_conds = nan([W H D]);
        CL_conds(1:num_conds) = CL_conds_vec;
        CL_conds = permute(CL_conds,[2 1 3]);
    else %Added this if statement because lines 88-90 went out of bounds when there were no closed loop conditions - LT
        CL_conds = [];
    end
    
    
    TC_conds = []; %by default, don't plot any tuning curves
    
end
if nargin < 7
    overlap = 0; %by default, don't overlap multiple conditions on same plot
end
overlap = logical(overlap);

%get datatype indices
num_OL_datatypes = length(OL_datatypes);
OL_inds = nan(1,num_OL_datatypes);
for d = 1:num_OL_datatypes
    OL_inds(d) = find(strcmpi(Data.channelNames.timeseries,OL_datatypes{d}));
end
num_CL_datatypes = length(CL_datatypes);
CL_inds = nan(1,num_CL_datatypes);
for d = 1:num_CL_datatypes
    CL_inds(d) = find(strcmpi(Data.channelNames.histograms,CL_datatypes{d})); %%% now correctly looks for CL_inds from histogram names
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
    
    
end

if trial_options(2)==1
    subplot(2,num_TC_datatypes,num_TC_datatypes)
    plot(Data.interhistogram','Color',rep_Color,'LineWidth',rep_LineWidth)
    hold on
    plot(nanmean(Data.interhistogram),'Color',mean_Color,'LineWidth',mean_LineWidth)
    title('Intertrial Pattern Frame Histogram','FontSize',subtitle_FontSize)
    
    
end
snapnow;

%% Histograms for closed-loop trials
if ~isempty(CL_conds)
    num_figs = size(CL_conds,3);
    for d = CL_inds
        for fig = 1:num_figs
            num_plot_rows = (1-overlap/2)*max(nansum(CL_conds(:,:,fig)>0)); 
            num_plot_cols = max(nansum(CL_conds(:,:,fig)>0,2));
            figure('Position',[100 100 540 540*(num_plot_rows/num_plot_cols)])
            for row = 1:num_plot_rows
                for col = 1:num_plot_cols
                    cond = CL_conds(1+(row-1)*(1+overlap),col,fig); %should be correct now
                    if cond>0 
                        better_subplot(num_plot_rows, num_plot_cols, col+num_plot_cols*(row-1))
                        [~, ~, num_reps, num_positions] = size(Data.histograms);
                        x = circshift(1:num_positions,[1 floor(num_positions/2)]);
                        x(x>x(end)) = x(x>x(end))-num_positions;
                        tmpdata = circshift(squeeze(Data.histograms(d,cond,:,:)),[1 floor(num_positions/2)]); %changed to floor to match x
                        plot(repmat(x',[1 num_reps]),tmpdata','Color',rep_Color,'LineWidth',rep_LineWidth);
                        hold on
                        plot(x,nanmean(tmpdata),'Color',mean_Color,'LineWidth',mean_LineWidth)
                        ylim(histogram_ylimits(d,:));
                        title(['Condition #' num2str(cond)],'FontSize',subtitle_FontSize)
                        
                    end
                    if overlap==1
                        cond = CL_conds(row*2,col,fig); 
                        if cond>0
                            tmpdata = circshift(squeeze(Data.histograms(d,cond,:,:)),[1 num_positions/2]);
                            plot(repmat(x',[1 num_reps]),tmpdata','Color',rep_Color2,'LineWidth',rep_LineWidth);
                            plot(x,nanmean(tmpdata),'Color',mean_Color2,'LineWidth',mean_LineWidth)
                            
                        end
                    end
                end
            end
            snapnow;
        end
    end
end

%% Timeseries data for open-loop trials

if ~isempty(OL_conds)
    num_figs = size(OL_conds,3);
    num_reps = size(Data.timeseries,3);
    %loop for different data types
    for d = OL_inds
        for fig = 1:num_figs
            num_plot_rows = (1-overlap/2)*max(nansum(OL_conds(:,1,fig)>0));
            num_plot_cols = max(nansum(OL_conds(1,:,fig)>0,2)); %Added 1/s to the dimensions here because it was giving twice the number rows necessary and causing line 211 to go out of bounds - LT
            figure('Position',[100 100 540 540*(num_plot_rows/num_plot_cols)])
            for row = 1:num_plot_rows
                for col = 1:num_plot_cols
                    cond = OL_conds(1+(row-1)*(1+overlap),col,fig);
                    if cond>0
                        better_subplot(num_plot_rows, num_plot_cols, col+num_plot_cols*(row-1))
                        plot(repmat(Data.timestamps',[1 num_reps]),squeeze(Data.timeseries(d,cond,:,:))','Color',rep_Color,'LineWidth',rep_LineWidth);
                        hold on
                        plot(Data.timestamps,squeeze(nanmean(Data.timeseries(d,cond,:,:),3)),'Color',mean_Color,'LineWidth',mean_LineWidth);
                        ylim(timeseries_ylimits(d,:));
                        title(['Condition #' num2str(cond)],'FontSize',subtitle_FontSize)
                    end
                    if overlap==1
                        cond = CL_conds(row*2,col,fig);
                        if cond>0
                            plot(repmat(Data.timestamps',[1 num_reps]),squeeze(Data.timeseries(d,cond,:,:))','Color',rep_Color2,'LineWidth',rep_LineWidth);
                            plot(Data.timestamps,squeeze(nanmean(Data.timeseries(d,cond,:,:),3)),'Color',mean_Color2,'LineWidth',mean_LineWidth);
                        end
                    end
                end
            end
            
            snapnow; %Only takes a snapshot every time a figure is full and about to be erased for the next one.
        end
    end
end

%% Tuning-curves for specified open-loop trials
if ~isempty(TC_conds)
    num_figs = size(TC_conds,3);
    %loop for different data types
    for d = TC_inds
        for fig = 1:num_figs
            num_plot_rows = (1-overlap/2)*max(nansum(TC_conds(:,:,fig)>0));
            figure('Position',[100 100 540/num_plot_rows 540])
            for row = 1:num_plot_rows
                conds = TC_conds(1+(row-1)*(1+overlap),:,fig);
                conds(isnan(conds)&&conds==0) = [];
                better_subplot(num_plot_rows, 1, row)
                plot(squeeze(Data.summaries(d,conds,:)),'Color',rep_Color,'LineWidth',rep_LineWidth);
                hold on
                plot(nanmean(Data.summaries(d,conds,:),3),'Color',mean_Color,'LineWidth',mean_LineWidth);
                ylim(timeseries_ylimits(d,:));
                title(['Condition #' num2str(cond)],'FontSize',subtitle_FontSize)
                if overlap==1
                    conds = TC_conds(row*2,:,fig);
                    conds(isnan(conds)&&conds==0) = [];
                    plot(squeeze(Data.summaries(d,conds,:)),'Color',rep_Color2,'LineWidth',rep_LineWidth);
                    plot(nanmean(Data.summaries(d,conds,:),3),'Color',mean_Color2,'LineWidth',mean_LineWidth);
                end
            end
            
            snapnow; %only snapshots each figure once - make sure this isn't missing anything!
        end
    end
end