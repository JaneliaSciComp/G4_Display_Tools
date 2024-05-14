function create_currentExp(exp_folder)


%% check for correct folders
pattern_folder = fullfile(exp_folder, 'Patterns');
function_folder = fullfile(exp_folder, 'Functions');
AO_folder = fullfile(exp_folder, 'Analog Output Functions');

assert(exist(pattern_folder,'dir')==7,'did not detect pattern folder')
assert(exist(function_folder,'dir')==7,'did not detect position function folder')
assert(exist(AO_folder,'dir')==7,'did not detect AO function folder')


%% read patterns
matinfo = dir([pattern_folder '\*.mat']);
patinfo = dir([pattern_folder '\*.pat']);
num_files = length({patinfo.name});

for f = 1:num_files
    currentExp.pattern.pattNames{f} = matinfo(f).name;
    currentExp.pattern.patternList{f} = patinfo(f).name;
    patternIN = load(fullfile(pattern_folder, matinfo(f).name));
    currentExp.pattern.x_num(f) = patternIN.pattern.x_num; % Matlab now has its own built in class "pattern" which conflicts here.
    currentExp.pattern.y_num(f) = patternIN.pattern.y_num;
    currentExp.pattern.gs_val(f) = patternIN.pattern.gs_val;
    currentExp.pattern.arena_pitch(f) = round(rad2deg(patternIN.pattern.param.arena_pitch));
end
currentExp.pattern.num_patterns = num_files;


%% read position functions
matinfo = dir([function_folder '\*.mat']);
pfninfo = dir([function_folder '\*.pfn']);
num_files = length({pfninfo.name});
trial_dur = 0;

for f = 1:num_files
    currentExp.function.functionName{f} = matinfo(f).name;
    currentExp.function.functionList{f} = pfninfo(f).name;
    load(fullfile(function_folder, matinfo(f).name))
    currentExp.function.functionSize(f) = pfnparam.size;
    trial_dur = trial_dur + sum(pfnparam.dur);
end
currentExp.trialDuration = trial_dur/num_files;
currentExp.function.numFunc = num_files;


%% read analog output functions
matinfo = dir([AO_folder '\*.mat']);
afninfo = dir([AO_folder '\*.afn']);
num_files = length({afninfo.name});

for f = 1:num_files
    currentExp.aoFunction.aoFunctionName{f} = matinfo(f).name;
    currentExp.aoFunction.aoFunctionList{f} = afninfo(f).name;
    load(fullfile(AO_folder, matinfo(f).name))
    currentExp.aoFunction.aoFunctionSize(f) = afnparam.size;
end
currentExp.aoFunction.numaoFunc = num_files;


%% save currentExp structure
save(fullfile(exp_folder, 'currentExp.mat'),'currentExp');

end