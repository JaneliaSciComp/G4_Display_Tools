%plot tuning-curves for specified open-loop trials

%Variables needed for this function: TC_Conds, TC_inds, overlap,
%num_groups, CombData, rep_Colors, rep_LineWidth, mean_Colors,
%mean_LineWidth, timeseries_ylimits, subtitle_FontSize, 
function plot_TC_specified_OLtrials(TC_plot_settings, TC_conds, TC_inds, overlap, ...
    num_groups, CombData)

    rep_Colors = TC_plot_settings.rep_colors;
    rep_LineWidth = TC_plot_settings.rep_lineWidth;
    mean_Colors = TC_plot_settings.mean_colors;
    mean_LineWidth = TC_plot_settings.mean_lineWidth;
    timeseries_ylimits = TC_plot_settings.timeseries_ylimits;
    subtitle_FontSize = TC_plot_settings.subtitle_fontSize;
    
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
                    titlestr = ['\fontsize{' num2str(subtitle_FontSize) '} Condition #{\color[rgb]{' num2str(mean_Colors(g,:)) '}' num2str(conds)]; 
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
end