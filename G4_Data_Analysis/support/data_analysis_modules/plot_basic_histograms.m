%% plot data
%calculate overall measurements and plot basic histograms
function plot_basic_histograms(model, timeseries_data, interhistogram_data, ...
    TC_plot_settings, gen_settings, plot_settings, exp_settings, proc_settings, ...
    annotation_settings, single, save_settings, num_groups, genotype)

    %Set up needed variables
    num_exps = model.num_exps;

    trial_options = proc_settings.trial_options;
    TC_inds = model.datatype_indices.TC_inds; % uses 
    bad_trials = model.bad_trials;
    bad_inter = model.bad_intertrials;
    

    TC_datatypes = TC_plot_settings.TC_datatypes;
    protocol = exp_settings.group_being_analyzed_name;
     
    rep_Colors = gen_settings.rep_colors;
    mean_Colors = gen_settings.mean_colors;
    rep_LineWidth = gen_settings.rep_lineWidth;
    mean_LineWidth = gen_settings.mean_lineWidth;
    subtitle_FontSize = gen_settings.subtitle_fontSize/1.25;
    ann_textbox = annotation_settings.textbox;
    ann_text = annotation_settings.annotation_text;
    ann_fontSize = annotation_settings.font_size/1.25;
    ann_fontName = annotation_settings.font_name;
    ann_lineStyle = annotation_settings.line_style;
    ann_edgeColor = annotation_settings.edge_color;
    ann_lineWidth = annotation_settings.line_width;
    ann_backgroundColor = annotation_settings.background_color;
    ann_color = annotation_settings.color;
    ann_interpreter = annotation_settings.interpreter;
    plot_in_degrees = plot_settings.inter_in_degrees;
    xlimits = plot_settings.xlimits;
    
    num_TC_datatypes = length(TC_datatypes);
    
    if num_groups > 5
        for i = 1:ceil(num_groups/5)
            if i == ceil(num_groups/5)
                if rem(num_groups,5) == 0
                    groups(i) = 5;
                else
                    groups(i) = rem(num_groups,5);
                end
            else
                groups(i) = 5;
            end
        end
        
    else
        
        groups = num_groups;
    end
    
    
    g = 0;
    for grp = 1:length(groups)
        num_plot_groups = groups(grp);
        figure();
        
        for gr = 1:num_plot_groups*(length(groups)-1)+groups(end)
            flies(gr) = 0;
            while sum(sum(sum(~isnan(timeseries_data(gr,flies(gr)+1,:,:,:))))) && flies(gr) <= num_exps-1
                flies(gr) = flies(gr) + 1;
                if flies(gr) == length(timeseries_data(1,:,1,1,1))
                    break;
                end
            end
            if flies(gr) == 1
                flies(gr) = 0;
            end
        end

        
        for plot_group = 1:num_plot_groups
            g = g + 1;
            
            for d = 1:num_TC_datatypes
                data_vec = reshape(timeseries_data(g,:,TC_inds(d),:,:),[1 numel(timeseries_data(g,:,d,:,:))]);
                datastr = ['Open Loop ' TC_datatypes{d}];
                datastr(strfind(datastr,'_')) = '-'; %convert underscores to dashes to prevent subscripts

                subplot(2+num_TC_datatypes,num_plot_groups,plot_group)
                if d ==1
                    if single == 0
                        text(0.1, .65, ['Number of Flies: ' num2str(flies(g))],  'FontSize', 8);
                        
                    else
                        md = load(fullfile(exp_settings.fly_path, 'metadata.mat'));
                        fly_name = md.metadata.fly_name;
                        timestamp = md.metadata.timestamp;
                        fly_name(strfind(fly_name,'_')) = '-';
                        text(0.1, .7, ['Fly Name: ' fly_name], 'FontSize', 8);
                        text(0.1, .5, ['Timestamp: ' timestamp], 'FontSize', 8);
                        text(0.1, .3, ['Trials thrown out: ' num2str(size(bad_trials,1))],  'FontSize', 8);
                        
                        
                    end
                end
                text(0.6, 1.25-0.3*(d+1), ['Mean ' TC_datatypes{d} ' = ' num2str(nanmean(data_vec))], 'FontSize', 8);
                
                axis off
                hold on
        %         title(['Group ' num2str(g)],'FontSize',subtitle_FontSize);
                genotypeStr = convertCharsToStrings(genotype(g));
                protocolStr = convertCharsToStrings(protocol);
                num_expsStr = convertCharsToStrings(num_exps);  
                if single
                    title("Single Fly Report - " + protocolStr + ", " + genotypeStr,'FontSize',subtitle_FontSize,'interpreter','none');
                else
                    title(protocolStr + ", " + genotypeStr,'FontSize',subtitle_FontSize,'interpreter','none');
                end
                %text
    %             annotation('textbox',[0.3 0.0001 0.7 0.027],'String',"empty split: " + e + " flies run from 08/08/19 to 08/13/19", ...
    %                 'FontSize' ,10,'FontName','Arial','LineStyle','-','EdgeColor',[1 1 1],'LineWidth',1,'BackgroundColor',[1 1 1],'Color',[0 0 0],'Interpreter', 'none'); %e is number of experiments
                

                annotation('textbox', ann_textbox, 'String', ann_text, ...
                    'FontSize', ann_fontSize, 'FontName', ann_fontName, 'LineStyle', ann_lineStyle, ...
                    'EdgeColor', ann_edgeColor, 'LineWidth', ann_lineWidth, 'BackgroundColor', ann_backgroundColor, ...
                    'Color', ann_color, 'Interpreter', ann_interpreter);

                subplot(2+num_TC_datatypes,num_plot_groups,d*num_plot_groups+plot_group)
                avg = 1/100;
                histogram(data_vec, 100, 'Normalization', 'probability')
                hold on
                xlim(xlimits(d,:))
                xlabel('Volts', 'FontSize', ann_fontSize);
                ylabel('%', 'FontSize', ann_fontSize);
                plot(xlimits(d,:),[avg avg],'--','Color',rep_Colors(g,:)','LineWidth',mean_LineWidth)
                ylimit = ylim; 
                set(gca, 'YTick', ylimit(1):.01:ylimit(2))
                yticklabels(yticks*100);
                xline(0, 'LineWidth',.75);
                
                title(datastr,'FontSize',subtitle_FontSize,'interpreter','none');
                currPlot = gca;
                set(currPlot, 'FontSize', 8);
            end

            if trial_options(2)==1 && single == 0
                
                ind_lines = squeeze(nanmean(interhistogram_data(g,:,:,:),3));
                avg_line = squeeze(nanmean(nanmean(interhistogram_data(g,:,:,:),3),2));
                total_points_array = [];
                for trs = 1:size(interhistogram_data,3)
                    total_points_array(trs) = nansum(interhistogram_data(1,1,trs,:),4);
                end
                total_points = nanmean(mean(nonzeros(total_points_array)));
                ind_lines = ind_lines/total_points;
                avg_line = avg_line/total_points;
                
                if plot_in_degrees == 1
                    if size(ind_lines,2) > size(ind_lines,1)
                        half = size(ind_lines,2)/2;
                        for i = 1:size(ind_lines,1)
                            ind_lines(i,:) = [ind_lines(i,half+1:end), ind_lines(i, 1:half)];
                        end
                    else
                        half = size(ind_lines,1)/2;
                        for i = 1:size(ind_lines,2)
                            ind_lines(:,i) = [ind_lines(half+1:end,i), ind_lines(1:half,i)];
                        end
                    end
                    
                    avg_line(:,1) = [avg_line(half+1:end); avg_line(1:half)];
                end
 
                subplot(2+num_TC_datatypes,num_plot_groups,(1+num_TC_datatypes)*num_plot_groups+plot_group)
                plot(ind_lines','Color',rep_Colors(g,:),'LineWidth',rep_LineWidth)
                hold on   
                plot(avg_line,'Color',mean_Colors(g,:),'LineWidth',mean_LineWidth)
                hold on
                avg_dist_line = (100/192)*(1/100);
                xli = xlim;
                plot(xli, [avg_dist_line avg_dist_line], '--', 'Color', rep_Colors(g,:)', 'LineWidth', mean_LineWidth)
                
                %convert x axis to degrees
               if plot_in_degrees == 1
                    x = xlim;
                    x = x(2);
                    tickgap = x/10;
                    for tick = 1:11
                        tick_labels(tick) = (-180 + (36*tick) - 36);
                        ticks(tick) = tick*tickgap - tickgap;
                    end

                    xticks(ticks);

                    xticklabels(string(tick_labels));
                    xlabel('Degrees');
               end
               
               ylimit = ylim; 
               set(gca, 'YTick', ylimit(1):.01:ylimit(2))
               yticklabels(yticks*100);
               ylabel('%', 'FontSize', ann_fontSize);

                title('Closed Loop Stripe Position','FontSize',subtitle_FontSize)
                currPlot = gca;
                set(currPlot, 'FontSize', 8);
            
            elseif trial_options(2) == 1 && single == 1
               
                fly_line = squeeze(nanmean(interhistogram_data(g,:,:,:),3));
                total_points_array = [];
                for trs = 1:size(interhistogram_data,3)
                    total_points_array(trs) = nansum(interhistogram_data(1,1,trs,:),4);
                end
                total_points = nanmean(mean(nonzeros(total_points_array)));

                fly_line = fly_line/total_points;
                if plot_in_degrees == 1
                    
                    half = length(fly_line)/2;
                    fly_line = [fly_line(half+1:end); fly_line(1:half)];
                    
                end
                
                subplot(2+num_TC_datatypes,num_plot_groups,(1+num_TC_datatypes)*num_plot_groups+plot_group)
                plot(fly_line','Color',rep_Colors(g,:),'LineWidth',rep_LineWidth)
                hold on;
                
                if plot_in_degrees == 1
                     x = xlim;
                    x = x(2);
                    tickgap = x/10;
                    for k = 1:11
                        tick_labels(k) = (-180 + (36*k) - 36);
                        ticks(k) = k*tickgap - tickgap;
                    end
                    xticks(ticks);

                    xticklabels(string(tick_labels));
                    xlabel('Degrees');
                end
               
                avg_val = mean(fly_line);
                xl_fly = xlim;
                if ~isempty(avg_val)
                    plot(xl_fly,[avg_val avg_val],'--','Color',rep_Colors(g,:)','LineWidth',rep_LineWidth)
                end
                 ylimit = ylim; 
               set(gca, 'YTick', ylimit(1):.01:ylimit(2))
               yticklabels(yticks*100);
               ylabel('%', 'FontSize', ann_fontSize);
                
                title('Closed Loop Stripe Position','FontSize',subtitle_FontSize)
                currPlot = gca;
                set(currPlot, 'FontSize', 8);
            
            end


        end
        if grp == 1
            genotype_labels = 1:groups(grp);
        else
            genotype_labels = sum(groups(1:grp-1))+1:sum(groups(1:grp));
        end


        save_figure(save_settings, genotype{genotype_labels}, 'hist', num2str(grp));
    end
    
%     currgraph = gcf;
%     currPosition = get(currgraph, 'Position');
%     screen = get(0,'ScreenSize');
%     if num_groups <= 3
%         %do nothing
%     elseif num_groups <= 6
% 
%         newPosition = [10, 10, screen(3)*.5, screen(4)*.5];
%         set(currgraph, 'Position', newPosition);
%     else
%         newPosition = [10,10, screen(3)*.8, screen(4)*.8];
%         set(currgraph, 'Position', newPosition);
%     end
end

