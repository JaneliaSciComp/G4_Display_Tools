function save_figure(save_settings, varargin)
    
    savename = varargin{1};
    for i = 2:length(varargin)
        savename = savename + "_" + varargin{i};
    end
    
    save_path = fullfile(save_settings.save_path, savename);
    paperunits = save_settings.paperunits;
    orientation = save_settings.orientation;
    x_width = save_settings.x_width;
    y_width = save_settings.y_width;
    
    set(gcf, 'PaperUnits', paperunits);
    set(gcf, 'PaperPosition', [0.4 0.4 x_width y_width]);
    orient(gcf, orientation);
    print(save_path,'-dpdf');
    close(gcf);

end