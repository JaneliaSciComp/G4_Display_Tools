function plot_falmr_timeseries(falmr_data, timestampsIN, plot_settings, exp_settings, ...
    model, save_settings, gen_settings, num_groups, genotype,  single, pat_move_time)

% Get items needed out of settings structures

% Timeseries plot settings
    falmr_conds = plot_settings.faLmR_conds;
    cond_name = plot_settings.faLmR_cond_name;
    axis_labels = plot_settings.OL_TS_conds_axis_labels;
    figure_titles = plot_settings.faLmR_figure_names;
     frame_scale = plot_settings.frame_scale;
    frame_color = plot_settings.frame_color;
    frame_superimpose = plot_settings.frame_superimpose;
    timeseries_ylimits = plot_settings.timeseries_ylimits;
    timeseries_xlimits = plot_settings.timeseries_xlimits;
    plot_opposing_directions = plot_settings.faLmR_plot_both_directions;
    show_ind_flies = plot_settings.show_individual_flies;
    show_ind_reps = plot_settings.show_individual_reps;
    cutoff_time = plot_settings.cutoff_time;
    other_indicators = plot_settings.other_indicators;
    pattern_motion_indicator = plot_settings.pattern_motion_indicator;
    condition_pairs = plot_settings.faLmR_pairs;
    
    % general plot settings
    rep_Colors = gen_settings.rep_colors;
    mean_Colors = gen_settings.mean_colors;
    mean_LineWidth = gen_settings.mean_lineWidth;
    EdgeColor = gen_settings.edgeColor;
    patch_alpha = gen_settings.patch_alpha;
    subtitle_FontSize = gen_settings.subtitle_fontSize;
    legend_FontSize = gen_settings.legend_fontSize; 
    rep_LineWidth = gen_settings.rep_lineWidth;   
    control_color = gen_settings.control_color;   
    y_fontsize = gen_settings.yLabel_fontSize;
    x_fontsize = gen_settings.xLabel_fontSize;
    fly_Colors = gen_settings.fly_colors;
    axis_num_fontSize = gen_settings.axis_num_fontSize;
    figTitle_fontSize = gen_settings.figTitle_fontSize; 
    
    % Model
        
    bottom_left_place = model.falmr_bottom_left_places;
    left_col_places = model.falmr_left_column_places;
    top_left_place = model.top_left_place; 
    
    % Experiment settings
    control_genotype = exp_settings.control_genotype;
    

     if ~isempty(falmr_conds)

        num_exps = size(falmr_data,2);
        
        for fig = 1:length(falmr_conds)
            subplot_figure_titles = plot_settings.faLmR_subplot_figure_titles{fig};
        
            ydata = [];
            %num_plot_rows = (1-overlap/2)*max(nansum(falmr_conds(:,:,fig)>0));
            %num_plot_cols = max(nansum(falmr_conds(:,:,fig)>0,2));
            num_plot_rows = size(falmr_conds{fig},1);
            num_plot_cols = size(falmr_conds{fig},2);
            figure('Position',[100 100 540 540*(num_plot_rows/num_plot_cols)])
            for row = 1:num_plot_rows
                for col = 1:num_plot_cols
                    cond = falmr_conds{fig}(1+(row-1),col);
                    placement = col+num_plot_cols*(row-1);
                    place = row+num_plot_rows*(col-1);

                    %The larger the number of rows is compared to columns,
                    %the more data gets cut off the bottom. Have to
                    %increment the spacing between plots depending on num
                    %rows. 

                    [gap_x, gap_y] = get_plot_spacing(num_plot_rows, num_plot_cols);


                    if cond>0
                        better_subplot(num_plot_rows, num_plot_cols, placement, gap_x, gap_y)
                        yline(0);
                        hold on
                        for g = 1:num_groups
                            if single && show_ind_reps
                                num_reps = size(falmr_data,4);
                                tmpdata = squeeze(falmr_data(g,:,cond,:,:));
                                 
                            else
                                num_reps = 0;
                                tmpdata = squeeze(falmr_data(g,:,cond,:));
                                
                            end
                            meandata = nanmean(tmpdata);
                            nanidx = isnan(meandata);
                            stddata = nanstd(tmpdata);
                            semdata = stddata./sqrt(sum(max(~isnan(tmpdata),[],2)));
                            timestamps = timestampsIN(~nanidx);
                            meandata(nanidx) = []; 
                            semdata(nanidx) = [];
                            ms_to_move = nanmean(squeeze(pat_move_time(g,:,cond,:)))/1000;
                            move_line(g) = timestamps(1) + ms_to_move;
                            if cutoff_time > 0
                                cutoff_ind = find(timestamps>cutoff_time);
                                if ~isempty(cutoff_ind)
                                    meandata(cutoff_ind(1)+1:end) = [];
                                    timestamps(cutoff_ind(1)+1:end)= [];
                                    semdata(length(meandata)+1:end) = [];
                                end
                            end

                            if single 
                                if show_ind_reps
                                    for rep = 1:num_reps
                                        plot(repmat(timestampsIN',[1 rep]),tmpdata(rep,:)','Color',fly_Colors(rep*2,:),'LineWidth', rep_LineWidth);
                                    end
                                    plot(timestamps, meandata, 'Color', .75*mean_Colors(g,:),'LineWidth', mean_LineWidth);
                                else
                                    plot(repmat(timestampsIN',[1 num_exps]),tmpdata','Color',mean_Colors(g,:),'LineWidth',rep_LineWidth);
                                end
                            elseif num_groups==1  && show_ind_flies == 1
                                for exp = 1:num_exps
                                    plot(repmat(timestampsIN',[1 exp]),tmpdata(exp,:)','Color',fly_Colors(exp,:),'LineWidth',rep_LineWidth);
                                end

                                plot(timestamps, meandata, 'Color', .75*mean_Colors(g,:),'LineWidth', mean_LineWidth);
                            else
                                if g == control_genotype
                                    plot(timestamps,meandata,'Color',control_color,'LineWidth',mean_LineWidth);
                                    patch([timestamps fliplr(timestamps)],[meandata+semdata fliplr(meandata-semdata)],'k','FaceColor',control_color,'EdgeColor',EdgeColor,'FaceAlpha',patch_alpha)
                                else
                                    plot(timestamps,meandata,'Color',mean_Colors(g,:),'LineWidth',mean_LineWidth);
                                    patch([timestamps fliplr(timestamps)],[meandata+semdata fliplr(meandata-semdata)],'k','FaceColor',mean_Colors(g,:),'EdgeColor',EdgeColor,'FaceAlpha',patch_alpha)
                                    
                                end

                                
                            end

                            if plot_opposing_directions == 1
                                opp_cond = get_opposing_condition(cond, condition_pairs);
                                if single && show_ind_reps
                                    tmpdata = squeeze(falmr_data(g,:,opp_cond,:,:));
                                else
                                    tmpdata = squeeze(falmr_data(g,:,opp_cond,:));
                                end
                                meandata = nanmean(tmpdata);
                                nanidx = isnan(meandata);
                                stddata = nanstd(tmpdata);
                                semdata = stddata./sqrt(sum(max(~isnan(tmpdata),[],2)));
                                timestamps = timestampsIN(~nanidx);
                                meandata(nanidx) = []; 
                                semdata(nanidx) = [];
                                
                                if cutoff_time > 0
                                    cutoff_ind = find(timestamps>cutoff_time);
                                    if ~isempty(cutoff_ind)
                                       meandata(cutoff_ind(1)+1:end) = [];
                                       timestamps(cutoff_ind(1)+1:end) = [];
                                       semdata(length(meandata)+1:end) = [];
                                    end
                                end

 %adjust color to make opposing direction
                                %lighter
  
                                if single == 1
                                    if show_ind_reps
                                        for rep2 = 1:num_reps
                                            plot(repmat(timestampsIN',[1 rep2]), tmpdata(rep2,:)', 'Color', fly_Colors(rep2*2,:),'LineWidth', rep_LineWidth);
                                        end
                                        plot(timestamps, meandata, 'Color', .75*mean_Colors(g+1,:), 'LineWidth', mean_LineWidth);
                                    else
                                        plot(repmat(timestampsIN',[1 num_exps]),tmpdata','Color',mean_Colors(g+1,:),'LineWidth',rep_LineWidth);
                                    end
                                elseif num_groups == 1
                                    plot(timestamps,meandata,'Color',mean_Colors(g+1,:),'LineWidth',mean_LineWidth);
                                    patch([timestamps fliplr(timestamps)],[meandata+semdata fliplr(meandata-semdata)],'k','FaceColor',mean_Colors(g+1,:),'EdgeColor',EdgeColor,'FaceAlpha',patch_alpha)

                                else
                                    if g == control_genotype
                                        plot(timestamps,meandata,'Color',control_color + .75,'LineWidth',mean_LineWidth);
                                        patch([timestamps fliplr(timestamps)],[meandata+semdata fliplr(meandata-semdata)],'k','FaceColor',control_color,'EdgeColor',EdgeColor,'FaceAlpha',patch_alpha)

                                    else
                                        
                                        for rgb = 1:length(mean_Colors(g,:))
                                            if mean_Colors(g,rgb) > .75
                                                color_adjust(rgb) = 0;
                                            elseif mean_Colors(g,rgb) > .5
                                                color_adjust(rgb) = .25;
                                            elseif mean_Colors(g, rgb) > .25
                                                color_adjust(rgb) = .5;
                                            elseif mean_Colors(g,rgb) >= 0
                                                color_adjust(rgb) = .75;
                            
                                            end
                                        end
                                        
                                        plot(timestamps,meandata,'Color',mean_Colors(g,:) + color_adjust,'LineWidth',mean_LineWidth);
                                        patch([timestamps fliplr(timestamps)],[meandata+semdata fliplr(meandata-semdata)],'k','FaceColor',mean_Colors(g,:),'EdgeColor',EdgeColor,'FaceAlpha',patch_alpha)
                                
                                    
                                    end
                                end
                                
                                
                               
                            end
                        end

                        if ~isempty(cond_name)
                            if ~isempty(cond_name{fig}(1+(row-1),col))
                                title(cond_name{fig}(1+(row-1),col),'FontSize',subtitle_FontSize)
                            end
                        end
                        if timeseries_ylimits(7,:) ~= 0
                            ylim(timeseries_ylimits(d,:));
                        else
                            lines = findobj(gca, 'Type', 'line');
                            for l = 1:length(lines)
                                curr_ydata = lines(l).YData;
                                mm = [min(curr_ydata), max(curr_ydata)];
                                ydata = [ydata, mm];
                                
                            end
                        end
                        
                        if pattern_motion_indicator == 1
                            if max(move_line)-min(move_line) > 50
                                msg = "variation in start times of " + string(max(move_line)-min(move_line)) + " for cond " + string(cond);
                                disp(msg);
                            end
                            disp_move_line = median(move_line);
                            xline(disp_move_line);
                        end
                        
%                         if frame_superimpose==1
%                             curr_ylim = ylim(gca);
%                             yrange = diff(curr_ylim);
%                             framepos = squeeze(nanmedian(nanmedian(timeseries_data(:,:,Frame_ind,cond,:),2),1))';
%                             framepos = (frame_scale*framepos/max(framepos))+curr_ylim(1)-frame_scale*yrange;
%                             ylim([curr_ylim(1)-frame_scale*yrange curr_ylim(2)])
%                             plot(timestampsIN,framepos,'Color',frame_color,'LineWidth',mean_LineWidth);
%                             y = ylim;
%                             mm = [min(y), max(y)];
%                             ydata = [ydata, mm];
%                         end
                        set(gca, 'FontSize', axis_num_fontSize);

                     end



                    % setting axes and labels

                    if ~ismember(place,left_col_places{fig}) %far-most left axis (clear all the right subplots)
                          currGraph = gca; 
                          currGraph.YAxis.Visible = 'off';
                    end 
                    % Set labels
                    xlabel('')
                    ylabel('')
                    if place == top_left_place
                        ylabel(axis_labels{end}(2), 'FontSize', y_fontsize) %1st subplot - Top Left
                        set(gca,'YTick');
                    end
                    if place == bottom_left_place{fig}
                        xlabel(axis_labels{end}(1), 'FontSize', x_fontsize) %7th subplot - Bottom Left
                    end
%                     if ~isnan(OL_durations(place)) && OL_durations(place) ~= 0
%                         xlim([-.2, OL_durations(place)]);
%                     end
%                     
                    if ~isempty(subplot_figure_titles)
                        sgtitle(subplot_figure_titles(fig), 'FontSize', figTitle_fontSize);
                    end
                    
                    

%                         % setting figures
%                         if OL_conds == 41 
%                             set(gcf,'Position', [10 10 250 400])
%                         end
                end
            end
            if fig <= length(figure_titles)
                if ~isempty(figure_titles{fig})
                    set(gcf, 'Name', figure_titles{fig});
                end
            end
            
            if timeseries_ylimits(7,:) == 0
                allax = findall(gcf, 'Type', 'axes');
                ymin = min(ydata);
                ymax = max(ydata);
                for ax = allax

                    ylim(ax, [ymin, ymax]);
                end
            end
            h = findobj(gcf,'Type','line');
%             if control_genotype ~= 0 
%                 genotype{control_genotype} = genotype{control_genotype} + " (control)";
%             end
            if num_groups == 1
                if  plot_opposing_directions == 0

                    legend1 = legend(genotype, 'FontSize', legend_FontSize);
                else
                    legend1 = legend(h(end), genotype);
                    
                end
            else
                
                if plot_opposing_directions == 0
                    
                    legend1 = legend(h(end:-1:end-(num_groups-1)), genotype{1:end},'Orientation','horizontal');
                    
                else

                    legend1 = legend(h(end:-2:end - (num_groups*2-1)),genotype{1:end},'Orientation','horizontal');%prints warnings in orange but ignore
                    
                end
            end

%            if control_genotype ~= 0
%                 genotype{control_genotype} = erase(genotype{control_genotype}," (control)");
%             end

            newPosition = [0.5 0.004 0.001 0.001]; %legend positioning


            newUnits = 'normalized';
            legend1.ItemTokenSize = [10,7];
            set(legend1,'Position', newPosition,'FontSize',legend_FontSize, 'Units', newUnits, 'Interpreter', 'none','Box','off');
            
            figH = gcf;
            fig_title = figH.Name(~isspace(figH.Name));

            save_figure(save_settings, fig_title, genotype{1:end}, 'faLmR_timeseries', num2str(fig));



        

        end
        
     end