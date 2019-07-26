function update_status_display(new_string)
% this function updates the status display box at the bottom of the GUI

global hPcontrol;
if isempty(hPcontrol)
    Panel_com('quiet_mode_on');
    %disp(new_string);
else
    handles = guihandles(hPcontrol);
    rowNum = size(new_string, 1);
    
    %disp(new_string);
    for i = 1:rowNum
        if (i == 1)
            temp_cell_array = [' > ' new_string];
        else
            temp_cell_array = new_string;
        end
    end
    
    set(handles.status_display, 'String', cat(1,{temp_cell_array},...
        get(handles.status_display, 'String')));
end
