classdef G4_trial_model
    
 %end

 %classdef trial_class
 
    properties
        
        trial_mode;
        pattern_name;
        position_func;
        ao1;
        ao2;
        ao3;
        ao4;
        frame_index;
        frame_rate;
        gain;
        offset;
        duration;
        is_checked;
        trial_array;
    end

    
    %set values given to a struct of protected variables to actually use in manipulation

    methods
        
        function self = G4_trial_model()
        
            self.trial_mode = 1 ;
            self.pattern_name= '' ;
            self.position_func = '' ;
            self.ao1 = '' ;
            self.ao2 = '' ;
            self.ao3 = '' ;
            self.ao4 = '' ;
            self.frame_index = [] ;
            self.frame_rate = [] ;
            self.gain = [] ;
            self.offset = [] ;
            self.duration = 5 ;
            self.is_checked = false ;
            self.trial_array = {self.trial_mode, self.pattern_name, self.position_func, self.ao1, ...
                self.ao2, self.ao3, self.ao4, self.frame_index, self.frame_rate, self.gain, self.offset, ...
                self.duration, self.is_checked};
 
            
        end

         function [pre_trial] = update_pre_trial(pre_trial_table, event)
            pre_trial = get(pre_trial_table, 'data');

         end
        
         function [inter_trial] = update_inter_trial(inter_trial_table, event)
            inter_trial = get(inter_trial_table, 'data');

         end
         
         
         function [block_trial] = update_block_trial(block_trial_table, event)
            block_trial = get(block_trial_table, 'data');
 
         end
         
         function [post_trial] = update_post_trial(post_trial_table, event)
            post_trial = get(post_trial_table, 'data');

         end
         
         function [block_trial] = add_trial(add_trial_button, event)
            
            block_table = findobj('Tag','block');
            oldData = get(block_table, 'data');
            checkbox_column_data = horzcat(oldData(:, end));
            checked_list = find(cell2mat(checkbox_column_data));
            checked_count = length(checked_list);
                       
            if checked_count == 0
                newRow = oldData(end,:);
                block_trial = [oldData;newRow];
                set(block_table,'data',block_trial);
            elseif checked_count == 1
                newRow = oldData(checked_list(1),1:end-1);
                newRow{:,end+1} = false;
                block_trial = [oldData;newRow];
                set(block_table,'data',block_trial);
            else
                disp("You can only select one row for this functionality.");
            end
            
         
         end
         
         
        
        function[] = check_mode(trial)
            %for each of these, set up an object (trial_mode_1, trial_mode_2, etc 
            %to feed into following functions

        %   !!!!!!!!!!!Alternatively, could make a class for each mode. Default is an object of 
            %class 1, but upon a change create an object of class whatever. Might be cleaner.

            if trial.trial_mode_ == 1
                %position function name should be editable, gain and offset hidden
            elseif trial.trial_mode_ == 2
                %frame rate is constant (editable), gain offset hidden
            elseif trial.trial_mode_ == 3
                %frame index is constant (editable) gain offset hidden
            elseif trial.trial_mode_ == 4
                %closed-loop sets frame rate (gate, offset)
            elseif trial.trial_mode_ == 5
                %closed-loop rate + offset position function (pos func name, gain, offset)
            elseif trial.trial_mode_ == 6
                %closed-loop rate X + pos func Y (position func name, gain, offset)
            elseif trial.trial_mode_ == 7
                %closed-loop sets frame index (no unique parameters)
            else
                disp('Please enter a valid mode.');

            end
        end

        function [trial_block] = form_trial_block()
            
            check_mode(trial);

            for i = 1:number_of_trials
                trial_block(i) = trial;
                
            end
        end



        
    end
end




