% Host is not opening correctly. It used to, last time I tested it. I
% updated to the latest pre-release (144) but it's still happening. Ask
% Frank about it.

global ctlr;

 if ~isempty(ctlr)
    if ctlr.isOpen() == 1
       ctlr.close()
    end
end

%% Open new Panels controller instance
ctlr = PanelsController();
ctlr.mode = 0;
ctlr.open(true);

fig = figure('Name', 'Test Setup', 'NumberTitle', 'off', 'units','pixels','MenuBar', 'none', ...
                'ToolBar', 'none', 'Resize', 'off');
pix = get(0, 'screensize');
fig_size = [.4*pix(3), .4*pix(4), .2*pix(3), .2*pix(4)];
set(fig, 'Position', fig_size);


all_on_button = uicontrol(fig,'Style','pushbutton', 'String', 'All On', 'units', ...
    'pixels', 'Position', [15, 15, .8*fig_size(3), .3*fig_size(4)],'Callback', ctlr.allOn());

all_off_button = uicontrol(fig, 'Style', 'pushbutton', 'String', 'All Off', 'units', ...
    'pixels', 'Position', [15, .3*fig_size(4) + 30, .8*fig_size(3), .3*fig_size(4)], ...
    'Callback', ctlr.allOff());

