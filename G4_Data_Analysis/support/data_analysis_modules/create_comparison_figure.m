function create_comparison_figure(CombData, gen_settings, comp_settings, ts_settings, ...
    pos_settings, mp_settings,P, M, P_flies, M_flies, single, save_settings,...
    genotype, control_genotype)
    
    %This figure should have one row per condition. Each row containing
    %four types of plot: 

    %Timeseries plot
    %Position series
    %M plot
    %P plot
    
    %Need to know:
    %Which conditions
    %Which datatypes to do timeseries for 
    conditions = comp_settings.conditions;
    plot_order = comp_settings.plot_order;
    num_rows = comp_settings.rows_per_fig;
    num_groups = size(M,1);
    
   
    
    if ~isempty(plot_order)
        plot_order = {'LmR', 'pos', 'M', 'P'};
    end
    num_cols = length(plot_order);    
    plot_both_dir_ts = ts_settings.plot_both_directions;
    plot_both_dir_pos = pos_settings.plot_opposing_directions;
    num_conds = length(conditions);
    if isempty(num_rows) || num_rows == 0
        num_rows = 6;
    end
    num_figs = ceil(num_conds/num_rows);
    show_ind_flies_ts = ts_settings.show_individual_flies;
    show_ind_flies_pos = pos_settings.show_individual_flies;
    show_ind_flies_mp = mp_settings.show_individual_flies;
    
    new_xaxis = mp_settings.new_xaxis;
    pos_xaxis = mp_settings.xaxis;
    
    fly_colors = gen_settings.fly_colors;
    mean_colors = gen_settings.mean_colors;
    rep_LineWidth = gen_settings.rep_lineWidth;
    mean_LineWidth = gen_settings.mean_lineWidth;
    control_color = gen_settings.control_color;
    EdgeColor = gen_settings.edgeColor;
    patch_alpha = gen_settings.patch_alpha;
    y_fontsize = gen_settings.yLabel_fontSize;
    legend_FontSize = gen_settings.legend_fontSize;
    axis_num_fontSize = gen_settings.axis_num_fontSize;
    subtitle_FontSize = gen_settings.subtitle_fontSize;
    figTitle_fontSize = gen_settings.figTitle_fontSize;
    ylimits = comp_settings.ylimits;
    norm = comp_settings.norm;
    
    figure_names = comp_settings.figure_names;
    cond_names = comp_settings.cond_name;
    subplot_figure_titles = comp_settings.subplot_figure_names;
    
    if ~isempty(new_xaxis)
        pos_xaxis = new_xaxis(pos_xaxis);
    end
    [pos_xaxis, xaxis_inds] = sort(pos_xaxis);
    
    if norm == 1
        timeseries_data = CombData.ts_avg_reps_norm;
    else
        timeseries_data = CombData.ts_avg_reps;
    end
    
%     if normalized 
%         timeseries_data = CombData.ts_avg_reps_norm;
%     else
%         timeseries_data = CombData.ts_avg_reps;
%     end
    timestampsIN = CombData.timestamps;
    
    for c = 1:num_cols
        bottom_places(c) = num_rows*c;
        top_places(c) = bottom_places(c) - (num_rows - 1);
    end
    for r = 1:num_rows
        left_col_places(r) = r;
    end
    
        
    
    
    if ~isempty(conditions)
        for fig = 1:num_figs
            figure('Position',[100 100 1540 1540*(num_rows/num_cols)])
            fig_name = figure_names{fig};
            cond_name = cond_names{fig};
            ydata = [];
            ydata_pos = [];
            for row = 1:num_rows
                if (fig-1)*num_rows + row > length(conditions)
                    continue;
                end
                cond = conditions((fig-1)*num_rows + row);
                for col = 1:num_cols
                    
                    place = row+num_rows*(col-1);
                    placement = col+num_cols*(row-1);
                    if cond ~= 0
                        
                         %subplot
                         
                         better_subplot(num_rows, num_cols, placement, 40, 120)
                         hold on
                         yline(0, 'k--');
                         hold on
                         
                         %Get type of plot
                         plot_type  = plot_order{col};
                         
                         if strcmp(plot_type,'LmR') || strcmp(plot_type,'LpR') || strcmp(plot_type, 'faLmR')
                             
                             d = find(strcmpi(CombData.channelNames.timeseries, plot_type));

                             for g = 1:num_groups
                                tmpdata = squeeze(timeseries_data(g,:,d,cond,:));
                                meandata = nanmean(tmpdata);
                                nanidx = isnan(meandata);
                                stddata = nanstd(tmpdata);
                                semdata = stddata./sqrt(sum(max(~isnan(tmpdata),[],2)));
                                timestamps = timestampsIN(~nanidx);
                                meandata(nanidx) = []; 
                                semdata(nanidx) = []; 
                                if single == 1
                                    plot(repmat(timestampsIN',[1 num_exps]),tmpdata','Color',mean_colors(g,:),'LineWidth',rep_LineWidth);
                                elseif num_groups==1  && show_ind_flies_ts == 1
                                    for exp = 1:num_exps
                                        plot(repmat(timestampsIN',[1 exp]),tmpdata(exp,:)','Color',fly_colors(exp,:),'LineWidth',rep_LineWidth);
                                    end

                                    plot(timestamps, meandata, 'Color', .75*mean_colors(g,:),'LineWidth', mean_LineWidth);
                                else
                                    if g == control_genotype
                                        plot(timestamps,meandata,'Color',control_color,'LineWidth',mean_LineWidth);
                                        patch([timestamps fliplr(timestamps)],[meandata+semdata fliplr(meandata-semdata)],'k','FaceColor',control_color,'EdgeColor',EdgeColor,'FaceAlpha',patch_alpha)
                                    else
                                        plot(timestamps,meandata,'Color',mean_colors(g,:),'LineWidth',mean_LineWidth);
                                        patch([timestamps fliplr(timestamps)],[meandata+semdata fliplr(meandata-semdata)],'k','FaceColor',mean_colors(g,:),'EdgeColor',EdgeColor,'FaceAlpha',patch_alpha)
                                    end
                                end

                                if plot_both_dir_ts

                                    tmpdata = squeeze(timeseries_data(g,:,d,cond+1,:));
                                    meandata = nanmean(tmpdata);
                                    nanidx = isnan(meandata);
                                    stddata = nanstd(tmpdata);
                                    semdata = stddata./sqrt(sum(max(~isnan(tmpdata),[],2)));
                                    timestamps = timestampsIN(~nanidx);
                                    meandata(nanidx) = []; 
                                    semdata(nanidx) = [];
                                    %adjust color to make opposing direction
                                    %lighter

                                    if single == 1
                                        plot(repmat(timestampsIN',[1 num_exps]),tmpdata','Color',mean_colors(g+1,:),'LineWidth',rep_LineWidth);
                                    elseif num_groups == 1
                                        plot(timestamps,meandata,'Color',mean_colors(g+1,:),'LineWidth',mean_LineWidth);
                                        patch([timestamps fliplr(timestamps)],[meandata+semdata fliplr(meandata-semdata)],'k','FaceColor',mean_colors(g+1,:),'EdgeColor',EdgeColor,'FaceAlpha',patch_alpha)
                                    else
                                        if g == control_genotype
                                            plot(timestamps,meandata,'Color',control_color + .75,'LineWidth',mean_LineWidth);
                                            patch([timestamps fliplr(timestamps)],[meandata+semdata fliplr(meandata-semdata)],'k','FaceColor',control_color,'EdgeColor',EdgeColor,'FaceAlpha',patch_alpha)

                                        else

                                            for rgb = 1:length(mean_colors(g,:))
                                                if mean_colors(g,rgb) > .75
                                                    color_adjust(rgb) = 0;
                                                elseif mean_colors(g,rgb) > .5
                                                    color_adjust(rgb) = .25;
                                                elseif mean_colors(g, rgb) > .25
                                                    color_adjust(rgb) = .5;
                                                elseif mean_colors(g,rgb) >= 0
                                                    color_adjust(rgb) = .75;

                                                end
                                            end

                                            plot(timestamps,meandata,'Color',mean_colors(g,:) + color_adjust,'LineWidth',mean_LineWidth);
                                            patch([timestamps fliplr(timestamps)],[meandata+semdata fliplr(meandata-semdata)],'k','FaceColor',mean_colors(g,:),'EdgeColor',EdgeColor,'FaceAlpha',patch_alpha)


                                        end
                                    end

                                end
                             end
                             
                             if isempty(ts_settings.axis_labels)
                                 axis_labels = ["Time(sec", plot_type];
                             else
                                 if length(plot_order) <= 4
                                     axis_labels = ts_settings.axis_labels{1};
                                 else
                                     num_ts_plot = strcmp(plot_order, plot_type);
                                     axis_labels = ts_settings.axis_labels{num_ts_plot};
                                 end
                             end

                             if ylimits ~= 0
                                ylim(ylimits);
                            else
                                lines = findobj(gca, 'Type', 'line');
                                for l = 1:length(lines)
                                    curr_ydata = lines(l).YData;
                                    mm = [min(curr_ydata), max(curr_ydata)];
                                    ydata = [ydata, mm];

                                end
                            end
                             
                         elseif strcmp(plot_type, 'pos')

                            for g = 1:num_groups

                                tmpdata = squeeze(CombData.mean_pos_series(g,:,cond,:));
                                meandata = nanmean(tmpdata);
                                nanidx = isnan(meandata);
                                stddata = nanstd(tmpdata);
                                semdata = stddata./sqrt(sum(max(~isnan(tmpdata),[],2)));
    %                             meandata(nanidx) = []; 
    %                             semdata(nanidx) = [];

                                if single
                                    plot(pos_xaxis, tmpdata', 'Color',mean_colors(g,:),'LineWidth',rep_LineWidth);
                                elseif num_groups == 1 && show_ind_flies_pos == 1

                                    %Plot each fly
                                    for exp = 1:num_exps

                                        plot(pos_xaxis, tmpdata(exp,:),'Color',fly_colors(exp,:),'LineWidth',rep_LineWidth);
                                        hold on;

                                    end
                                    %Plot average of the flies

                                    plot(pos_xaxis, meandata,'Color', .75*mean_colors(g,:),'LineWidth', mean_LineWidth);

                                else


                                    if g == control_genotype

                                        plot(pos_xaxis, meandata,'Color',control_color,'LineWidth',mean_LineWidth);


                                    else

                                        plot(pos_xaxis, meandata,'Color',mean_colors(g,:),'LineWidth',mean_LineWidth);

                                    end
                                end

                                 if plot_both_dir_pos

                                     tmpdata = squeeze(CombData.mean_pos_series(g,:,cond+1,:));
                                     meandata = nanmean(tmpdata);
                                     nanidx = isnan(meandata);
                                     stddata = nanstd(tmpdata);
                                     semdata = stddata./sqrt(sum(max(~isnan(tmpdata),[],2)));
    %                                  meandata(nanidx) = []; 
    %                                  semdata(nanidx) = [];
                                        %adjust color to make opposing direction
                                        %lighter
                                     if single
                                         plot(pos_xaxis, tmpdata','Color',mean_colors(g+1,:),'LineWidth',rep_LineWidth);
                                     elseif g == control_genotype
                                         plot(pos_xaxis, meandata,'Color',control_color + .75,'LineWidth',mean_LineWidth);
                                     else

                                         for rgb = 1:length(mean_colors(g,:))
                                             if mean_colors(g,rgb) > .75
                                                 color_adjust(rgb) = 0;
                                             elseif mean_colors(g,rgb) > .5
                                                 color_adjust(rgb) = .15;
                                             elseif mean_colors(g, rgb) > .25
                                                 color_adjust(rgb) = .35;
                                             elseif mean_colors(g,rgb) >= 0
                                                 color_adjust(rgb) = .55;
                                             end
                                          end

                                          plot(pos_xaxis, meandata,'Color',mean_colors(g,:) + color_adjust,'LineWidth',mean_LineWidth);
                                     end
                                 end
                            end
                            
                            if isempty(pos_settings.axis_labels)
                                axis_labels = ["Frame Position", "Position"];
                            else
                                axis_labels = pos_settings.axis_labels;
                            end
                            
                            if ylimits ~= 0
                                ylim(ylimits);
                            else
                                lines = findobj(gca, 'Type', 'line');
                                for l = 1:length(lines)
                                    curr_ydata = lines(l).YData;
                                    mm = [min(curr_ydata), max(curr_ydata)];
                                    ydata = [ydata, mm];

                                end
                            end
                            
%                             lines_pos = findobj(gca, 'Type', 'line');
%                             for l = 1:length(lines_pos)
%                                 curr_ydata_pos = lines_pos(l).YData;
%                                 mm_pos = [min(curr_ydata_pos), max(curr_ydata_pos)];
%                                 ydata_pos = [ydata_pos, mm_pos];
% 
%                             end

                             
                         elseif strcmp(plot_type, 'M')
                             
                   
                            if size(M,2) < (fig-1)*num_rows + row
                                continue;
                            end
                            
                            if num_groups == 1 && show_ind_flies_mp == 1
                                for fly = 1:size(M_flies,2)
                                    datatoplot = squeeze(M_flies(1, fly, ceil(cond/2), :));
                                    %datatoplot = datatoplot(xaxis_inds);
                                    plot(pos_xaxis, datatoplot,'Color',fly_colors(fly,:),'LineWidth',rep_LineWidth);
                                    hold on;

                                end
                                datatoplot = squeeze(M(1, ceil(cond/2), :));
    %                            datatoplot = datatoplot(xaxis_inds);
                                plot(pos_xaxis, datatoplot,'Color',mean_colors(1,:),'LineWidth',mean_LineWidth);

                             else

                                for g = 1:num_groups

                                    if g == control_genotype

                                        datatoplot = squeeze(M(g, ceil(cond/2), :));
                                        %datatoplot = datatoplot(xaxis_inds);
                                        plot(pos_xaxis, datatoplot,'Color',control_color,'LineWidth',mean_LineWidth);


                                    else

                                       datatoplot = squeeze(M(g, ceil(cond/2), :));
                                       % datatoplot = datatoplot(xaxis_inds);
                                        plot(pos_xaxis, datatoplot,'Color',mean_colors(g,:),'LineWidth',mean_LineWidth);


                                    end
                                end
                            end
                            
                            if isempty(mp_settings.axis_labels)
                                axis_labels = ["Frame Position", "Motion-Dependent Response"];
                            else
                                axis_labels = mp_settings.axis_labels{1};
                            end
                            
                            if ylimits ~= 0
                                ylim(ylimits);
                            else
                                lines = findobj(gca, 'Type', 'line');
                                for l = 1:length(lines)
                                    curr_ydata = lines(l).YData;
                                    mm = [min(curr_ydata), max(curr_ydata)];
                                    ydata = [ydata, mm];

                                end
                            end
                                
                             
                             
                         elseif strcmp(plot_type, 'P')
                             
                             %plot P data
                             
                             
                            
                            if size(P,2) < (fig-1)*num_rows + row
                                continue;
                            end
                            
                            if num_groups == 1 && show_ind_flies_mp == 1
                                for fly = 1:size(P_flies,2)
                                    datatoplot = squeeze(P_flies(1, fly, ceil(cond/2), :));
                                    %datatoplot = datatoplot(xaxis_inds);
                                    plot(pos_xaxis, datatoplot,'Color',fly_colors(fly,:),'LineWidth',rep_LineWidth);
                                    hold on;

                                end
                                datatoplot = squeeze(P(1, ceil(cond/2), :));
    %                            datatoplot = datatoplot(xaxis_inds);
                                plot(pos_xaxis, datatoplot,'Color',mean_colors(1,:),'LineWidth',mean_LineWidth);

                             else

                                for g = 1:num_groups

                                    if g == control_genotype

                                        datatoplot = squeeze(P(g, ceil(cond/2), :));
                                        %datatoplot = datatoplot(xaxis_inds);
                                        plot(pos_xaxis, datatoplot,'Color',control_color,'LineWidth',mean_LineWidth);


                                    else

                                       datatoplot = squeeze(P(g, ceil(cond/2), :));
                                       % datatoplot = datatoplot(xaxis_inds);
                                        plot(pos_xaxis, datatoplot,'Color',mean_colors(g,:),'LineWidth',mean_LineWidth);


                                    end
                                end
                            end
                            
                            if isempty(mp_settings.axis_labels)
                                axis_labels = ["Frame Position", "Position-Dependent Response"];
                            else
                                axis_labels = mp_settings.axis_labels{2};
                            end
                            
                            if ylimits ~= 0
                                ylim(ylimits);
                            else
                                lines = findobj(gca, 'Type', 'line');
                                for l = 1:length(lines)
                                    curr_ydata = lines(l).YData;
                                    mm = [min(curr_ydata), max(curr_ydata)];
                                    ydata = [ydata, mm];

                                end
                            end
                                
                             
                         else
                             
                             disp('Unrecognized plot type in your plot order. Check settings.');
                         end
                        
                    end
                    
                    set(gca, 'FontSize', axis_num_fontSize);
                    xlabel('')
                    ylabel('')
                    if sum(place==bottom_places)
                        
                        xlabel(axis_labels(1), 'FontSize', y_fontsize);
                        set(gca,'XTick');
                        
                    elseif sum(place==top_places)
                        ylabel(axis_labels(2), 'FontSize', y_fontsize)
                        set(gca,'YTick');
                    end
                    
                    if ~ismember(place,top_places) && ~ismember(place,left_col_places) %far-most left axis (clear all the right subplots)
                          currGraph = gca; 
                          currGraph.YAxis.Visible = 'off';
                    end 
                    
                    if ~ismember(place, bottom_places)
                        currGraph = gca;
                        currGraph.XAxis.Visible = 'off';
                    end
                    
                    if ~isempty(cond_name(1+(row-1),col))
                        title(cond_name(1+(row-1),col),'FontSize',subtitle_FontSize)
                    end
                    
                    
                        
                    %Add x and y axis labels if int he correct position
                end
            end
            if ylimits == 0
                allax = findall(gcf, 'Type', 'axes');
                ymin = min(ydata);
                ymax = max(ydata);
                for ax = allax
                    ylim(ax, [ymin, ymax]);
                end

            end
            
           if ~isempty(subplot_figure_titles)
               sgtitle(subplot_figure_titles{1,fig}, 'FontSize', figTitle_fontSize);
           end
            
            h = findobj(gcf,'Type','line');
            if num_groups == 1
                if plot_both_dir_ts == 0

                    legend1 = legend(genotype, 'FontSize', legend_FontSize);
                else
                    legend1 = legend(h(end), genotype);
                    
                end
            else
                
                if plot_both_dir_ts == 0
                    
                    legend1 = legend(h(end:-1:end-(num_groups-1)), genotype{1:end},'Orientation','horizontal');
                    
                else

                    legend1 = legend(h(end:-2:end - (num_groups*2-1)),genotype{1:end},'Orientation','horizontal');%prints warnings in orange but ignore
                    
                end
            end
            
            newPosition = [0.5 0.004 0.001 0.001]; %legend positioning
            newUnits = 'normalized';
            legend1.ItemTokenSize = [10,7];
            set(legend1,'Position', newPosition,'FontSize',legend_FontSize, 'Units', newUnits, 'Interpreter', 'none','Box','off');
            
            
            %Add legend, plot title
            set(gcf, 'Name', figure_names{1,fig});
             figH = gcf;
            fig_title = figH.Name(~isspace(figH.Name));
            if fig == num_figs
                save_figure(save_settings, fig_title, num2str(conditions((fig-1)*num_rows+1)),  num2str(conditions(end)));
            else

                save_figure(save_settings, fig_title, num2str(conditions((fig-1)*num_rows+1)), num2str(conditions(fig*num_rows)));
            end
            
            clear('allax');
            clear('lines');
            clear('curr_ydata');

                
                % Save figure here
        end
    end
end