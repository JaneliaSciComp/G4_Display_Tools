%plot tuning-curves for specified open-loop trials

%Variables needed for this function: TC_Conds, TC_inds,
%num_groups, CombData, rep_Colors, rep_LineWidth, mean_Colors,
%mean_LineWidth, timeseries_ylimits, subtitle_FontSize, 
function plot_TC_specified_OLtrials(TC_plot_settings, TC_conds, plot_names, TC_inds, genotype, control_genotype, ...
    num_groups, summaries, single, save_settings, fig_num)

    rep_Colors = TC_plot_settings.rep_colors;
    rep_LineWidth = TC_plot_settings.rep_lineWidth;
    mean_Colors = TC_plot_settings.mean_colors;
    mean_LineWidth = TC_plot_settings.mean_lineWidth;
    timeseries_ylimits = TC_plot_settings.timeseries_ylimits;
    subtitle_FontSize = TC_plot_settings.subtitle_fontSize;
    marker_type = TC_plot_settings.marker_type;
    plot_opposing_directions = TC_plot_settings.plot_both_directions;
    control_color = TC_plot_settings.control_color;
    legend_FontSize = TC_plot_settings.legend_FontSize;
    axis_FontSize = TC_plot_settings.axis_label_fontSize;
    axis_labels = TC_plot_settings.TC_axis_labels;
    datatypes = TC_plot_settings.TC_datatypes;
    xaxis_values = TC_plot_settings.xaxis_values;
    fig_names = TC_plot_settings.figure_names;
    xtick_fontSize = TC_plot_settings.xtick_label_fontSize;
    
    
    if ~isempty(TC_conds)
        
        %loop for different data types
        for d = TC_inds
            ydata = [];
            num_plot_rows = size(TC_conds,2);
            num_plot_cols = size(TC_conds{1},1);
            figure('Position',[100 100 540 540*(num_plot_rows/num_plot_cols)])
            for row = 1:num_plot_rows
                for col = 1:num_plot_cols
                    conds = TC_conds{row}(col,:);
                    conds(isnan(conds)|conds==0) = [];
                    if isempty(conds)
                        continue;
                    end
                    placement = col+num_plot_cols*(row-1);
                    better_subplot(num_plot_rows, num_plot_cols, placement, 20, 35)
                    hold on
                    for g = 1:num_groups
                        tmpdata = squeeze(nanmean(summaries(g,:,d,conds,:),5));

                        if single == 1 
                            plot(tmpdata','Color',mean_Colors(g,:),'LineWidth',rep_LineWidth, 'Marker', marker_type);

                        elseif g == control_genotype
                            plot(nanmean(tmpdata),'Color',control_color,'LineWidth',mean_LineWidth, 'Marker', marker_type);
                        else

                            plot(nanmean(tmpdata),'Color',mean_Colors(g,:),'LineWidth',mean_LineWidth, 'Marker', marker_type);
                        end
                        if plot_opposing_directions == 1
                            for l = 1:length(conds)
                                conds(l) = conds(l) + 1;
                            end
                            tmpdata = squeeze(nanmean(summaries(g,:,d,conds,:),5));
                            if single == 1
                                plot(tmpdata','Color', mean_Colors(g+1,:), 'LineWidth', mean_LineWidth, 'Marker', marker_type);
                            elseif num_groups == 1
                                plot(nanmean(tmpdata),'Color',mean_Colors(g+1,:),'LineWidth',mean_LineWidth, 'Marker', marker_type);
                            else
                                if g == control_genotype
                                    plot(nanmean(tmpdata),'Color',control_color + .5,'LineWidth',mean_LineWidth, 'Marker', marker_type);
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
                                    plot(nanmean(tmpdata),'Color',mean_Colors(g,:) + color_adjust,'LineWidth',mean_LineWidth, 'Marker', marker_type);
                                end
                            end
                            for i = 1:length(conds)
                                conds(i) = conds(i) - 1;
                            end
                        end

                            
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
                        
                       % timeseries_ylimits(d,:) = ylim;
                    end
                   % titlestr = ['\fontsize{' num2str(subtitle_FontSize) '} Condition #{\color[rgb]{' num2str(mean_Colors(g,:)) '}' num2str(conds)];
                    %titlestr = "Datatype: " + CombData.channelNames.timeseries(d) + newline + " Condition # " + num2str(conds);
                    if row == num_plot_rows && col == 1
                        xlabel(axis_labels{TC_inds==d}(1), 'FontSize', axis_FontSize);
                        xticks(1:length(TC_conds{row}));
                        xticklabels(xaxis_values);
                    else
                         xlabel('');
                         xticks(1:length(TC_conds{row}));
                         xticklabels(xaxis_values);
                    end
                    
                    a = get(gca, 'XTickLabel');
                    set(gca, 'XTickLabel',a,'fontsize',xtick_fontSize);
                    
                    if row == 1 && col == 1
                        yaxis_label = axis_labels{TC_inds==d}(2);
                        ylabel(yaxis_label, 'FontSize', axis_FontSize);
                    else
                        ylabel('');
                    end
                    
                    if col~=1

                      currGraph = gca; 
                      currGraph.YAxis.Visible = 'off';
                    end 
                       
                    
                    title(plot_names(row,col), 'FontSize', subtitle_FontSize)
                end
            end
            if find(TC_inds==d) <= length(fig_names)
                if ~isempty(fig_names(TC_inds==d))
                    set(gcf, 'Name', fig_names(TC_inds==d));
                end
            end
            h = findobj(gcf,'Type','line');
%             if control_genotype ~= 0 
%                 genotype{control_genotype} = genotype{control_genotype} + " (control)";
%             end
            if num_groups == 1
                if plot_opposing_directions == 0
                    legend1 = legend(genotype);
                else
                    legend1 = legend(h(end), genotype);
                end
            else
                if plot_opposing_directions == 0
                    legend1 = legend(h(end:-1:end-(num_groups-1)), genotype{1:end},'Orientation','horizontal');
                else
                    legend1 = legend(h(end:-2:end - (num_groups*2-1)),genotype{1:end},'Orientation','horizontal');
                end
            end
%             if control_genotype ~= 0
%                 genotype{control_genotype} = erase(genotype{control_genotype}," (control)");
%             end
            
            if timeseries_ylimits(d,:) == 0
                allax = findall(gcf, 'Type', 'axes');
                ymin = min(ydata);
                ymax = max(ydata);
                for ax = allax
                
                    ylim(ax, [ymin, ymax]);
                end
            end
            newPosition = [0.5 0.004 0.001 0.001]; %legend positioning
            newUnits = 'normalized';
            legend1.ItemTokenSize = [10,7];
            set(legend1,'Position', newPosition,'FontSize',legend_FontSize, 'Units', newUnits, 'Interpreter', 'none','Box','off');
            
            figH = gcf;
            fig_title = figH.Name(~isspace(figH.Name));

            save_figure(save_settings, fig_title, genotype{1:end}, 'TC', num2str(fig_num));

           
        end   
    end
end