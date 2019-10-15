function error = Z_waitforidle(obj, aPingInterval)
% WAITFORIDLE Block until the device stops moving.
% error = device.WAITFORIDLE();
% error = device.WAITFORIDLE(interval);
%
% interval - Optional; number of seconds to wait between checks
%            of the device's state. Defaults to 0.1 seconds.
% error    - Return value, normally empty. If the device
%            entered an error state while this method was
%            checking for idleness, this method will return the
%            error message.
%
% This method will ping the device repeatedly until the device
% either becomes idle or produces an error response.
%
% See also home, stop, moveabsolute, moverelative,
% moveatvelocity, moveindexed

    interval = 0.1;
    if (nargin > 1)
        interval = aPingInterval;
    end

    moving = true;
    if (~obj.IsAxis)
        moving = false;
    end

    while (moving)
        reply = obj.request('', []);
        if (~isa(reply, 'Zaber.AsciiMessage'))
            moving = false;
            error = reply;
        elseif (reply.IsError)
            moving = false;
            error = reply.Data;
        elseif (reply.IsIdle)
            moving = false;
        else
            pause(interval);
        end
    end
end