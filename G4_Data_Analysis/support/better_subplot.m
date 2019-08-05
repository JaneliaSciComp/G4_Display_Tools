function better_subplot(H, W, N)

fig = gcf;
fig_pos = fig.Position;
fig_width = fig_pos(3);
fig_height = fig_pos(4);
gap_x = 50/fig_width;
gap_y = 50/fig_height;

row = ceil(N/W);
col = mod((N-1),W) + 1;

plot_width = (1 - gap_x*(W+1))/W;
plot_height = (1 - gap_y*(H+1))/H;

plot_x = col*gap_x + (col-1)*plot_width;
plot_y = fig_height - (row*gap_y + (row-1)*plot_height);

axes('Position', [plot_x, plot_y, plot_width, plot_height]);

end