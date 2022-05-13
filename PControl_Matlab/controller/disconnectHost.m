function disconnectHost

global ctlr;

if isa(ctlr, 'PanelsController')
    ctlr.close();
end
clear global;
