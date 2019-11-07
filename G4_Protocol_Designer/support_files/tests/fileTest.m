function tests = fileTest
    tests = functiontests(localfunctions);
end

%% test import_folder against typical but empty directory structure
function testG4DocumentImportFolder(testCase)
    disp('This test should end by itself. There is an error in G4_document.import_folder() if you have to CTRL-C out of it');
    testpath = tempname;
    mkdir(testpath);
    mkdir(testpath, 'Functions');
    mkdir(testpath, 'Patterns');
    t1 = timer('StartDelay', 1);
    t1.TimerFcn = 'delete(findall(0, ''Tag'', ''Msgbox_Import Successful''))';    
    t2 = timer('StartDelay',2);
    t2.TimerFcn = 'com.mathworks.mde.cmdwin.CmdWinMLIF.getInstance().processKeyFromC(2,67,''C'')';
    start(t1);
    start(t2);
    g4doc = G4_document();
    g4doc.import_folder(testpath);
    rtn = get(t2, 'Running');
    stop(t2); 
    delete(t1);delete(t2);
    rmdir(testpath, 's');
    verifyEqual(testCase, 'on', rtn)
end

%% test import_folder against directory structure with one more directory level
function testG4DocumentImportNestedFolder(testCase)
    disp('This test should end by itself. There is an error in G4_document.import_folder() if you have to CTRL-C out of it');
    testpath = tempname;
    mkdir(testpath);
    mkdir(testpath, 'Functions');
    mkdir(testpath, 'Patterns');
    mkdir(fullfile(testpath, 'Functions'), 'subdirectory');
    t1 = timer('StartDelay', 1);
    t1.TimerFcn = 'delete(findall(0, ''Tag'', ''Msgbox_Import Successful''))';    
    t2 = timer('StartDelay',2);
    t2.TimerFcn = 'com.mathworks.mde.cmdwin.CmdWinMLIF.getInstance().processKeyFromC(2,67,''C'')';
    start(t1);
    start(t2);
    g4doc = G4_document();
    g4doc.import_folder(testpath);
    rtn = get(t2, 'Running');
    stop(t2);
    delete(t1);delete(t2);
    rmdir(testpath, 's');
    verifyEqual(testCase, 'on', rtn)
end



