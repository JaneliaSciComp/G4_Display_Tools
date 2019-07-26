classdef G4_conductor_model 
    
    properties
        
        fly_name_;
        fly_genotype_;
        experimenter_;
        experiment_type_;
        do_plotting_;
        do_processing_;
        plotting_file_;
        processing_file_;
        run_protocol_file_;
        
    end
    
    properties (Dependent)
        
        fly_name;
        fly_genotype;
        experimenter;
        experiment_type;
        do_plotting;
        do_processing;
        plotting_file;
        processing_file;
        run_protocol_file;
        
    end
    
    
    methods
        
%CONSTRUCTOR--------------------------------------------------------------

        function self = G4_conductor_model()
            
            self.fly_name = '';
            self.fly_genotype = '';
            self.experimenter = getenv('USERNAME');
            self.experiment_type = 1;
            self.do_plotting = 1;
            self.do_processing = 1;
            self.plotting_file = 'default plotting path';
            self.processing_file = 'default processing path';
            self.run_protocol_file = 'default run file path';
            
            
        end
        
        
        
        
%GETTERS------------------------------------------------------------------
        
        function value = get.fly_name(self)
            value = self.fly_name_;
        end
        
        function value = get.fly_genotype(self)
            value = self.fly_genotype_;
        end
        
        function value = get.experimenter(self)
            value = self.experimenter_;
        end
        
        function value = get.experiment_type(self)
            value = self.experiment_type_;
        end
        
        function value = get.do_plotting(self)
            value = self.do_plotting_;
        end
        
        function value = get.do_processing(self)
            value = self.do_processing_;
        end
        
        function value = get.plotting_file(self)
            value = self.plotting_file_;
        end
        
        function value = get.processing_file(self)
            value = self.processing_file_;
        end
        
        function value = get.run_protocol_file(self)
            value = self.run_protocol_file_;
        end


%SETTERS------------------------------------------------------------------

        function self = set.fly_name(self, value)
            self.fly_name_ = value;
        end
        
        function self = set.fly_genotype(self, value)
            self.fly_genotype_ = value;
        end
        
        function self = set.experimenter(self, value)
            self.experimenter_ = value;
        end
        
        function self = set.experiment_type(self, value)
            self.experiment_type_ = value;
        end
        
        function self = set.do_plotting(self, value)
            self.do_plotting_ = value;
        end
        
        function self = set.do_processing(self, value)
            self.do_processing_ = value;
        end
        
        function self = set.plotting_file(self, value)
            self.plotting_file_ = value;
        end
        
        function self = set.processing_file(self, value)
            self.processing_file_ = value;
        end
        
        function self = set.run_protocol_file(self, value)
            self.run_protocol_file_ = value;
        end
        
    end
    
    
end