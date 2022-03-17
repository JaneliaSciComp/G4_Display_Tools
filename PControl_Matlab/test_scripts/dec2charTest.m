classdef dec2charTest < matlab.unittest.TestCase

    methods(Test, TestTags = {'DisplayToolsUtilities', 'helper'})

        function validNumbers(testCase)
            % Randomly test a subset of the acceptable dec2char argument space
            for i = randi([0 255], 1, 50)
                for j = randi([1 128], 1, 50)
                    expectedResult = zeros(1,j);
                    expectedResult(1) = i;
                    testCase.verifyEqual(dec2char(i, j), expectedResult, ...
                        sprintf("dec2char produces an error for value %d and dimension %d", i, j));
                end
            end
        end
        
        function negativeNumbersFail(testCase)
            for i = randi([-128 -1], 1, 10)
                testCase.verifyError(@()dec2char(i, 1), 'G4DT:dec2char:neg');
            end
        end
        
        function largeNumbersFail(testCase)
            for i =  randi([256 65000], 1, 10)
                testCase.verifyError(@()dec2char(i, 1), 'G4DT:dec2char:numchar');
            end
        end
        
        function largeCharactersFail(testCase)
            for i = randi([129 255], 1, 10)
                testCase.verifyError(@()dec2char(1, i), 'G4DT:dec2char:overflow');
            end
        end
    end

end