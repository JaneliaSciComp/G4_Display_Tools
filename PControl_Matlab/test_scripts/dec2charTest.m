classdef dec2charTest < matlab.unittest.TestCase

    methods(Test, TestTags = {'DisplayToolsUtilities', 'helper'})

        function validUINT8NumbersLongStreamsNumbers(testCase)
            %% Randomly test a subset of the acceptable dec2char argument space. 
            %  Both, the tested value and the dimension are sampled from
            %  within 'uint8' range.
            for i = randi([0 255], 1, 50)
                for j = randi([1 255], 1, 50)                    
                    expectedResult = uint8(zeros(1,j));
                    expectedResult(1) = i;
                    testCase.verifyEqual(dec2char(i, j), expectedResult, ...
                        sprintf("dec2char produces an error for value %d and dimension %d", i, j));
                end
            end
        end
        
        function validNumbers(testCase)
            %% Calculates the bytestreams of different lengths for numbers in the range between 0 and 2^53-2. 
            % Then reconstructs the original number from this and checks if that is correct.
            for i = randi([0 flintmax-2], 1, 50)
                minlength = ceil(log2(i)/8);
                for j = randi([minlength 255], 1, 10)
                    actualStream = dec2char(i, j);
                    actualNumber = uint64(0);
                    for k = 1:length(actualStream)
                        addval = double(bitshift(uint64(actualStream(k)), (k-1)*8));
                        actualNumber = actualNumber + addval;
                    end
                    testCase.verifyEqual(actualNumber, uint64(i), ...
                        sprintf("dec2char produces the wrong stream for value %d and dimension %d", i, j));
                end
            end
        end

        function validNumbersBreakOlddec2char(testCase)
            %% Most of these are numbers broke the previous dec2char function.
            numbers = [   127     128     5000   5000     5000   intmax('uint32')];
            types =   ["uint8" "uint8" "uint16" "int16" "uint16" "uint32"];
            dimensions = [  2       2        2       2        3        4];
            assert(length(numbers) == length(types),...
                "Setup error: numbers and types correspond and have to have the same length");
            assert(length(numbers) == length(dimensions),...
                "Setup error: numbers and dimensions correspond and have to have the same length");
            for i = 1:length(numbers)
                number = numbers(i);
                typedNumber = cast(numbers(i), types(i));
                assert(number == typedNumber, ...
                    "somehow %d and %d are not considered to be the same", number, typedNumber);
                dimension = dimensions(i);
                realStream = dec2char(typedNumber, dimension);
                expectedStream = dec2char(number, dimension);
                testCase.verifyEqual(realStream, expectedStream, ...
                    sprintf("dec2char produces an error for value %d and dimension %d", number, dimension));
            end
        end

        function negativeNumbersFail(testCase)
            %% Make sure that negative numbers throw an exepeption
            for i = randi([-flintmax+1 -1], 1, 100)
                testCase.verifyError(@()dec2char(i, 1), 'MATLAB:validators:mustBeGreaterThanOrEqual');
            end
        end

        function largeNumbersFail(testCase)
            %% Make sure that numbers larger than the dimensions necessary will throw an exception
            for i =  randi([256 flintmax-1], 1, 100)
                maxlength = ceil(log2(i)/8);
                for j = randi([1 maxlength-1], 1, 10)
                    testCase.verifyError(@()dec2char(i, j), 'G4DT:dec2char:numchar');
                end
            end
        end
                
    end

end