function success = connectHost()

global ctlr;

ctlr = PanelsController();
ctlr.open(true);

success = ctrl.isOpen;
