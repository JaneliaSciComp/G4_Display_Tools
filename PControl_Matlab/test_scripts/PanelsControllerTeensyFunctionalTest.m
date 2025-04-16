classdef PanelsControllerTeensyFunctionalTest < matlab.unittest.TestCase
    
    properties
        panelsController
    end

    methods(TestMethodSetup)
        function startNewHost(testCase)
            testCase.panelsController = PanelsController('192.168.10.62');
            testCase.panelsController.open(false);
        end
     end
    
    methods(TestMethodTeardown)
        function stopHost(testCase)
            testCase.panelsController.close(true);
        end
    end
    
    methods(Test, TestTags = {'MainHost', 'PanelsController'})
        function stopDisplay(testCase)
            for i = 1:100
                testCase.verifyTrue(testCase.panelsController.stopDisplay(), ...
                    sprintf("PanelsController.stopDisplay didn't successfully complete for iteration %d.", i));
            end
        end
        
        function sendAllOn(testCase)
            for i = 1:100
                testCase.verifyTrue(testCase.panelsController.allOn(), ...
                    sprintf("PanelsController.allOn wasn't successfully completed in iteration %d.", i));
            end
        end
        
        function sendAllOff(testCase)
            for i = 1:100
                testCase.verifyTrue(testCase.panelsController.allOff(), ...
                    sprintf("PanelController.allOff wasn't successfully completed in iteration %d", i));
            end
        end
        
        function sendAllOnAndOff(testCase)
            for i = 1:15
                testCase.verifyTrue(testCase.panelsController.allOn(), ...
                    sprintf("PanelsController.allOn wasn't successfully completed in iteration %d.", i));
                testCase.verifyTrue(testCase.panelsController.allOff(), ...
                    sprintf("PanelController.allOff wasn't successfully completed in iteration %d", i));
                testCase.verifyTrue(testCase.panelsController.allOn(), ...
                    sprintf("PanelsController.allOn wasn't successfully completed in iteration %d.", i));
                testCase.verifyTrue(testCase.panelsController.allOff(), ...
                    sprintf("PanelController.allOff wasn't successfully completed in iteration %d", i));
            end
        end
        
        function sendAllOnAndOffWithDelay(testCase)
            delayOnOff = 0.004;
            delayOffOn = 0;
            boff = tic;
            for i = 1:15
                while toc(boff) < delayOffOn
                end
                bon = tic;
                testCase.verifyTrue(testCase.panelsController.allOn(), ...
                    sprintf("PanelsController.allOn wasn't successfully completed in iteration %d, round 1.", i));
                while toc(bon) < delayOnOff
                end
                boff = tic;
                testCase.verifyTrue(testCase.panelsController.allOff(), ...
                    sprintf("PanelController.allOff wasn't successfully completed in iteration %d, round 1.", i));
                while toc(boff) < delayOffOn % Copy&Paste earlier code to reduce the delay introduced by for-loop.
                end
                bon = tic;
                testCase.verifyTrue(testCase.panelsController.allOn(), ...
                    sprintf("PanelsController.allOn wasn't successfully completed in iteration %d, round 2.", i));
                while toc(bon) < delayOnOff
                end
                boff = tic;
                testCase.verifyTrue(testCase.panelsController.allOff(), ...
                    sprintf("PanelController.allOff wasn't successfully completed in iteration %d, round 2", i));
            end
        end
        
        function testReset(testCase)
            testCase.verifyTrue(testCase.panelsController.sendDisplayReset());
        end
                
        function testLoggedResetCounter(testCase)
            %% testLoggedResetCounter Send alternating reset and sync logs
            %
            %  see also testResetCounter, testMultipleResetCounter, testSyncLog
            testCase.panelsController.setRootDirectory("C:\matlabroot\G4");
            testCase.panelsController.startLog();
            testCase.panelsController.setControlMode(1);
            for pse = randi([1 25], 1, 10)                
                testCase.panelsController.resetCounter();
                testCase.panelsController.sendSyncLog(pse, int64(posixtime(datetime('now'))*1000*1000));
                pause(pse/10);
            end
            testCase.panelsController.stopLog();
        end
        
        function paintNumbers(testCase)
            nmb = zeros(16*2, 16*12);
            % one
            nmb(2:15, 8) = 15;
            nmb(2, 6:8) = 15;
            nmb(15, 6:10) = 15;
            % two
            nmb(2, 16 + (5:11)) = 15;
            nmb((2:6), 11 + 16) = 15;
            nmb(7, (5:11) + 16) = 15;
            nmb(7:14, 5 + 16) = 15;
            nmb(14, (5:11) + 16) = 15;
            frm = make_framevector_gs16(nmb, 1);
            testCase.panelsController.streamFrame(0, 0, frm);
            disp(frm);
        end

        function streamFromFile(testCase)

            repetition = 10;

            fh = fopen('C:\Users\labadmin\src\G4_Display_Tools\PControl_Matlab\test_scripts\Patterns_2x12\pat0007.pat');
            data = fread(fh);
            fclose(fh);
            data = transpose(data);
            
            framecount = data(1) + bitshift(data(2), 8);
            assert(data(5) == 16, "Can only load grayscale images right now");
            assert(data(6) == 2, "Only tested for G4.1 with 2x12");
            assert(data(7) == 12, "Only tested for G4.1 with 2x12");

            
            tic;
            for allidx = 1:repetition
                for idx = 1:framecount
                % framecmd = make_framevector_gs16(aaa.pattern.Pats(:,:,idx));
                start_byte = 8 + (idx-1) * 3176;
                end_byte = 7 + idx * 3176;
                testCase.panelsController.streamFrame(0, 0, data(start_byte:end_byte));
                end
            end
            elapsed = toc;
            sprintf("FPS: %.2f for %d frames and %d repetitions in %.2f seconds", framecount*repetition/elapsed, framecount, repetition, elapsed)
            
        end
    
        function streamPlaceLearning(testCase)

            % led_circ is a helper variable that defines the circumfence of the arena in LED count.
            % In this case the arena has 192 LEDs in each row (12 panels, each with 16 LEDs)
            % I did not define the number of LEDS per column, this would be 32 (2 panels, each with 16 LEDs)
            led_circ = 192;
            % flips is the number of "trials" (how ofthen the location of the patterns switch)
            flips = 50;

           
            % bars is a 2-dimensional array. It is built like this:
            % - array with dimension 32×16 and filled with 1 (`ones(32,led_circ/12)`, https://www.mathworks.com/help/matlab/ref/ones.html)
            % - array with dimension 32×16 and filled with 0 (`zeros(32,led_circ/12)`, https://www.mathworks.com/help/matlab/ref/zeros.html)
            % - those two array are concatenated in the first dimension, this means the result should have the dimension 32×32 (`[ A , B]`, https://www.mathworks.com/help/matlab/math/creating-and-concatenating-matrices.html#OverviewCreatingAndConcatenatingExample-3)
            % - the array gets repeated once in the first and twice in the second dimension (`repmat([], 1, 2)`, https://www.mathworks.com/help/matlab/ref/repmat.html)
            % Consequently, bars holds 32 rows and 64 columns. The columns 1…16 contain all "1", the columns 17..32 all "0", columns 33…48 all "1", the columns 49…64 all "0"
            bars=repmat([ones(32,led_circ/12),zeros(32,led_circ/12)],1,2);
            % stripes is a 2-dimensional array. It is built like this:
            % - an array with dimensions 8×64 and filled with 1  (`ones(8,led_circ/3)`)
            % - an array with oimensions 8×64 and filled with 0  (`zeros(8,led_circ/3)`)
            % - those two arrays are concatenated in rows below each other (not the `;` instead of the `,` for `bars`)
            % - The array is repeated twice in the first and once in the second dimension.
            % The result has a dimension of 32 rows and 64 columns. The first 8 rows are completely filled with "1"…
            stripes=repmat([ones(8,led_circ/3);zeros(8,led_circ/3)],2,1);
            % diagonal is a 2-dimensional array. At first it takes the first row from `bars`
            diagonal=circshift(bars(1,:),[0,1]);
            % Then the code iterates through the numbers 1…31, thakes the first row of `diagonal` (same as first row of `bars`), shifts it by the current counter to the right and adds it as the current counter row to `diagonal`
            % The result has the dimension of 32 rows and 64 columns, where each line is circle-shifted by 1. So row 1 has a 1 in column 1…16, row 2 in column 2…17 etc…
            for f=1:31
                diagonal=[diagonal;circshift(diagonal(1,:),[0,f])];
            end
            % append these three patterns to an array of the dimensions with 32 rows and 192 columns
            SBDpat = circshift([bars,stripes,diagonal],[0,12]);
            orient = randi([0, 4], 1, flips);
            for idx = 1:flips
                SBDfrm = make_framevector_gs16(circshift(SBDpat*15, [0 orient(idx)*48]), 0);
                testCase.panelsController.streamFrame(0, 0, SBDfrm);
                pause(1);
            end
        end


    end
     
end
