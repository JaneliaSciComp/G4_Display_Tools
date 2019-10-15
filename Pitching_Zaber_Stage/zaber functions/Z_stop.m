function error = Z_stop(obj)
% STOP Stop the device if it is moving.
% error = device.STOP();
%
% error    - Error information from the device(s), if any.
%
% If this device is a multi-axis controller, all axes will be
% stopped. To stop an individual axis, retrieve it from the Axes
% property and invoke its stop method instead.
%
% See also waitforidle, moveabsolute, moverelative, moveatvelocity,
% moveindexed

    error = [];

    reply = obj.request('stop', []);

    if (isa(reply, 'Zaber.AsciiMessage') && reply.IsError)
        error = reply.DataString;
    end
end