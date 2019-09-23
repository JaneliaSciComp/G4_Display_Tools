%% initialization
Z_port = serial('COM6');

%initialize zaber stage for binary protocol
% set(Zaber_obj, ...
%     'BaudRate', 9600, ...
%     'DataBits', 8, ...
%     'FlowControl', 'none', ...
%     'Parity', 'none', ...
%     'StopBits', 1);
% set(Zaber_obj, 'Timeout', 0.5)
% warning off MATLAB:serial:fread:unsuccessfulRead

%initialize zaber stage for ASCII protocol
set(Z_port, ...
    'BaudRate', 115200, ...
    'DataBits', 8, ...
    'FlowControl', 'none', ...
    'Parity', 'none', ...
    'StopBits', 1, ...
    'Terminator','CR/LF');

set(Z_port, 'Timeout', 0.5)
warning off MATLAB:serial:fgetl:unsuccessfulRead

%open the port
fopen(Z_port);

%detect device
% protocol = Zaber.Protocol.detect(Z_port);
protocol = Zaber.AsciiProtocol(Z_port);
%%


%identify binary device
% device1 = Zaber.BinaryDevice.initialize(protocol, 1);

%identify ASCII device
Zaber_device = Zaber.AsciiDevice.initialize(protocol, 1);


%% commands

%move absolute
error = Zaber_device.multiaxiscommand('move abs', int32(aPosition))

%move relative
aDelta = 10;
error = Zaber_device.multiaxiscommand('move rel', int32(aDelta))

%move at velocity
error = Zaber_device.multiaxiscommand('move vel', int32(aVelocity))

%get position
pos = Zaber_device.get('pos');

%read a setting
value = Z_get(Zaber_device, aSetting);

%write a setting
Z_set(Zaber_device, aSetting, aValue);

%wait for idle
error = Z_waitforidle(Zaber_device, aPingInterval)

%stop if moving
error = Z_stop(Zaber_device)



      