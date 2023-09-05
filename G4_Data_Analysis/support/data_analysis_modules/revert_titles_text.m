function [ts_set, tc_set] = revert_titles_text(text_to_remove, ts_set, tc_set)

    for revert_name = 1:length(ts_set.figure_names)
        ts_set.figure_names(revert_name) = erase(ts_set.figure_names(revert_name), text_to_remove);
    end
    for revert_fa = 1:length(ts_set.faLmR_figure_names)
        ts_set.faLmR_figure_names(revert_fa) = erase(ts_set.faLmR_figure_names(revert_fa),text_to_remove);
    end
    for revert_subname = 1:length(ts_set.subplot_figure_title)
        for revert_datasubname = 1:length(ts_set.subplot_figure_title{revert_subname})
            ts_set.subplot_figure_title{revert_subname}(revert_datasubname) = erase(ts_set.subplot_figure_title{revert_subname}(revert_datasubname), text_to_remove);
        end
    end
    for revert_faname = 1:length(ts_set.faLmR_subplot_figure_titles)
        ts_set.faLmR_subplot_figure_titles(revert_faname) = erase(ts_set.faLmR_subplot_figure_titles(revert_faname), text_to_remove);
    end
    for revert_tcname = 1:length(tc_set.figure_names)
        tc_set.figure_names(revert_tcname) = erase(tc_set.figure_names(revert_tcname), text_to_remove);
    end
    for revert_tcsubname = 1:length(tc_set.subplot_figure_title)
        for revert_tcdatasubname = 1:length(tc_set.subplot_figure_title{revert_tcsubname})
            tc_set.subplot_figure_title{revert_tcsubname}(revert_tcdatasubname) = erase(tc_set.subplot_figure_title{revert_tcsubname}(revert_tcdatasubname), text_to_remove);
        end
    end

end
