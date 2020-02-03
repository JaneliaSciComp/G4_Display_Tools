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
    plot_opposing_directions = TC_plot_settings.plot_both_directions;
    
    if ~isempty(TC_conds)
        
        %loop for different data types
        for d = TC_inds

            num_plot_rows = size(TC_conds,1);
            num_plot_cols = 1;
            figure('Position',[100 100 540 540*(num_plot_rows/num_plot_cols)])
            for row = 1:num_plot_rows
                for col = 1:num_plot_cols
                    conds = TC_conds(1+(row-1)*(1+overlap),:);
                    conds(isnan(conds)|conds==0) = [];
                    placement = col+num_plot_cols*(row-1);
                    better_subplot(num_plot_rows, num_plot_cols, placement)
                    hold on
                    for g = 1:num_groups
                        tmpdata = squeeze(nanmean(CombData.summaries(g,:,d,conds,:),5));
                        if num_groups==1 && plot_opposing_directions == 0 
                            plot(tmpdata','Color',rep_Colors(g,:),'LineWidth',rep_LineWidth);
                        end
                        plot(nanmean(tmpdata),'Color',mean_Colors(g,:),'LineWidth',mean_LineWidth, 'Marker', marker_type);
                        if plot_opposing_directions == 1
                            for l = 1:length(conds)
                                conds(l) = conds(l) + 1;
                            end
                            tmpdata = squeeze(nanmean(CombData.summaries(g,:,d,conds,:),5));
                            plot(nanmean(tmpdata),'Color',mean_Colors(g+1,:),'LineWidth',mean_LineWidth, 'Marker', marker_type);
                            for i = 1:length(conds)
                                conds(i) = conds(i) - 1;
                            end
                        end

                            
                    end
                    ylim(timeseries_ylimits(d,:));
                   % titlestr = ['\fontsize{' num2str(subtitle_FontSize) '} Condition #{\color[rgb]{' num2str(mean_Colors(g,:)) '}' num2str(conds)];
                    titlestr = "Datatype: " + CombData.channelNames.timeseries(d) + " Condition # " + num2str(conds);
                    xlabel(TC_plot_settings.xaxis_label);
                    xticks(1:length(TC_conds));
                    xticklabels(TC_plot_settings.xaxis_values);
                    if overlap==1
                        conds = TC_conds(row*2,:);
                        conds(isnan(conds)|conds==0) = [];
                        titlestr = string([titlestr ' \color[rgb]{' num2str(rep_Colors(g,:)) '}(' num2str(conds) ')']);
                        for g = 1:num_groups
                            tmpdata = squeeze(nanmean(CombData.summaries(g,:,d,conds,:),5));
                            plot(nanmean(tmpdata),'Color',rep_Colors(g,:),'LineWidth',mean_LineWidth);
                        end
                    end
                    title(titlestr, 'FontSize', subtitle_FontSize)
                end
            end
        end
    end   
end