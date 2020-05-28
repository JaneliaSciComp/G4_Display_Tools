function better_subplot(H, W, N, pix_x, pix_y)

if ~exist('pix_x','var')
    pix_x = 20;
end
if~exist('pix_y','var')
    pix_y = 35;
end
fig = gcf;
fig_pos = fig.Position;
fig_width = fig_pos(3);
fig_height = fig_pos(4);
gap_x = pix_x/fig_width;%20
gap_y =pix_y/fig_height;%35

row = ceil(N/W);
col = mod((N-1),W) + 1;

plot_width = (1 - gap_x*(W+1))/W;
plot_height = (1 - gap_y*(H+1))/H;



plot_x = col*gap_x + (col-1)*plot_width + .015;
plot_y = row*gap_y + (row-1)*plot_height; %This equation was giving a huge number (200 and something) for a normalized y position. changed equation to match above - LT 8/15

% if rem(N-1,W) == 0
%     %Then the plot is on the left column. Add 15 pixels to its plot_width
%     %so the y axis label is not cut off
%     plot_x = plot_x+.015;
% end
axes('Position', [plot_x, (1 - plot_height) - plot_y, plot_width, plot_height]);

end