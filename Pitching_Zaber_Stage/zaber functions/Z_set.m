function result = Z_set(obj, aSetting, aValue)
% SET Write a value to a device setting.
% result = device.set(setting, value)
%
% setting - Numeric identifier for the setting to write. For legal
%           values, see the Zaber ASCII protocol manual:
%           http://www.zaber.com/wiki/Manuals/ASCII_Protocol_Manual#Device_Settings
% value   - New value of the setting, as a 32-bit integer or a string.
%           Note that many settings expect integer values and will
%           produce an error if sent a number with a decimal point.
%           If passing in a number that is not expected to have a
%           decimal point, it is recommended that you cast it to
%           int32 first.
% result  - True if the write succeeded, or the reply message if
%           the device returned an error response.
%
% Errors will be thrown if there is a communication error. If the
% setting does not exist, if the setting is read-only, or if the
% value provided is out of range for the setting then a warning
% will occur and the device's response message will be returned.
%
% See also get

    result = false;

    reply = obj.request(sprintf('set %s', aSetting), aValue);

    if (isa(reply, 'Zaber.AsciiMessage'))
        if (reply.IsError)
            warning('Zaber:BinaryDevice:set:writeError', ...
                    'Attempt to read setting %s from device %d resulted in error %s.', ...
                    aSetting, obj.DeviceNo, reply.DataString);
            result = reply.DataString;
        else
            result = true;
        end
    end
end