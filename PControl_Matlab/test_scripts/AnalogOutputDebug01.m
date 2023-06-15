%%

% Minimal dependency script to demonstrate a G4 error:
% Whenever there is an activate AO channel command after starting a log,
% this crashes G4 Host with the following output on the application:
% Error: TDMS Advanced Synchronous Write in Advanced TDMS Writes.vi->TDMS Log Module.vi->Logging Loop(TDMS).vi->Main Host.vi

% Full example output in the G4 Host window (v248) is:
% 06/13/2023 16:25:40.896 :  Root Directory Path - C:\Program Files (x86)\HHMI G4\Support files
% 06/13/2023 16:25:41.030 :  PC Name - reiser-ww10.hhmi.org, IP Address - 10.102.40.34, TCP Port - 62222
% 06/13/2023 16:25:43.031 :  Waiting for TCP Connection
% 06/13/2023 16:25:46.007 :  TCP Connection Established
% 06/13/2023 16:25:46.159 :  Change Root Directory received
% 06/13/2023 16:25:46.159 :  Root Directory Path - C:\matlabroot\G4Debug
% 06/13/2023 16:25:46.265 :  Set Control Mode received
% 06/13/2023 16:25:46.266 :  Control Mode - Fixed Rate Position Function
% 06/13/2023 16:25:46.375 :  Set Pattern ID received
% 06/13/2023 16:25:46.378 :  Pattern 1
% 06/13/2023 16:25:46.484 :  Set Pattern Function ID received
% 06/13/2023 16:25:46.486 :  Pattern Function - 1
% 06/13/2023 16:25:46.591 :  Start Log received
% 06/13/2023 16:25:46.704 :  Set Active Analog Output Channels received
% 06/13/2023 16:25:46.751 :  Error: TDMS Advanced Synchronous Write in Advanced TDMS Writes.vi->TDMS Log Module.vi->Logging Loop(TDMS).vi->Main Host.vi
% 06/13/2023 16:25:46.753 :  Error: TDMS Advanced Synchronous Write in Advanced TDMS Writes.vi->TDMS Log Module.vi->Logging Loop(TDMS).vi->Main Host.vi
% 06/13/2023 16:25:46.755 :  Error: TDMS Advanced Synchronous Write in Advanced TDMS Writes.vi->TDMS Log Module.vi->Logging Loop(TDMS).vi->Main Host.vi
% 06/13/2023 16:25:46.758 :  Error: TDMS Advanced Synchronous Write in Advanced TDMS Writes.vi->TDMS Log Module.vi->Logging Loop(TDMS).vi->Main Host.vi
% 06/13/2023 16:25:46.762 :  Error: TDMS Advanced Synchronous Write in Advanced TDMS Writes.vi->TDMS Log Module.vi->Logging Loop(TDMS).vi->Main Host.vi
% 06/13/2023 16:25:46.764 :  Error: TDMS Advanced Synchronous Write in Advanced TDMS Writes.vi->TDMS Log Module.vi->Logging Loop(TDMS).vi->Main Host.vi
% 06/13/2023 16:25:46.766 :  Error: TDMS Advanced Synchronous Write in Advanced TDMS Writes.vi->TDMS Log Module.vi->Logging Loop(TDMS).vi->Main Host.vi
% 06/13/2023 16:25:46.768 :  Error: TDMS Advanced Synchronous Write in Advanced TDMS Writes.vi->TDMS Log Module.vi->Logging Loop(TDMS).vi->Main Host.vi
% 06/13/2023 16:25:46.770 :  Error: TDMS Advanced Synchronous Write in Advanced TDMS Writes.vi->TDMS Log Module.vi->Logging Loop(TDMS).vi->Main Host.vi
% 06/13/2023 16:25:46.771 :  Error: TDMS Advanced Synchronous Write in Advanced TDMS Writes.vi->TDMS Log Module.vi->Logging Loop(TDMS).vi->Main Host.vi
% 06/13/2023 16:25:46.775 :  Error: TDMS Advanced Synchronous Write in Advanced TDMS Writes.vi->TDMS Log Module.vi->Logging Loop(TDMS).vi->Main Host.vi
% 06/13/2023 16:25:46.779 :  Error: TDMS Advanced Synchronous Write in Advanced TDMS Writes.vi->TDMS Log Module.vi->Logging Loop(TDMS).vi->Main Host.vi
% 06/13/2023 16:25:46.781 :  Error: TDMS Advanced Synchronous Write in Advanced TDMS Writes.vi->TDMS Log Module.vi->Logging Loop(TDMS).vi->Main Host.vi
% 06/13/2023 16:25:46.785 :  Error: TDMS Advanced Synchronous Write in Advanced TDMS Writes.vi->TDMS Log Module.vi->Logging Loop(TDMS).vi->Main Host.vi

% Solution: change order of logging and activating the AO channel


%% open connection to G4 Host. The Application must be running
tcpConn = pnet('tcpconnect', 'localhost', 62222)
pause(0.1)


%% set root path [0x43 LEN_LO LEN_HI PATH]
rootPathName = char("C:\matlabroot\G4Debug")
pnet(tcpConn, 'write', char([67 dec2char(length(rootPathName), 2) uint8(rootPathName)]))  
pause(0.1)
ret = pnet(tcpConn, 'read', 65536, 'uint8', 'noblock')

%% set control mode [0x2 0x10 MODE]
pnet(tcpConn, 'write', char([2 16 1])) 
pause(0.1)
ret = pnet(tcpConn, 'read', 65536, 'uint8', 'noblock')

%% set pattern ID [0x3 0x3 PAT_LO PAT_HI]
pnet(tcpConn, 'write', char([3 3 1 0]))  
pause(0.1)
ret = pnet(tcpConn, 'read', 65536, 'uint8', 'noblock')

%% set function ID [0x3 0x15 FUN_LO FUN_HI]
pnet(tcpConn, 'write', char([3 21 1 0]))  
pause(0.1)
ret = pnet(tcpConn, 'read', 65536, 'uint8', 'noblock')

%% Activate AO Channel [0x2 0x11 CHANNEL]
pnet(tcpConn, 'write', char([2 17 1])) 
pause(0.1)
ret = pnet(tcpConn, 'read', 65536, 'uint8', 'noblock')

%% start log [0x1 0x41]
pnet(tcpConn, 'write', char([1 65]))
pause(0.1)
ret = pnet(tcpConn, 'read', 65536, 'uint8', 'noblock')

%% Start display for 5s (50 deci seconds) [0x3 0x21 T_LO T_HI]
pnet(tcpConn, 'write', char([3 33 50 0])) 
pause(0.1)
ret = pnet(tcpConn, 'read', 65536, 'uint8', 'noblock')
pause(5)

%% stoplog [0x1 0x40]
pnet(tcpConn, 'write', char([1 64])) 
pause(0.1)
ret = pnet(tcpConn, 'read', 65536, 'uint8', 'noblock')

pause(2)

%% close connection
pnet(tcpConn, 'close')