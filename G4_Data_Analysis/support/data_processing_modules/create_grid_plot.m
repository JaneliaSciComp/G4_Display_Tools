function create_grid_plot(dark_data, light_data, grid_rows, grid_columns, plot_chan, timestamps)
    
%% Need to switch back to passing in all data. WIll want to plot each rep individually
% in light color and then the average thicker on each axis. 
    
    for cond = 1:length(dark_data)
        fig = figure; 
        ts = timestamps{cond};
        for rep = 1:size(dark_data{cond},3)
            rep_data_dark(rep,:,:) = squeeze(dark_data{cond}(plot_chan, 1, rep, :, :));
            rep_data_light(rep,:,:) = squeeze(light_data{cond}(plot_chan, 1, rep, :, :));
        end
        avg_data_dark = squeeze(mean(rep_data_dark,1));
        avg_data_light = squeeze(mean(rep_data_light,1));
        dark_plot_title = ['Condition ' num2str(cond) ' Dark Squares'];
        light_plot_title = ['Condition ' num2str(cond) ' Light Squares'];
        dark_yax = [min(min(avg_data_dark)) max(max(avg_data_dark))];
        light_yax = [min(min(avg_data_light)) max(max(avg_data_light))];
        [gap_x, gap_y] = get_plot_spacing(grid_rows(cond), grid_columns(cond));
        for dframe = 1:size(avg_data_dark,1)
            % if sum(~isnan(data_to_plot(dframe, :))) > 0
                if size(avg_data_dark,1) > 32
                    gap_x = 5;
                    gap_y = 15;
                end
                better_subplot(grid_rows(cond), grid_columns(cond), dframe, gap_x, gap_y);
                yline(0);
                hold on
                for rep = 1:size(rep_data_dark,1)
                    plot(ts, squeeze(rep_data_dark(rep, dframe,:)));
                end
                plot(ts, squeeze(avg_data_dark(dframe, :)), 'Color', 'black', 'Linewidth', 2.0);
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

        for lframe = 1:size(avg_data_light,1)
             if size(avg_data_light,1) > 32
                gap_x = 5;
                gap_y = 15;
            end
            better_subplot(grid_rows(cond), grid_columns(cond), lframe, gap_x, gap_y);
            yline(0);
            hold on
            for rep = 1:size(rep_data_light,1)
                plot(ts, squeeze(rep_data_light(rep, dframe,:)));
            end
            plot(ts, squeeze(avg_data_light(lframe, :)), 'Color', 'black', 'Linewidth', 2.0);
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

        rep_data_dark = [];
        rep_data_light = [];

        
    end

end
