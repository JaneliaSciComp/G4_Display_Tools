funcation currentExp = browseExpDir(expDir)

%expDir = 'C:\Current Projects\G4Panels\PControl_G4_V01\Experiment';

patDir = [expDir, '\Patterns'];
patFunDir = [expDir, '\Functions'];
aoFunDir = [expDir, '\AOFunctions'];

if exist(patDir, 'dir')
    patFile = [patDir, '\*.pat'];
    patList = dir(patFile);
    for i = 1:length(patList)
        currentExp.patterns.pattNames{i} = patList(i).name;
    end
end

if exist(patFunDir, 'dir')
    posFunFile = [patFunDir, '\*.pfn'];
    posFunList = dir(posFunFile);
    for i = 1:length(posFunList)
        currentExp.posFunctions.posFunctionName{i} = posFunList(i).name;
    end
end


if exist(aoFunDir, 'dir')
    aoFunFile = [aoFunDir, '\*.afn'];
    aoFunList = dir(aoFunFile);
    for i = 1:length(aoFunList)
        currentExp.aoFunctions.aoFunctionNames{i} = aoFunList(i).name;
    end
end

save('C:\Current Projects\G4Panels\PControl_G4_V01\currentExp.mat', 'currentExp');