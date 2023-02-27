%plot timeseries data for open-loop trials

function plot_OL_timeseries(timeseries_data, timestampsIN, model, plot_settings,...
    exp_settings, save_settings, gen_settings, num_groups, genotype, single, ...
    fig_num, pat_move_time)


    % Get needed items from the settings structures
    
    %timeseries plot settings
    OL_conds = plot_settings.OL_TS_conds{fig_num};
    OL_durations = plot_settings.OL_TS_durations{fig_num};
    cond_name = plot_settings.cond_name{fig_num};
    axis_labels = plot_settings.OL_TS_conds_axis_labels;
    figure_titles = plot_settings.figure_names;
    frame_scale = plot_settings.frame_scale;
    frame_color = plot_settings.frame_color;
    frame_superimpose = plot_settings.frame_superimpose;
    timeseries_ylimits = plot_settings.timeseries_ylimits;
    timeseries_xlimits = plot_settings.timeseries_xlimits;
    plot_opposing_directions = plot_settings.plot_both_directions;
    show_ind_flies = plot_settings.show_individual_flies;
    show_ind_reps = plot_settings.show_individual_reps;
    subplot_figure_titles = plot_settings.subplot_figure_title;
    cutoff_time = plot_settings.cutoff_time;

    if ~isempty(plot_settings.other_indicators)
        other_indicators = plot_settings.other_indicators{fig_num};
    else
        other_indicators = [];
    end

    pattern_motion_indicator = plot_settings.pattern_motion_indicator;
    condition_pairs = plot_settings.opposing_condition_pairs;
    
    %General plot settings
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
    
    %Model (index tracking, layout)
    OL_inds = model.datatype_indices.OL_inds;
    Frame_ind = model.datatype_indices.Frame_ind;
    top_left_place = model.top_left_place;
    bottom_left_place = model.timeseries_bottom_left_places{fig_num};
    left_col_places = model.timeseries_left_column_places{fig_num};
    
    %experiment settings
    control_genotype = exp_settings.control_genotype;

    
    if ~isempty(OL_conds)
    
        num_exps = size(timeseries_data,2);
    %loop for different data types
        for d = OL_inds
            ydata = [];
            %num_plot_rows = (1-overlap/2)*max(nansum(OL_conds(:,:,fig)>0));
            %num_plot_cols = max(nansum(OL_conds(:,:,fig)>0,2));
            num_plot_rows = size(OL_conds,1);
            num_plot_cols = size(OL_conds,2);
            figure('Position',[100 100 540 540*(num_plot_rows/num_plot_cols)])
            for row = 1:num_plot_rows
                for col = 1:num_plot_cols
                    cond = OL_conds(1+(row-1),col);
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
                                num_reps = size(timeseries_data,5);
                                tmpdata = squeeze(timeseries_data(g,:,d,cond,:,:));
                                 
                            else
                                num_reps = 0;
                                tmpdata = squeeze(timeseries_data(g,:,d,cond,:));
                                
                            end
                            meandata = mean(tmpdata,'omitnan');
                            nanidx = isnan(meandata);
                            stddata = nanstd(tmpdata);
                            semdata = stddata./sqrt(sum(max(~isnan(tmpdata),[],2)));
                            timestamps = timestampsIN(~nanidx);
                            meandata(nanidx) = []; 
                            semdata(nanidx) = [];
                            ms_to_move = mean(squeeze(pat_move_time(g,:,cond,:),'omitnan'))/1000;
                            if ~isempty(timestamps)
                                move_line(g) = timestamps(1) + ms_to_move;
                            else
                                move_line(g) = NaN;
                            end
                            if cutoff_time > 0
                                cutoff_ind = find(timestamps>cutoff_time);
                                if ~isempty(cutoff_ind)
                                    meandata(cutoff_ind(1)+1:end) = [];
                                    timestamps(cutoff_ind(1)+1:end)= [];
                                    semdata(length(meandata)+1:end) = [];
                                end
                            end
                            
                           if plot_opposing_directions
                                opp_cond = get_opposing_condition(cond, condition_pairs);
                                if single && show_ind_reps
                                    tmpdataOpp = squeeze(timeseries_data(g,:,d,opp_cond,:,:));
                                else
                                    tmpdataOpp = squeeze(timeseries_data(g,:,d,opp_cond,:));
                                end
                                meandataOpp = mean(tmpdataOpp,'omitnan');
                                nanidxOpp = isnan(meandataOpp);
                                stddataOpp = nanstd(tmpdataOpp);
                                semdataOpp = stddataOpp./sqrt(sum(max(~isnan(tmpdataOpp),[],2)));
                                timestampsOpp = timestampsIN(~nanidxOpp);
                                meandataOpp(nanidxOpp) = []; 
                                semdataOpp(nanidxOpp) = [];

                                if cutoff_time > 0
                                    cutoff_indOpp = find(timestampsOpp>cutoff_time);
                                    if ~isempty(cutoff_indOpp)
                                       meandataOpp(cutoff_indOpp(1)+1:end) = [];
                                       timestampsOpp(cutoff_indOpp(1)+1:end) = [];
                                       semdataOpp(length(meandataOpp)+1:end) = [];
                                    end
                                end
                            end
                   

                            if single 
                                if show_ind_reps
                                    for rep = 1:num_reps
                                        plot(repmat(timestampsIN',[1 rep]),tmpdata(rep,:)','Color',fly_Colors(rep*2,:),'LineWidth', rep_LineWidth);
                                    end
                                    if plot_opposing_directions
                                        for rep2 = 1:num_reps
                                            plot(repmat(timestampsIN',[1 rep2]), tmpdataOpp(rep2,:)', 'Color', fly_Colors(rep2*2,:),'LineWidth', rep_LineWidth);
                                        end
                                        plot(timestampsOpp, meandataOpp, 'Color', .75*mean_Colors(g+1,:), 'LineWidth', mean_LineWidth);
                                    end
                                    plot(timestamps, meandata, 'Color', .75*mean_Colors(g,:),'LineWidth', mean_LineWidth);
                                else
                                    plot(repmat(timestampsIN',[1 num_exps]),tmpdata','Color',mean_Colors(g,:),'LineWidth',rep_LineWidth);
                                    if plot_opposing_directions
                                        plot(repmat(timestampsIN',[1 num_exps]),tmpdataOpp','Color',mean_Colors(g+1,:),'LineWidth',rep_LineWidth);
                                    end
                                        
                                end
                            elseif num_groups==1
                                
                                if show_ind_flies == 1
                                    
                                    for exp = 1:num_exps
                                        plot(repmat(timestampsIN',[1 exp]),tmpdata(exp,:)','Color',fly_Colors(exp,:),'LineWidth',rep_LineWidth);
                                    end
                                    
                                    if plot_opposing_directions == 1
                                        
                                        for exp = 1:num_exps
                                            plot(repmat(timestampsIN',[1 exp]),tmpdataOpp(exp,:)','Color',fly_Colors(exp,:),'LineWidth',rep_LineWidth);
                                        end
                                        plot(timestampsOpp,meandataOpp,'Color',mean_Colors(g+1,:),'LineWidth',mean_LineWidth);
                                        patch([timestampsOpp fliplr(timestampsOpp)],[meandataOpp+semdataOpp fliplr(meandataOpp-semdataOpp)],'k','FaceColor',mean_Colors(g+1,:),'EdgeColor',EdgeColor,'FaceAlpha',patch_alpha)
                                        
                                    end
                                    
                                else
                                    
                                    if plot_opposing_directions == 1
                                        
                                        plot(timestampsOpp,meandataOpp,'Color',mean_Colors(g+1,:),'LineWidth',mean_LineWidth);
                                        patch([timestampsOpp fliplr(timestampsOpp)],[meandataOpp+semdataOpp fliplr(meandataOpp-semdataOpp)],'k','FaceColor',mean_Colors(g+1,:),'EdgeColor',EdgeColor,'FaceAlpha',patch_alpha)
                                        
                                    end
                                        
                                    
                                end

                                plot(timestamps, meandata, 'Color', mean_Colors(g,:),'LineWidth', mean_LineWidth);
                                patch([timestamps fliplr(timestamps)],[meandata+semdata fliplr(meandata-semdata)],'k','FaceColor',mean_Colors(g,:),'EdgeColor',EdgeColor,'FaceAlpha',patch_alpha)
                            else
                                if g == control_genotype
                                    plot(timestamps,meandata,'Color',control_color,'LineWidth',mean_LineWidth);
                                    patch([timestamps fliplr(timestamps)],[meandata+semdata fliplr(meandata-semdata)],'k','FaceColor',control_color,'EdgeColor',EdgeColor,'FaceAlpha',patch_alpha)
                                    if plot_opposing_directions
                                        plot(timestampsOpp,meandataOpp,'Color',control_color + .75,'LineWidth',mean_LineWidth);
                                        patch([timestampsOpp fliplr(timestampsOpp)],[meandataOpp+semdataOpp fliplr(meandataOpp-semdataOpp)],'k','FaceColor',control_color,'EdgeColor',EdgeColor,'FaceAlpha',patch_alpha)
                                    end
                                        
                                else
                                    plot(timestamps,meandata,'Color',mean_Colors(g,:),'LineWidth',mean_LineWidth);
                                    patch([timestamps fliplr(timestamps)],[meandata+semdata fliplr(meandata-semdata)],'k','FaceColor',mean_Colors(g,:),'EdgeColor',EdgeColor,'FaceAlpha',patch_alpha)
                                    
                                    if plot_opposing_directions
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
                                        
                                        plot(timestampsOpp,meandataOpp,'Color',mean_Colors(g,:) + color_adjust,'LineWidth',mean_LineWidth);
                                        patch([timestampsOpp fliplr(timestampsOpp)],[meandataOpp+semdataOpp fliplr(meandataOpp-semdataOpp)],'k','FaceColor',mean_Colors(g,:),'EdgeColor',EdgeColor,'FaceAlpha',patch_alpha)
                                    end
                                    
                                end

                                
                            end
                            

                        end
%                         titlestr = ['\fontsize{' num2str(subtitle_FontSize) '} Condition #{\color[rgb]{' num2str(mean_Colors(g,:)) '}' num2str(cond)]; 
                        if ~isempty(cond_name(1+(row-1),col))
                            title(cond_name(1+(row-1),col),'FontSize',subtitle_FontSize)
                        end
                        if timeseries_ylimits(d,:) ~= 0
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
                            if ~isnan(disp_move_line) && ~isempty(disp_move_line)
                                xline(disp_move_line);
                            end
                        end

                        if ~isempty(other_indicators)
                            line_value = other_indicators(1+(row-1),col);
                            if ~isnan(line_value) && line_value ~= 0
                                xline(line_value);
                            end
                        end
                        
                        if frame_superimpose==1
                            curr_ylim = ylim(gca);
                            yrange = diff(curr_ylim);
                            framepos = squeeze(nanmedian(nanmedian(timeseries_data(:,:,Frame_ind,cond,:),2),1))';
                            framepos = (frame_scale*framepos/max(framepos))+curr_ylim(1)-frame_scale*yrange;
                            ylim([curr_ylim(1)-frame_scale*yrange curr_ylim(2)])
                            plot(timestampsIN,framepos,'Color',frame_color,'LineWidth',mean_LineWidth);
                            y = ylim;
                            mm = [min(y), max(y)];
                            ydata = [ydata, mm];
                        end
                        set(gca, 'FontSize', axis_num_fontSize);
                        
                    end

                    % setting axes and labels

                    if ~ismember(place,left_col_places) %far-most left axis (clear all the right subplots)
                          currGraph = gca; 
                          currGraph.YAxis.Visible = 'off';
                    end 
                    % Set labels
                    xlabel('')
                    ylabel('')
                    if place == top_left_place
                        ylabel(axis_labels{OL_inds==d}(2), 'FontSize', y_fontsize) %1st subplot - Top Left
                        set(gca,'YTick');
                    end
                    if place == bottom_left_place
                        xlabel(axis_labels{OL_inds==d}(1), 'FontSize', x_fontsize) %7th subplot - Bottom Left
                    end
                    if ~isnan(OL_durations(place)) && OL_durations(place) ~= 0
                        xlim([-.2, OL_durations(place)]);
                    end
                    
                    if ~isempty(subplot_figure_titles)
                        sgtitle(subplot_figure_titles{OL_inds==d}(fig_num), 'FontSize', figTitle_fontSize);
                    end
                    
                    

%                         % setting figures
%                         if OL_conds == 41 
%                             set(gcf,'Position', [10 10 250 400])
%                         end
                end
            end
            if find(OL_inds==d) <= length(figure_titles)
                if ~isempty(figure_titles(OL_inds==d))
                    set(gcf, 'Name', figure_titles(OL_inds==d));
                end
            end
            
            if timeseries_ylimits(d,:) == 0
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
                if frame_superimpose == 0 && plot_opposing_directions == 0

                    legend1 = legend(genotype, 'FontSize', legend_FontSize);
                else
                    legend1 = legend(h(end), 'Positive');
                    
                end
            else
                
                if plot_opposing_directions == 0
                    
                    legend1 = legend(h(end:-1:end-(num_groups-1)), genotype{1:end},'Orientation','horizontal');
                    
                else
                    
                    legend1 = legend(h(end:-2:end - (num_groups*2-1)),genotype{1:end},'Orientation','horizontal');%prints warnings in orange but ignore
                    
                    
                end
            end
%             if control_genotype ~= 0
%                 genotype{control_genotype} = erase(genotype{control_genotype}," (control)");
%             end

            newPosition = [0.5 0.004 0.001 0.001]; %legend positioning


            newUnits = 'normalized';
            legend1.ItemTokenSize = [10,7];
            set(legend1,'Position', newPosition,'FontSize',legend_FontSize, 'Units', newUnits, 'Interpreter', 'none','Box','off');
            
            figH = gcf;
            fig_title = figH.Name(~isspace(figH.Name));

            save_figure(save_settings, fig_title, genotype{1:end}, 'timeseries', num2str(fig_num));


        end
    end
    
end
