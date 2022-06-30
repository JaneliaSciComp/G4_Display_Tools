function [ts_set, tc_set] = add_titles_text(text, ts_set, tc_set)
    
    if ~isempty(ts_set.figure_names)
        for name = 1:length(ts_set.figure_names)
           ts_set.figure_names(name) = ts_set.figure_names(name) + text;
        end
    end
    
    if ~isempty(ts_set.faLmR_figure_names)
        for faName = 1:length(ts_set.faLmR_figure_names)
           ts_set.faLmR_figure_names(faName) = ts_set.faLmR_figure_names(faName) + text;
        end
    end
    
    if ~isempty(ts_set.subplot_figure_title)
        for subname = 1:length(ts_set.subplot_figure_title)
            for datasubname = 1:length(ts_set.subplot_figure_title{subname})
                ts_set.subplot_figure_title{subname}(datasubname) = ts_set.subplot_figure_title{subname}(datasubname) + text;
            end
        end
    end
    
    if ~isempty(ts_set.faLmR_subplot_figure_titles)
        for fasubname = 1:length(ts_set.faLmR_subplot_figure_titles)

            ts_set.faLmR_subplot_figure_titles(fasubname) = ts_set.faLmR_subplot_figure_titles(fasubname) + text;

        end
    end
    
    if ~isempty(tc_set.figure_names)
        for tcname = 1:length(tc_set.figure_names)
           tc_set.figure_names(tcname) = tc_set.figure_names(tcname) + text;
        end
    end
    
    if ~isempty(tc_set.subplot_figure_title)
        for subtcname = 1:length(tc_set.subplot_figure_title)
            for datatcsubname = 1:length(tc_set.subplot_figure_title{subtcname})
                tc_set.subplot_figure_title{subtcname}(datatcsubname) = tc_set.subplot_figure_title{subtcname}(datatcsubname) + text;
            end
        end
    end

end