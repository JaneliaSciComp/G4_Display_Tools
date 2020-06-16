function [gap_x, gap_y] = get_plot_spacing(num_rows, num_cols)

    gap_x = 20;

    if num_rows - 1 > num_cols
        gap_y = 90;

    elseif num_rows > num_cols
        gap_y = 70;

    elseif num_rows + 1 < num_cols

        gap_y = 30;

    elseif num_rows < num_cols

        gap_y = 40;

    else
        gap_y = 50;
    end

end