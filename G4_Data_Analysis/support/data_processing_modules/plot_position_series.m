function plot_position_series(mean_pos_series)

    subplot(3,2,1)
    hold on;
    plot(mean_pos_series(1:2,:)', '.r')

    subplot(3,2,2)
    hold on; 
    plot(mean_pos_series(3:4,:)', '.r')

    P1b = nanmean([mean_pos_series(1,:); mean_pos_series(2,:)],1);
    M1b = nanmean([mean_pos_series(1,:); -mean_pos_series(2,:)],1);

    P2b = nanmean([mean_pos_series(3,:); mean_pos_series(4,:)],1);
    M2b = nanmean([mean_pos_series(3,:); -mean_pos_series(4,:)],1);

    subplot(323); 
    hold on; plot(P1b, '.r')

    subplot(324);
    hold on; plot(P2b, '.r')


end