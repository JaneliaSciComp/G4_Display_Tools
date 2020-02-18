%plot timeseries data for open-loop trials

function plot_OL_timeseries(timeseries_data, timestampsIN, OL_conds, OL_durations, cond_name, OL_inds, ...
    axis_labels, Frame_ind, num_groups, genotype, control_genotype, plot_settings, top_left_place, bottom_left_place, ...
    left_col_places, figure_titles, single)

    
    rep_Colors = plot_settings.rep_colors;
    mean_Colors = plot_settings.mean_colors;
    mean_LineWidth = plot_settings.mean_lineWidth;
    EdgeColor = plot_settings.edgeColor;
    patch_alpha = plot_settings.patch_alpha;
    subtitle_FontSize = plot_settings.subtitle_fontSize;
    legend_FontSize = plot_settings.legend_fontSize;
    frame_scale = plot_settings.frame_scale;
    frame_color = plot_settings.frame_color;
    frame_superimpose = plot_settings.frame_superimpose;
    timeseries_ylimits = plot_settings.timeseries_ylimits;
    timeseries_xlimits = plot_settings.timeseries_xlimits;
    rep_LineWidth = plot_settings.rep_lineWidth;
    plot_opposing_directions = plot_settings.plot_both_directions;
    control_color = plot_settings.control_color;
    show_ind_flies = plot_settings.show_individual_flies;
    y_fontsize = plot_settings.yLabel_fontSize;
    x_fontsize = plot_settings.xLabel_fontSize;
    
    

    
    if ~isempty(OL_conds)
    
        num_exps = size(timeseries_data,2);
    %loop for different data types
        for d = OL_inds
            
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
                    if cond>0
                        better_subplot(num_plot_rows, num_plot_cols, placement)
                        hold on
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
                                plot(repmat(timestampsIN',[1 num_exps]),tmpdata','Color',mean_Colors(g,:),'LineWidth',rep_LineWidth);
                            elseif num_groups==1  && show_ind_flies == 1
                                plot(repmat(timestampsIN',[1 num_exps]),tmpdata','Color',mean_Colors(g,:),'LineWidth',rep_LineWidth);
                                plot(timestamps, meandata, 'Color', .5*mean_Colors(g,:),'LineWidth', mean_LineWidth);
                            else
                                if g == control_genotype
                                    plot(timestamps,meandata,'Color',control_color,'LineWidth',mean_LineWidth);
                                    patch([timestamps fliplr(timestamps)],[meandata+semdata fliplr(meandata-semdata)],'k','FaceColor',control_color,'EdgeColor','none','FaceAlpha',patch_alpha)
                                else
                                    plot(timestamps,meandata,'Color',mean_Colors(g,:),'LineWidth',mean_LineWidth);
                                    patch([timestamps fliplr(timestamps)],[meandata+semdata fliplr(meandata-semdata)],'k','FaceColor',mean_Colors(g,:),'EdgeColor','none','FaceAlpha',patch_alpha)
                                end
                            end
                            
                            if plot_opposing_directions == 1
                            
                                tmpdata = squeeze(timeseries_data(g,:,d,cond+1,:));
                                meandata = nanmean(tmpdata);
                                nanidx = isnan(meandata);
                                stddata = nanstd(tmpdata);
                                semdata = stddata./sqrt(sum(max(~isnan(tmpdata),[],2)));
                                timestamps = timestampsIN(~nanidx);
                                meandata(nanidx) = []; 
                                semdata(nanidx) = [];
                                if single == 1
                                    plot(repmat(timestampsIN',[1 num_exps]),tmpdata','Color',mean_Colors(g+1,:),'LineWidth',rep_LineWidth);
                                elseif num_groups == 1
                                    plot(timestamps,meandata,'Color',mean_Colors(g+1,:),'LineWidth',mean_LineWidth);
                                    patch([timestamps fliplr(timestamps)],[meandata+semdata fliplr(meandata-semdata)],'k','FaceColor',mean_Colors(g+1,:),'EdgeColor','none','FaceAlpha',patch_alpha)
                                else
                                    if g == control_genotype
                                        plot(timestamps,meandata,'Color',control_color,'LineWidth',mean_LineWidth);
                                        patch([timestamps fliplr(timestamps)],[meandata+semdata fliplr(meandata-semdata)],'k','FaceColor',control_color,'EdgeColor','none','FaceAlpha',patch_alpha)

                                    else
                                        plot(timestamps,meandata,'Color',mean_Colors(g,:),'LineWidth',mean_LineWidth);
                                        patch([timestamps fliplr(timestamps)],[meandata+semdata fliplr(meandata-semdata)],'k','FaceColor',mean_Colors(g,:),'EdgeColor','none','FaceAlpha',patch_alpha)
                                
                                    
                                    end
                                end
                               
                            end
                        end
%                         titlestr = ['\fontsize{' num2str(subtitle_FontSize) '} Condition #{\color[rgb]{' num2str(mean_Colors(g,:)) '}' num2str(cond)]; 
                        if ~isempty(cond_name(1+(row-1),col))
                            title(cond_name(1+(row-1),col),'FontSize',subtitle_FontSize)
                        end
                        ylim(timeseries_ylimits(d,:));
                        %xlim(timeseries_xlimits)
                        
                        if frame_superimpose==1
                            yrange = diff(timeseries_ylimits(d,:));
                            framepos = squeeze(nanmedian(nanmedian(timeseries_data(:,:,Frame_ind,cond,:),2),1))';
                            framepos = (frame_scale*framepos/max(framepos))+timeseries_ylimits(d,1)-frame_scale*yrange;
                            ylim([timeseries_ylimits(d,1)-frame_scale*yrange timeseries_ylimits(d,2)])
                            plot(timestampsIN,framepos,'Color',frame_color,'LineWidth',mean_LineWidth);
                        end
                        
%                         title([titlestr '}'])
                        % title
                        %title(cond_name{cond},'FontSize',subtitle_FontSize)
                        % legend


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
                    if ~isnan(OL_durations(place))
                        xlim([0, OL_durations(place)]);
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
            h = findobj(gcf,'Type','line');
            if control_genotype ~= 0 
                genotype{control_genotype} = genotype{control_genotype} + " (control)";
            end
            if num_groups == 1
                if frame_superimpose == 0 && plot_opposing_directions == 0

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
            if control_genotype ~= 0
                genotype{control_genotype} = erase(genotype{control_genotype}," (control)");
            end

            newPosition = [0.5 0.004 0.001 0.001]; %legend positioning


            newUnits = 'normalized';
            legend1.ItemTokenSize = [10,7];
            set(legend1,'Position', newPosition,'FontSize',legend_FontSize, 'Units', newUnits, 'Interpreter', 'none','Box','off');



        end
    end
    
end
