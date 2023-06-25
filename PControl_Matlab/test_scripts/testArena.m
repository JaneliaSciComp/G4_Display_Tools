% Host is not opening correctly. It used to, last time I tested it. I
% updated to the latest pre-release (144) but it's still happening. Ask
% Frank about it.

% Need to test on actual arena

% 2023-06-21 FL: Make it work on MATLAB2019

function testArena
    %% Open new Panels controller instance
    ctlr = PanelsController();
    ctlr.open(true);

    fig = figure('Name', 'Test Setup', 'NumberTitle', 'off', 'units','pixels','MenuBar', 'none', ...
        'ToolBar', 'none', 'Resize', 'off');
    pix = get(0, 'screensize');
    fig_size = [.4*pix(3), .4*pix(4), .2*pix(3), .2*pix(4)];
    set(fig, 'Position', fig_size);

    uicontrol(fig...
        ,'Style','pushbutton'...
        ,'String', 'All On'...
        ,'units','pixels'...
        ,'Position', [.1*fig_size(3), .65*fig_size(4), .8*fig_size(3), .3*fig_size(4)]...
        ,'Callback', {@allLEDOn, ctlr});

    uicontrol(fig...
        ,'Style', 'pushbutton'...
        ,'String', 'All Off'...
        ,'units', 'pixels'...
        ,'Position', [.1*fig_size(3), .35*fig_size(4), .8*fig_size(3), .3*fig_size(4)]...
        ,'Callback', {@allLEDOff ,ctlr});
end

function allLEDOn(src,event,ctrl)
%% Callback wrapper function to gain access to the ctrl
%  Turning on all LEDs
    ctrl.allOn();
end

function allLEDOff(src,event,ctrl)
%% Callback wrapper function to gain access to the ctrl
%  Turning off all LEDs
    ctrl.allOff();
end
