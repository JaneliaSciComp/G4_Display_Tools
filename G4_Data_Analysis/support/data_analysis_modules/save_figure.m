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
    res = save_settings.high_resolution;
    
    h =  findobj('type','figure');
    fig_to_save = h(1);
    
    set(fig_to_save, 'PaperUnits', paperunits);
    set(fig_to_save, 'PaperPosition', [0.4 0.4 x_width y_width]);
    orient(fig_to_save, orientation);
    if res == 1
        print(fig_to_save, save_path, '-painters', '-dpdf','-r300');
    else
        print(fig_to_save, save_path, '-dpdf');
    end
    savefig(save_path)
    close(fig_to_save);


end
