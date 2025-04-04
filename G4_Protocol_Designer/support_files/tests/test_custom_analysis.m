function [left_wing, right_wing] = test_custom_analysis(data)

    % data{1} = data collected from channel 1 (LmR data in the case of our lab).
    % data{2} = data collected from channel 2 (Left wing data)
    % data{3} = data collected from channel 3 (Right wing data)
    % data{4} = data collected from channel 4 (WBF data)
    % left_wing is the data you want plotted for the left wing
    % right_wing is the data you want plotted for the right wing

    % Do any analysis you want to do on the data in this function and then
    % return left_wing and right_wing to see them plotted on the axis on
    % the Conductor.

    left_wing = {1:100};
    right_wing = {100:-1:1};


end