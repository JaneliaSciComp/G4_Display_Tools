function value = Z_get(obj, aSetting)
% GET Read a setting from the device.
% value = device.GET(setting)
%
% setting - Name of the setting to read. See the
%           Zaber ASCII protocol manual for legal values:
%           http://www.zaber.com/wiki/Manuals/ASCII_Protocol_Manual#Device_Settings
% value   - Current value of the setting. This can be a number, an
%           array of numbers or a string.
%
% In the event of a communication error, an error will be thrown.
% If the device returns an error result, a warning will occur and
% the method will return the empty array.
%
% See also set

    value = [];
    reply = obj.request('get', aSetting);

    if (isa(reply, 'Zaber.AsciiMessage'))
        if (reply.IsError)
            warning('Zaber:AsciiDevice:get:readError', ...
                    'Attempt to read setting %s from device %d resulted in error %s.', ...
                    aSetting, obj.DeviceNo, reply.DataString);
        else
            if (length(reply.Data) > 0)
                value = reply.Data;
            else
                value = reply.DataString;
            end
        end
    end
end