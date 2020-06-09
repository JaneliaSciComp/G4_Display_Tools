function create_plot_figure(data, gen_settings, plot_settings, save_settings, ...
     indices, genotype, control_genotype, plot_type)

   % variables from general settings - same for all plot types
    
    rep_colors = gen_settings.rep_colors; 
    fly_colors = gen_settings.fly_colors;
    mean_colors = gen_settings.mean_colors;    
    subtitle_fontSize = gen_settings.subtitle_fontSize;
    legend_fontSize = gen_settings.legend_fontSize;
    yLabel_fontSize = gen_settings.yLabel_fontSize;
    xLabel_fontSize = gen_settings.xLabel_fontSize;
    axis_num_fontSize = gen_settings.axis_num_fontSize;
    axis_label_fontSize = gen_settings.axis_label_fontSize;
    rep_lineWidth = gen_settings.rep_lineWidth;
    control_color = gen_settings.control_color;
    mean_lineWidth = gen_settings.mean_lineWidth;
    edgeColor = gen_settings.edgeColor;
    patch_alpha = gen_settings.patch_alpha;
    
    
    % variables from specific plot settings
    conds = plot_settings.conds;
    cond_name = plot_settings.cond_name;
    left_col_places = plot_settings.left_column_places;
    top_left_place = plot_settings.top_left_place;
    bottom_left_place = plot_settings.bottom_left_place;
    axis_labels = plot_settings.axis_labels;
    figure_names = plot_settings.figure_names;
    figure_titles = plot_settings.figure_titles;
    xlimits = plot_settings.xlimits;
    ylimits = plot_settings.ylimits;
    xaxis = plot_settings.xaxis;
    
    switch plot_type
        
        case 'TS'
            
            show_ind_flies = plot_settings.show_individual_flies;
            frame_scale = plot_settings.frame_scale;
            frame_color = plot_settings.frame_color;
            frame_superimpose = plot_settings.frame_superimpose;
            frame_index = indices.Frame_ind;
            plot_both_directions = plot_settings.plot_both_directions;
            inds = indices.OL_inds;
            
        case 'TC'
            
            marker_type = TC_plot_settings.marker_type;
            plot_both_directions = plot_settings.plot_both_directions;
            inds = indices.TC_inds;

            
        case 'MP'
            
            show_ind_flies = plot_settings.show_individual_flies;
            new_xaxis = plot_settings.new_xaxis;
            inds = 1;
            
        case 'pos'
            
            show_ind_flies = plot_settings.show_individual_flies;
            new_xaxis = plot_settings.new_xaxis;
            plot_both_directions = plot_settings.plot_both_directions;
            inds = 1;
    end

    
    % Variables that need to be calculated
    if ~strcmp(data_type, 'MP')
        if size(data,1) == 1 && size(data,2) == 1
            single = 1;
        else 
            single = 0;
        end

        num_groups = size(data,1);
        num_exps = size(data,2);
    else
        if size(data.M,1) && size(data.M,2)
            single = 1;
    
    
    if ~isempty(conds)
        
        for d = inds
            
            ydata = [];
            num_rows = size(conds,1);
            num_cols = size(conds,2);
            figure('Position',[100 100 540 540*(num_rows/num_cols)]);
            for row = 1:num_rows
                for col = 1:num_cols
                    cond = conds(1+(row-1),col);
                    placement = col+num_cols*(row-1);
                    place = row+num_rows*(col-1);
                    if cond>0
                        better_subplot(num_rows, num_cols, placement)
                        if strcmp(plot_type,'MP') || strcmp(plot_type, 'pos')
                             yline(0, 'k--');
                        end
                        hold on
                        for g = 1:num_groups
                            
                            %Get data in final form
                            if strcmp(plot_type, 'TS')
                                tmpdata = squeeze(data(g,:,d,cond,:));
                                meandata = nanmean(tmpdata);
                                nanidx = isnan(meandata);
                                stddata = nanstd(tmpdata);
                                semdata = stddata./sqrt(sum(max(~isnan(tmpdata),[],2)));
                                xaxis = xaxis(~nanidx);
                                meandata(nanidx) = []; 
                                semdata(nanidx) = []; 
                                
                            elseif strcmp(plot_type, 'TC')
                                tmpdata = squeeze(nanmean(data(g,:,d,conds,:),5));
                                
                            elseif strcmp(plot_type, 'MP')
                                M = data.M;
                                P = data.P;
                                M_flies = data.M_flies;
                                P_flies = data.P_flies;
                                
                            
                            
                            
                        end
                        
                        
                    end
                    
                    
                    
                end
                
            end
            
            
            
        end

        
    end
    
    
    
    