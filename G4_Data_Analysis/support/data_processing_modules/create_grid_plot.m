function create_grid_plot(dark_avgReps_data, light_avgReps_data, grid_rows, grid_columns, plot_chan, timestamps)
    
%% Need to switch back to passing in all data. WIll want to plot each rep individually
% in light color and then the average thicker on each axis. 
    
    for cond = 1:length(dark_avgReps_data)
        fig = figure; 
        ts = timestamps{cond};
        plot_data_dark = squeeze(dark_avgReps_data{cond}(plot_chan, :, :));
        plot_data_light = squeeze(light_avgReps_data{cond}(plot_chan,:, :));
        dark_plot_title = ['Condition ' num2str(cond) ' Dark Squares'];
        light_plot_title = ['Condition ' num2str(cond) ' Light Squares'];
        dark_yax = [min(min(plot_data_dark)) max(max(plot_data_dark))];
        light_yax = [min(min(plot_data_light)) max(max(plot_data_light))];
        [gap_x, gap_y] = get_plot_spacing(grid_rows(cond), grid_columns(cond));
        for dframe = 1:size(plot_data_dark,1)
            % if sum(~isnan(data_to_plot(dframe, :))) > 0
                if size(plot_data_dark,1) > 32
                    gap_x = 5;
                    gap_y = 15;
                end
                better_subplot(grid_rows(cond), grid_columns(cond), dframe, gap_x, gap_y);
                yline(0);
                hold on
                plot(ts, squeeze(plot_data_dark(dframe, :)));
                ylim(dark_yax);
                % if dframe == 1
                %     ylabel('volts');
                % end
                % if dframe == (grid_rows(cond) - 1)*grid_columns(cond) + 1
                %     xlabel('ms');
                % end
                set(gca, 'Xcolor', '#F0F0F0', 'Ycolor', '#F0F0F0');
                set(gca, 'XTick', []);
                set(gca, 'YTick', []);
                set(gca, 'color', '#F0F0F0');
            % end
        end
        
        sgtitle(dark_plot_title);
       

        hold off 
        newfig = figure;

        for lframe = 1:size(plot_data_light,1)
             if size(plot_data_light,1) > 32
                gap_x = 5;
                gap_y = 15;
            end
            better_subplot(grid_rows(cond), grid_columns(cond), lframe, gap_x, gap_y);
            yline(0);
            hold on
            plot(ts, squeeze(plot_data_light(lframe, :)));
            ylim(light_yax);
            % if lframe == 1
            %     ylabel('volts');
            % end
            % if lframe == (grid_rows(cond) - 1)*grid_columns(cond) + 1
            %     xlabel('ms');
            % end
            set(gca, 'Xcolor', '#F0F0F0', 'Ycolor', '#F0F0F0');
            set(gca, 'XTick', []);
            set(gca, 'YTick', []);
            set(gca, 'color', '#F0F0F0');
            sgtitle(light_plot_title);

            hold off


        end

        
    end

end
