classdef AnalysisBeamformer < handle
    %AnalysisBeamformer Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(SetAccess = private)
        steps;      % array of AnalysisStep objects
        out_folder; % output folder
    end
    
    methods
        function obj = AnalysisBeamformer(out_folder)
            % parse inputs
            p = inputParser;
            addOptional(p,'out_folder','',@ischar);
            parse(p,out_folder);
            
            obj.steps = {};
            obj.out_folder = p.Results.out_folder;
        end
        
        function add(obj, new_step)
            % parse inputs
            p = inputParser;
            addRequired(p,'new_step',@(x) isa(x,'ftb.AnalysisStep'));
            parse(p,new_step);
            
            % add step
            if isempty(obj.steps)
                obj.steps{1} = p.Results.new_step;
            else
                idx = length(obj.steps) + 1;
                obj.steps{idx} = p.Results.new_step;
                % link previous step
                obj.steps{idx}.add_prev(obj.steps{idx-1});
            end
        end
        
        function obj = init(obj)
            
            if isempty(obj.steps)
                warning(['ftb:' mfilename],...
                    'no steps to init');
            end
            
            % init each step
            for i=1:length(obj.steps)
                obj.steps{i}.init(obj.out_folder);
            end
        end
        
        function obj = process(obj)
            
            if isempty(obj.steps)
                warning(['ftb:' mfilename],...
                    'no steps to process');
            end
            
            % process each step
            for i=1:length(obj.steps)
                obj.steps.process();
            end
        end
        
    end
    
end

