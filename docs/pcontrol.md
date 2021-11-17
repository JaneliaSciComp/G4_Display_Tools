---
title:  PControl
parent: Generation 4
nav_order: 15
---

# PControl

Running the [G4 Host]({{site.baseurl}}Display_Tools/docs/software_setup.html) software initiates the IO card of the system to start a TCP/IP server on the `localhost` at port `62222`. Through this TCP/IP connection, it is possible to communicate directly with the arena. Here we list the commands available in `Panel_com` which would allow you to implement the same functionality in a language of your choosing. For simplicity we document both, MATLAB's `Panel_com` command as well as the underlying TCP/IP data exchange. For the TCP/IP we use python as an example.

## Initiate the connection

Once the G4 Host application is running, you should be able to open a TCP/IP connection to port 62222 on the local machine.

```python
import socket

HOST = 'localhost'
PORT = 62222

with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
    try:
        s.connect((HOST, PORT))
    except ConnectionRefusedError:
        print(f"G4 Host doesn't appear to be running on {HOST}:{PORT}")
    # … commands follow here
```

The code above establishes a tcp connection similar to what the MATLAB code `connectHost;` does, which is a wrapper around `PanelController`:

```matlab
ctlr = PanelsController();
ctlr.mode = 0;
ctlr.open();
```

The `PanelController` is a class that handles the connection on the TCP/IP level. In your own code, it's good enough to use the following to initiate the connection:

```matlab
connectHost;
% … commands follow here
```

### Turn all panels on

This commamnd turns all panels on to the brightest level. If the arena is already on, you should not see a change. Use this for checking if your arena works.

This is a two-byte command (notation in hexadecimal): first byte is set to `0x01` (`1` in integer, `0b00000001` in binary), the second is `0xff` (`255` in decimal, `0b11111111` in binary). The following commands will only use hexadecimal notation of the bytes.

```python
    # … initiate the connection (see above)
    s.sendall(b'\x01\xff')
```

The corresponding MATLAB code:

```matlab
% … initiate the connection (see above)
Panel_com('all_on');
```

### Turn all panels off

This command turns all panels off. If the arena is already turned off, there will be no change.

This is a two-byte command with the first byte `0x01` and the second `0x00`.

```python
    # … initiate the connection (see above)
    s.sendall(b'\x01\x00')
```

The corresponding MATLAB code:

```matlab
% … initiate the connection (see above)
Panel_com('all_off');
```

### Stop Display

This command deactivates the display.

This is a two-byte command with the first byte `0x01` and the second `0x30`.

```python
    # … initiate the connection (see above)
    s.sendall(b'\x01\x30')
```

The corresponding MATLAB code:

```matlab
% … initiate the connection (see above)
Panel_com('stop_display');
```

### Reset Display

Reset the display. All panels will be off.

This is a two-byte command with the first byte `0x01` and the second `0x01`.

```python
    # … initiate the connection (see above)
    s.sendall(b'\x01\x01')
```

The corresponding MATLAB code:

```matlab
% … initiate the connection (see above)
Panel_com('reset_display');
```

### Reset Panel

Reset a single panel.

This is a three-byte command with the first bye `0x02`, the second `0x01`, and the third the address of the panel.

```python
    # … initiate the connection (see above)
    panel_number = 2
    s.sendall(b'\x01\x01' + bytes([panel_number]))
```

The corresponding MATLAB code:

```matlab
% … initiate the connection (see above)
Panel_com('reset', 2);
```

### Controller reset

This is a two-byte command with the first byte `0x01` and the second `0x60`.

```python
    # … initiate the connection (see above)
    s.sendall(b'\x01\x60')
```

The corresponding MATLAB code:

```matlab
% … initiate the connection (see above)
Panel_com('ctr_reset');
```

### Get Version

This is a two-byte command with the first byte `0x01` and the second `0x46`. It returns the version and Panel_com logs this to the error log file.

```python
    # … initiate the connection (see above)
    s.sendall(b'\x01\x46')
    # … add code to read data, eg:
    rsp = s.recv(1024)
```

The corresponding MATLAB code:

```matlab
% … initiate the connection (see above)
Panel_com('get_version');
```

### Reset Counter

This is a two-byte command with the first byte `0x01` and the second `0x42`.

__Note__: This command is currently not used. TODO: Explain usage.
{:.warning}

```python
    # … initiate the connection (see above)
    s.sendall(b'\x01\x42')
```

The corresponding MATLAB code:

```matlab
% … initiate the connection (see above)
Panel_com('reset_counter');
```

### Request Treadmill Data

This is a two-byte command with the first byte `0x01` and the second `0x45`.

__Note__: This command is currently not used. TODO: Explain usage.
{:.warning}

```python
    # … initiate the connection (see above)
    s.sendall(b'\x01\x45')
```

The corresponding MATLAB code:

```matlab
% … initiate the connection (see above)
Panel_com('request_treadmill_data');
```

### Update GUI Info

This is a two-byte command with the first byte `0x01` and the second `0x19`.

__Note__: This is supposed to update gain, offset, and position information (according to code comments). TODO: Explain usage.
{:.warning}

```python
    # … initiate the connection (see above)
    s.sendall(b'\x01\x19')
```

The corresponding MATLAB code:

```matlab
% … initiate the connection (see above)
Panel_com('update_gui_info');
```

### Start Log

Sending this command starts the logging process. The data is logged directly from the IO card and into the TDMS file format (see [data handling](data-handling.md)).

This is a two-byte command with the first byte `0x01` and the second `0x41`.


```python
    # … initiate the connection (see above)
    s.sendall(b'\x01\x41')
```

The corresponding MATLAB code:

```matlab
% … initiate the connection (see above)
Panel_com('start_log');
```

### Stop Log

Sending this command stops the logging process.

__Note__: This command seems to respond slowly. The MATLAB code has some fallback and potential manual intervention: if the stop_log fails, MATLAB tries again after 100ms. If that still fails, a popup window asks the user to manually stop  the log file. If you use the TCP/IP command, try to use a similar strategy.

This is a two-byte command with the first byte `0x01` and the second `0x40`.

```python
    # … initiate the connection (see above)
    s.sendall(b'\x01\x40')
```

The corresponding MATLAB code:

```matlab
% … initiate the connection (see above)
Panel_com('stop_log');
```

### Set Control Mode

This defines the [display mode](protocol-designer_display-modes.md) and requires an argument between 0 and 7.

This is a three-byte command with the first byte `0x02`, the second `0x10`, and the third with the desired control mode. The MATLAB code sends the command in blocking mode, so you might want to set the `MSG_WAITALL` flag in the `sendall` call. 

```python
    # … initiate the connection (see above)
    mode = 1
    assert 0 <= mode <= 7, "display mode outside allowed range 0…7"
    s.sendall(b'\x02\x10' + bytes([mode]))
```

The corresponding MATLAB code:

```matlab
% … initiate the connection (see above)
Panel_com('set_control_mode', 1);
```

### Set active Analog Output Channels

This command activates or deactivates the four possible output channels. The channels are encoded as binary flags, channel 0 for the lowest bit, channel 1 for the second etc… Channel 0 would therefore be `0b00000001`, channels 1 and 3 would be `0b00001010`.

This is a three-byte command with the first byte `0x02`, the second `0x11`, and the third the required channels.

```python
    # … initiate the connection (see above)
    ao_channels = 0b0000_0101 # Channel 0 and 2
    assert 0 <= ao_channels < 16, 
        "Wrong AO modes selected. Only 0b0000_0000 to 0b00001111 is allowed."
    s.sendall(b'\x02\x10' + bytes([ao_channels]))
```

The corresponding MATLAB code:

```matlab
% … initiate the connection (see above)
Panel_com('set_active_ao_channels', '0101'); % Only last 4 bits required.
```

### Stream channels

The command is used to set the analog input channels.

This is a three-byte command with the first byte `0x02`, the second `0x13`, and the third the active channels.

__Note__: TODO: The exact usage is unlcear. 

```python
    # … initiate the connection (see above)
    channels = 1 # unclear what this represents
    s.sendall(b'\x02\x13' + bytes([channels]))
```

The corresponding MATLAB code:

```matlab
% … initiate the connection (see above)
Panel_com('stream_channels', '1');
```

### Set Pattern ID

Displays the pattern with the specified ID on the panels.

This is a four-byte command with the first byte `0x03`, the second `0x03`, and the thrird and fourth byte defining the address in MSB.

```python
    # … initiate the connection (see above)
    pattern_id = b'\x05\x05'
    s.sendall(b'\x03\x03' + pattern_id)
```

The corresponding MATLAB code:

```matlab
% … initiate the connection (see above)
Panel_com('set_pattern_id', '1285'); 
```

### Set Pattern Function ID

Use a the function with the specified ID.

This is a four-byte command with the first byte `0x03`, the second `0x15`. The use of the third and fourth byte are unclear, but most likely they refer to an ID just like the pattern ID.

```python
    # … initiate the connection (see above)
    func_pattern_id = b'\x02\x07'
    s.sendall(b'\x03\x15' + func_pattern_id)
```

The corresponding MATLAB code:

```matlab
% … initiate the connection (see above)
Panel_com('set_pattern_id', '1794'); 
```

### Start Display

Start Display tells the arena to show the currently configured function and pattern for a specified time. The time in the TCP/IP command is specified in tenth of a second.

This is a four-byte command with the first byte `0x03`, the second `0x21` and the third and fourth representing the time.

```python
    # … initiate the connection (see above)
    duration = 6 * 10  # 60 deciseconds = 6 seconds
    s.sendall(b'\x03\x15' + duration.to_bytes(2, 'little') )
```

The corresponding MATLAB code (internal conversion from second to decisecond):

```matlab
% … initiate the connection (see above)
Panel_com('start_display', 6); 
```

### Set Framerate

```python
    # … initiate the connection (see above)
    fps = 500
    s.sendall(b'\x03\x12' + fps.to_bytes(2, 'little') )
```

The corresponding MATLAB code:

```matlab
% … initiate the connection (see above)
Panel_com('set_frame_rate', 500); 
```

### Set Position X

```python
    # … initiate the connection (see above)
    pos_x = 17
    s.sendall(b'\x03\x70' + pos_x.to_bytes(2, 'little') )
```

The corresponding MATLAB code:

```matlab
% … initiate the connection (see above)
Panel_com('set_position_x', 17); 
```

### Set Position Y

```python
    # … initiate the connection (see above)
    pos_y = 10
    s.sendall(b'\x03\x71' + pos_y.to_bytes(2, 'little') )
```

The corresponding MATLAB code:

```matlab
% … initiate the connection (see above)
Panel_com('set_position_y', 10); 
```

### Set Analog Output Function ID

```python
    # … initiate the connection (see above)
    chan = 1 # 0…3
    index = 23
    assert 0 <= chan  <= 3, "channel outside range"
    s.sendall(b'\x03\x31' + bytes([chan]) + bytes([index]))
```

The corresponding MATLAB code:

```matlab
% … initiate the connection (see above)
Panel_com('set_ao_function_id', 1, 23); 
```

### Set Analog Output

Set the voltage of a channel to a specified value.

```python
    # … initiate the connection (see above)
    chan = 1 # 0…3
    voltage = 32767 # -32767…0…32767 → -10V…0V…10V
    assert 0 <= chan  <= 3, "channel outside range"
    assert -32767 <= voltage <= 32767, "voltage outside range"
    if voltage < 0:
        s.sendall(b'\x04\x11' + bytes([chan]) + bytes([abs(voltage)]))
    else:
        s.sendall(b'\x04\x10' + bytes([chan]) + bytes([voltage]))
```

The corresponding MATLAB code:

```matlab
% … initiate the connection (see above)
Panel_com('set_ao', 1, 32767); 
```

### Set Gain Bias

```python
    # … initiate the connection (see above)
    gain_x = 100
    bias_x = 200
    s.sendall(b'\x05\x01' +
        gain_x.to_bytes(2, 'little', signed=True) +
        bias_x.to_bytes(2, 'little', signed=True))
```

The corresponding MATLAB code:

```matlab
% … initiate the connection (see above)
Panel_com('set_gain_bias', 100, 100); 
```

### Set Pattern and Position Function

```python
    # … initiate the connection (see above)
    pattern = 5
    position = 37
    s.sendall(b'\x05\x05' +
        pattern.to_bytes(2, 'little') +
        position.to_bytes(2, 'little'))
```

The corresponding MATLAB code:

```matlab
% … initiate the connection (see above)
Panel_com('set_pattern_and_position_function', 100, 100); 
```

### Stream Frame

### Change Root Directory

### Combined Commmand