filename = 'C:\Program Files (x86)\G4 Host\Support Files\Log Files\08-28-2015_11-11-02-46.tdms';
dd = TDMS_getStruct(filename);
FX = dd.Pattern_Position.X_Index.data;
FY = dd.Pattern_Position.Y_Index.data;
FT = dd.Pattern_Position.Time.data;
figure, plot(FT, FX);
plot(FT, FY, 'r--');