%plot histograms for closed-loop trials


%variables i need for this:  CL_conds, CL_inds, (optional num_figs,
%num_plot_rows, num_plot_cols?), overlap, CombData.histograms, num_groups,
%rep_Colors, rep_lineWidth, mean_colors, mean_lineWidth, histogram_ylimits,
%subtitle_FontSize, 
function plot_CL_histograms(CL_conds, CL_inds, histogram_data, num_groups, ...
    plot_settings, gen_settings, save_settings)
    
    overlap = plot_settings.overlap;
    rep_Colors = gen_settings.rep_colors;
    rep_LineWidth = gen_settings.rep_lineWidth;
    mean_Colors = gen_settings.mean_colors;
    mean_LineWidth = gen_settings.mean_lineWidth;
    histogram_ylimits = plot_settings.histogram_ylimits;
    subtitle_FontSize = gen_settings.subtitle_fontSize;
    figure_titles = plot_settings.figure_names;
   
    
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
                            [gap_x, gap_y] = get_plot_spacing(num_plot_rows, num_plot_cols);
                            better_subplot(num_plot_rows, num_plot_cols, col+num_plot_cols*(row-1), gap_x, gap_y)
                            hold on
                            [~, num_exps, ~, ~, ~, num_positions] = size(histogram_data);
                            x = circshift(1:num_positions,[1 floor(num_positions/2)]);
                            x(x>x(end)) = x(x>x(end))-num_positions;
                            for g = 1:num_groups
                                tmpdata = circshift(squeeze(mean(histogram_data(g,:,d,cond,:,:),5,'omitnan')),[1 num_positions/2]);
                                if num_groups==1 && overlap==0 %plot individual trials only if plotting one data group (otherwise it's too messy)
                                    plot(repmat(x',[1 num_exps]),tmpdata','Color',rep_Colors(g,:),'LineWidth',rep_LineWidth);
                                end
                                plot(x,mean(tmpdata,'omitnan'),'Color',mean_Colors(g,:),'LineWidth',mean_LineWidth)
                            end
                            ylim(histogram_ylimits(d,:));
                            titlestr = ['\fontsize{' num2str(subtitle_FontSize) '} Condition #{\color[rgb]{' num2str(mean_Colors(g,:)) '}' num2str(cond)]; 
                            if overlap==1
                                cond = CL_conds(row*2,col,fig);
                                if cond>0
                                    titlestr = [titlestr ' \color[rgb]{' num2str(rep_Colors(g,:)) '}(' num2str(cond) ')'];
                                    for g = 1:num_groups
                                        tmpdata = circshift(squeeze(mean(histogram_data(g,:,d,cond,:,:),5,'omitnan')),[1 num_positions/2]);
                                        plot(x,mean(tmpdata,'omitnan'),'Color',rep_Colors(g,:),'LineWidth',mean_LineWidth)
                                    end
                                end
                            end
                            title([titlestr '}'])
                        end
                    end
                end
                if find(CL_inds==d) <= length(figure_titles)
                    if ~isempty(figure_titles(CL_inds==d))
                        set(gcf, 'Name', figure_titles(CL_inds==d));
                    end
                end
            end
        end
        figH = gcf;
        fig_title = figH.Name(~isspace(figH.Name));

        save_figure(save_settings, fig_title, 'CLhistogram', num2str(fig));
    end
end