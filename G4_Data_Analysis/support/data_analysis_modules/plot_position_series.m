function plot_position_series(gen_settings, MP_settings, pos_settings, save_settings, mean_pos_series, ...
    P, M, P_flies, M_flies, genotype, control_genotype)


    
    MP_conds = MP_settings.mp_conds;
    cond_name = MP_settings.cond_name;
     mean_colors = gen_settings.mean_colors;
     mean_LineWidth = gen_settings.mean_lineWidth;
    EdgeColor = gen_settings.edgeColor;
    patch_alpha = gen_settings.patch_alpha;
     subtitle_FontSize = gen_settings.subtitle_fontSize;
     legend_FontSize = gen_settings.legend_fontSize;
    ylimits = MP_settings.ylimits;
    xaxis = MP_settings.xaxis;
    new_xaxis = MP_settings.new_xaxis;
     rep_LineWidth = gen_settings.rep_lineWidth;
     control_color = gen_settings.control_color;
     show_ind_flies = MP_settings.show_individual_flies;
     y_fontsize = gen_settings.yLabel_fontSize;
     x_fontsize = gen_settings.xLabel_fontSize;
     fly_colors = gen_settings.fly_colors;
    axis_num_fontSize = gen_settings.axis_num_fontSize;
    left_col_places = MP_settings.left_column_places;
    top_left_place = MP_settings.top_left_place;
    bottom_left_place = MP_settings.bottom_left_place;
    axis_labels = MP_settings.axis_labels;
    figure_titles = MP_settings.figure_names;
    subplot_figure_titles = MP_settings.subplot_figure_title;
    figTitle_fontSize = gen_settings.figTitle_fontSize;
    
    num_groups = size(mean_pos_series,1);
    num_exps = size(mean_pos_series,2);
    

    if ~isempty(new_xaxis)
        xaxis = new_xaxis(xaxis);
    end
    [xaxis, xaxis_inds] = sort(xaxis);

    
    if ~isempty(MP_conds)
        
        %Plot P and M 
        num_plots_per_fig = numel(MP_conds{1});
        num_rows = size(MP_conds{1},1);
        num_cols = size(MP_conds{1},2);
        num_figs = numel(MP_conds);
        
        for MP = 1:2
            if MP == 1
                data = M;
                data_flies = M_flies;
            else
                data = P;
                data_flies = P_flies;
            end
            for fig = 1:num_figs    
                figure('Position',[100 100 540 540*(num_rows/num_cols)])
                ydata = [];

                for row = 1:num_rows
                    for col = 1:num_cols
                        if row*col > size(data,2)
                            continue;
                        end
                        cond = MP_conds{fig}(1+(row-1),col);
                        place = row+num_rows*(col-1);
                        placement = col+num_cols*(row-1);
                        
                        [gap_x, gap_y] = get_plot_spacing(num_rows, num_cols);
                        better_subplot(num_rows, num_cols, placement,gap_x, gap_y)
                        yline(0, 'k--');
                        hold on

                        if num_groups == 1 && show_ind_flies == 1
                            for fly = 1:size(data_flies,2)
                                datatoplot = squeeze(data_flies(1, fly, ceil(MP_conds{fig}(row,col)/2), :));
                                %datatoplot = datatoplot(xaxis_inds);
                                plot(xaxis, datatoplot,'Color',fly_colors(fly,:),'LineWidth',rep_LineWidth);
                                hold on;

                            end
                            datatoplot = squeeze(data(1, ceil(MP_conds{fig}(row,col)/2), :));
%                            datatoplot = datatoplot(xaxis_inds);
                            plot(xaxis, datatoplot,'Color',mean_colors(1,:),'LineWidth',mean_LineWidth);

                        else

                            for g = 1:num_groups
                        
                                if g == control_genotype

                                    datatoplot = squeeze(data(g, ceil(MP_conds{fig}(row,col)/2), :));
                                    %datatoplot = datatoplot(xaxis_inds);
                                    plot(xaxis, datatoplot,'Color',control_color,'LineWidth',mean_LineWidth);


                                else

                                   datatoplot = squeeze(data(g, ceil(MP_conds{fig}(row,col)/2), :));
                                   % datatoplot = datatoplot(xaxis_inds);
                                    plot(xaxis, datatoplot,'Color',mean_colors(g,:),'LineWidth',mean_LineWidth);


                                end
                            end
                        end
                        
                        
               
         %               titlestr = ['\fontsize{' num2str(subtitle_FontSize) '} Condition #{\color[rgb]{' num2str(mean_Colors(g,:)) '}' num2str(cond)]; 
                        if ~isempty(cond_name{fig}(row,col))
                            title(cond_name{fig}(row,col),'FontSize',subtitle_FontSize);
                        end
                        if ~isempty(ylimits)
                            if ylimits(MP,:) ~= 0
                                ylim(ylimits(MP,:));
                            end
                        else
                            lines = findobj(gca, 'Type', 'line');
                            for l = 1:length(lines)
                                curr_ydata = lines(l).YData;
                                mm = [min(curr_ydata), max(curr_ydata)];
                                ydata = [ydata, mm];

                            end
                        end
                    


                        set(gca, 'FontSize', axis_num_fontSize);


                        % setting axes and labels

                        if ~ismember(place,left_col_places{fig}) %far-most left axis (clear all the right subplots)
                              currGraph = gca; 
                              currGraph.YAxis.Visible = 'off';
                        end 
                        % Set labels
                        xlabel('')
                        ylabel('')
                        if place == top_left_place
                            ylabel(axis_labels{MP}(2), 'FontSize', y_fontsize) %1st subplot - Top Left
                            set(gca,'YTick');
                        end
                        if place == bottom_left_place{fig}
                            xlabel(axis_labels{MP}(1), 'FontSize', x_fontsize) %7th subplot - Bottom Left
                        end



                    end
               end
    
                if MP <= length(figure_titles)
                    if ~isempty(figure_titles(MP))
                        set(gcf, 'Name', figure_titles(MP));
                    end
                end
                
                if MP <= length(subplot_figure_titles)
                    if ~isempty(subplot_figure_titles{MP})
                        sgtitle(subplot_figure_titles{MP}(fig), 'FontSize', figTitle_fontSize);
                    end
                end
                
                if isempty(ylimits)

                    allax = findall(gcf, 'Type', 'axes');
                    ymin = min(ydata);
                    ymax = max(ydata);
                    for ax = allax

                        ylim(ax, [ymin, ymax]);
                    end

                end
                h = findobj(gcf,'Type','line');
%                 if control_genotype ~= 0 
%                     genotype{control_genotype} = genotype{control_genotype} + " (control)";
%                 end
                if num_groups == 1


                    legend1 = legend(genotype, 'FontSize', legend_FontSize);

                else

                    legend1 = legend(h(end:-1:end-(num_groups-1)), genotype{1:end},'Orientation','horizontal');

                end
%                 if control_genotype ~= 0
%                     genotype{control_genotype} = erase(genotype{control_genotype}," (control)");
%                 end

                newPosition = [0.5 0.004 0.001 0.001]; %legend positioning


                newUnits = 'normalized';
                legend1.ItemTokenSize = [10,7];
                set(legend1,'Position', newPosition,'FontSize',legend_FontSize, 'Units', newUnits, 'Interpreter', 'none','Box','off');

                figH = gcf;
                fig_title = figH.Name(~isspace(figH.Name));

                save_figure(save_settings, fig_title, genotype{1:end}, 'posSeries', num2str(fig));

            end

        end

    end
    
    if pos_settings.plot_pos_averaged == 1
        
        plot_unedited_position_series(pos_settings, gen_settings, mean_pos_series, save_settings, genotype, control_genotype)
        
    end

end