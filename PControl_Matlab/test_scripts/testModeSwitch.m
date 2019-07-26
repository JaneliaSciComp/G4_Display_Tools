%Panel_com('ctr_reset');
%pause(0.5);
dos('avrdude -p atxmega128a1 -P COM5 -b 115200 -c avr109 -e -U flash:w:panelcontrollerMode2.hex');