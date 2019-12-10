% Saving function

function save_figures(save_settings, genotype)
    
    save_path = save_settings.save_path;
    paperunits = save_settings.paperunits;
    orientation = save_settings.orientation;
    x_width = save_settings.x_width;
    y_width = save_settings.y_width;
    

    h =  findobj('type','figure');
    num_figs = length(h);
    for f = 1:num_figs
        h = figure(f);
        set(gcf, 'PaperUnits', paperunits);
        
%         x_width=8 ;y_width=10; %size of pdf ("paper size") to make graphs fill the page
        if f == 1
            set(gcf, 'PaperPosition', [0 0 x_width y_width]);
            %set(gcf, 'PaperPositionMode', 'auto');
            orient(gcf,orientation)
        else
            set(gcf, 'PaperPosition', [0.4 0.4 x_width y_width]);
        end
        
        if length(genotype) == 1
            filename = fullfile(save_path, [genotype{1}, num2str(f)]);
        else
            filename = fullfile(save_path,[genotype{1:end}, num2str(f)]);
        end
        print(h,filename,'-dpdf');
    end


end