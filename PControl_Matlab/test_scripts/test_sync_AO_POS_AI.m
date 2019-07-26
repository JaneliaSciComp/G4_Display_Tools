%this script is used to test the synchronization of AI1, AO2 fucntion, and
%posiiton index for G4

filename = 'D:\G4_PanelController\Experiment\Log Files\04-20-2016_11-11-31-06.tdms';
dd = TDMS_getStruct(filename);
figure;
tai = dd.ADC0.Time.data;
vai = dd.ADC0.Voltage.data;
tao = dd.AO2.Time.data;
vao = dd.AO2.Voltage.data;
tpx = dd.Pattern_Position.Time.data;
vpx = dd.Pattern_Position.X_Index.data;
plot(tai,vai);
hold on;
plot(tao,vao);
plot(tpx,vpx);