function update_display_xy(newString)
% This function update the gain/offset/position of x channel in PControl GUI

global hPcontrol;

if ~isempty(hPcontrol)
    handles = guidata(hPcontrol);
end

X_info = sscanf(newString, '%*s %d %d %d %d %d %d %d %d');
handles.PC.x_gain_val = X_info(1)/10;
set(handles.x_gain_val, 'String', [num2str(handles.PC.x_gain_val) ' X']);
set(handles.x_gain_slider, 'Value', handles.PC.x_gain_val);

handles.PC.x_offset_val = X_info(2)/20;
set(handles.x_offset_val, 'String', [num2str(handles.PC.x_offset_val) ' X']);
set(handles.x_offset_slider, 'Value', handles.PC.x_offset_val);

handles.PC.x_pos = X_info(3) + 1;
set(handles.x_pos_val, 'string', num2str(handles.PC.x_pos));

handles.PC.x_mode = X_info(4);
set(handles.x_loop_menu, 'Value',handles.PC.x_mode+1);

handles.PC.y_gain_val = X_info(5)/10;
set(handles.y_gain_val, 'String', [num2str(handles.PC.y_gain_val) ' X']);
set(handles.y_gain_slider, 'Value', handles.PC.y_gain_val);

handles.PC.y_offset_val = X_info(6)/20;
set(handles.y_offset_val, 'String', [num2str(handles.PC.y_offset_val) ' X']);
set(handles.y_offset_slider, 'Value', handles.PC.y_offset_val);

handles.PC.y_pos = X_info(7) + 1;
set(handles.y_pos_val, 'string', num2str(handles.PC.y_pos));

handles.PC.y_mode = X_info(8);
set(handles.y_loop_menu, 'Value',handles.PC.y_mode+1);

guidata(hPcontrol, handles);
end