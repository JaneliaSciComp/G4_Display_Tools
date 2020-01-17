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
    marker_type = TC_plot_settings.marker_type;
    
    if ~isempty(TC_conds)
        
        %loop for different data types
        for d = TC_inds

            num_plot_rows = size(TC_conds,1);
            num_plot_cols = size(TC_conds,2);
            figure('Position',[100 100 540 540*(num_plot_rows/num_plot_cols)])
            for row = 1:num_plot_rows
                for col = 1:num_plot_cols
                    cond = TC_conds(1+(row-1)*(1+overlap),col);
                    cond(isnan(cond)|cond==0) = [];
                    placement = col+num_plot_cols*(row-1);
                    better_subplot(num_plot_rows, num_plot_cols, placement)
                    hold on
                    for g = 1:num_groups
                        tmpdata = squeeze(nanmean(CombData.summaries(g,:,d,cond,:),5));
                        if num_groups==1 && overlap==0 
                            plot(tmpdata','Color',rep_Colors(g,:),'LineWidth',rep_LineWidth);
                        end
                        plot(squeeze(tmpdata),'Color',mean_Colors(g,:),'LineWidth',mean_LineWidth, 'Marker', marker_type);
                    end
                    ylim(timeseries_ylimits(d,:));
                    titlestr = ['\fontsize{' num2str(subtitle_FontSize) '} Condition #{\color[rgb]{' num2str(mean_Colors(g,:)) '}' num2str(cond)]; 
                    if overlap==1
                        cond = TC_conds(row*2,col);
                        cond(isnan(cond)|cond==0) = [];
                        titlestr = [titlestr ' \color[rgb]{' num2str(rep_Colors(g,:)) '}(' num2str(cond) ')'];
                        for g = 1:num_groups
                            tmpdata = squeeze(nanmean(CombData.summaries(g,:,d,cond,:),5));
                            plot(nanmean(tmpdata),'Color',rep_Colors(g,:),'LineWidth',mean_LineWidth);
                        end
                    end
                    title([titlestr '}'])
                end
            end
        end
    end   
end