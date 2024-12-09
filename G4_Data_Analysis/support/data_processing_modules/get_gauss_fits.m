function [gaussVals, gaussFits] = get_gauss_fits(ts_data, medianVoltage, Volt_idx, exp_folder)

    fignum = 1;

    for cond = 1:size(ts_data,2)
        for rep = 1:size(ts_data,3)
            for frame = 1:size(ts_data,4)
                avgVolt = mean(squeeze(ts_data(Volt_idx, cond, rep, frame, :)), 'omitnan');
                gaussVals{cond, rep}(frame) = avgVolt-medianVoltage;              

            end
            vals = gaussVals{cond, rep};
            vals = vals(~isnan(vals));
            x = 2:length(vals)+1;
            y = vals;
            gaussFits{cond, rep} = fit(x.', y.', 'gauss1');

            gauss_title = ['Condition ' num2str(cond) ' Rep ' num2str(rep) ' Gaussian Fit'];
            fig(fignum) = figure;
            fignum = fignum + 1;
            f = gaussFits{cond, rep};
            plot(f, x, y);
            sgtitle(gauss_title);

        end
    end

    savefig(fig, fullfile(exp_folder, 'GaussianFits.fig'));

end