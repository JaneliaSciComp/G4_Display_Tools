function plot_unedited_position_series(settings, gen_settings, mean_pos_series, save_settings, genotype, control_genotype)
    
    mean_colors = gen_settings.mean_colors;
     mean_LineWidth = gen_settings.mean_lineWidth;
    EdgeColor = gen_settings.edgeColor;
    patch_alpha = gen_settings.patch_alpha;
     subtitle_FontSize = gen_settings.subtitle_fontSize;
     legend_FontSize = gen_settings.legend_fontSize;
     rep_LineWidth = gen_settings.rep_lineWidth;
     control_color = gen_settings.control_color;
     y_fontsize = gen_settings.yLabel_fontSize;
     x_fontsize = gen_settings.xLabel_fontSize;
     fly_colors = gen_settings.fly_colors;
    axis_num_fontSize = gen_settings.axis_num_fontSize;
    figTitle_fontSize = gen_settings.figTitle_fontSize;
    
    conds = settings.pos_conds;
    cond_name = settings.cond_name;
    ylimits = settings.ylimits;
    xaxis = settings.xaxis;
    new_xaxis = settings.new_xaxis;
    show_ind_flies = settings.show_individual_flies;
    left_col_places = settings.left_column_places;
    top_left_place = settings.top_left_place;
    bottom_left_place = settings.bottom_left_place;
    axis_labels = settings.axis_labels;
    figure_titles = settings.figure_names;
    plot_opposing_directions = settings.plot_opposing_directions;
    subplot_figure_titles = settings.subplot_figure_names;
    % Plot the regular position series (not M and P)
    
    num_groups = size(mean_pos_series,1);
    num_exps = size(mean_pos_series,2);
    
    if size(mean_pos_series,1) == 1 && size(mean_pos_series,2) == 1
        single = 1;
    else 
        single = 0;
    end
    
    
    if ~isempty(new_xaxis)
        xaxis = new_xaxis(xaxis);
    end
    [xaxis, xaxis_inds] = sort(xaxis);
    
    if ~isempty(conds)

        plots_per_fig = numel(conds{1});
        num_rows = size(conds{1},1);
        num_cols = size(conds{1},2);
        num_figs = numel(conds);

        for fig = 1:num_figs
            figure('Position',[100 100 540 540*(num_rows/num_cols)])
            ydata = [];

            for row = 1:num_rows
                for col = 1:num_cols

                    cond = conds{fig}(1+(row-1),col);
                    place = row+num_rows*(col-1);
                    placement = col+num_cols*(row-1);
                    if cond > 0

                        better_subplot(num_rows, num_cols, placement,20,35)
                        hold on

                        for g = 1:num_groups

                            tmpdata = squeeze(mean_pos_series(g,:,cond,:));
                            meandata = nanmean(tmpdata);
                            nanidx = isnan(meandata);
                            stddata = nanstd(tmpdata);
                            semdata = stddata./sqrt(sum(max(~isnan(tmpdata),[],2)));
%                             meandata(nanidx) = []; 
%                             semdata(nanidx) = [];
                            
                            if single
                                plot(xaxis, tmpdata', 'Color',mean_colors(g,:),'LineWidth',rep_LineWidth);
                            elseif num_groups == 1 && show_ind_flies == 1

                                %Plot each fly
                                for exp = 1:num_exps

                                    plot(xaxis, tmpdata(exp,:),'Color',fly_colors(exp,:),'LineWidth',rep_LineWidth);
                                    hold on;

                                end
                                %Plot average of the flies

                                plot(xaxis, meandata,'Color', .75*mean_colors(g,:),'LineWidth', mean_LineWidth);

                            else


                                if g == control_genotype

                                    plot(xaxis, meandata,'Color',control_color,'LineWidth',mean_LineWidth);


                                else

                                    plot(xaxis, meandata,'Color',mean_colors(g,:),'LineWidth',mean_LineWidth);

                                end
                            end

                             if plot_opposing_directions

                                 tmpdata = squeeze(mean_pos_series(g,:,cond+1,:));
                                 meandata = nanmean(tmpdata);
                                 nanidx = isnan(meandata);
                                 stddata = nanstd(tmpdata);
                                 semdata = stddata./sqrt(sum(max(~isnan(tmpdata),[],2)));
%                                  meandata(nanidx) = []; 
%                                  semdata(nanidx) = [];
                                    %adjust color to make opposing direction
                                    %lighter
                                 if single
                                     plot(xaxis, tmpdata','Color',mean_colors(g+1,:),'LineWidth',rep_LineWidth);
                                 elseif g == control_genotype
                                     plot(xaxis, meandata,'Color',control_color + .75,'LineWidth',mean_LineWidth);
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

                                      plot(xaxis, meandata,'Color',mean_colors(g,:) + color_adjust,'LineWidth',mean_LineWidth);
                                 end
                             end
                        end

                          titlestr = ['\fontsize{' num2str(subtitle_FontSize) '} Condition #{\color[rgb]{' num2str(mean_colors(g,:)) '}' num2str(cond)]; 
                        if ~isempty(cond_name{fig}(1+(row-1),col))
                            title(cond_name{fig}(1+(row-1),col),'FontSize',subtitle_FontSize)
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
                        ylabel(axis_labels(2), 'FontSize', y_fontsize) %1st subplot - Top Left
                        set(gca,'YTick');
                    end
                    if place == bottom_left_place{fig}
                        xlabel(axis_labels(1), 'FontSize', x_fontsize) %7th subplot - Bottom Left
                    end
                end
            end


            if ~isempty(figure_titles)
                set(gcf, 'Name', figure_titles{fig});
            end
            if ~isempty(subplot_figure_titles)
                sgtitle(subplot_figure_titles(fig), 'FontSize', figTitle_fontSize);
            end

            if ylimits == 0
                allax = findall(gcf, 'Type', 'axes');
                ymin = min(ydata);
                ymax = max(ydata);
                for ax = allax
                    ylim(ax, [ymin, ymax]);
                end
            end
            h = findobj(gcf,'Type','line');

            if num_groups == 1
                if plot_opposing_directions == 0
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

            newPosition = [0.5 0.004 0.001 0.001]; %legend positioning
            newUnits = 'normalized';
            legend1.ItemTokenSize = [10,7];
            set(legend1,'Position', newPosition,'FontSize',legend_FontSize, 'Units', newUnits, 'Interpreter', 'none','Box','off');

            figH = gcf;
            fig_title = figH.Name(~isspace(figH.Name));

            save_figure(save_settings, fig_title, genotype{1:end}, num2str(fig));


        end
    end
end
