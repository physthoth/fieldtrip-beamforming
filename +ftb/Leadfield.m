classdef Leadfield < ftb.AnalysisStep
    %Leadfield Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(SetAccess = private)
        config;
        leadfield;
    end
    
    methods
        function obj = Leadfield(params,name)
            %   params (struct or string)
            %       struct or file name
            %
            %   name (string)
            %       object name
            %   prev (Object)
            %       previous analysis step
            
            % parse inputs
            p = inputParser;
            p.StructExpand = false;
            addRequired(p,'params');
            addRequired(p,'name',@ischar);
            parse(p,params,name);
            
            % set vars
            obj@ftb.AnalysisStep('L');
            obj.name = p.Results.name;
            
            if isstruct(p.Results.params)
                % Copy config
                obj.config = p.Results.params;
            else
                % Load config from file
                din = load(p.Results.params);
                obj.config = din.cfg;
            end
            
            obj.leadfield = '';
        end
        
        function obj = add_prev(obj,prev)
            
            % parse inputs
            p = inputParser;
            addRequired(p,'prev',@(x)isa(x,'ftb.Electrodes'));
            parse(p,prev);
            
            % set the previous step, aka Electrodes
            obj.prev = p.Results.prev;
        end
        
        function obj = init(obj,analysis_folder)
            %INIT initializes the output files
            %   INIT(analysis_folder)
            %
            %   Input
            %   -----
            %   analysis_folder (string)
            %       root folder for the analysis output
            
            % init output folder and files
            properties = {'leadfield'};
            for i=1:length(properties)
                obj.(properties{i}) = obj.init_output(analysis_folder,...
                    'properties',properties{i});
            end
            
            obj.init_called = true;
        end
        
        function obj = process(obj)
            if ~obj.init_called
                error(['ftb:' mfilename],...
                    'not initialized');
            end
            
            % check deps restart
            force_deps = obj.check_deps();
            
            % get analysis step objects
            elecObj = obj.prev;
            hmObj = elecObj.prev;
            
            if isfield(obj.config, 'ft_prepare_sourcemodel')
                cfgin = obj.config.ft_prepare_sourcemodel;
                cfgin.vol = ftb.util.loadvar(hmObj.mri_headmodel);
                %     cfgin.hdmfile = cfghm.files.mri_headmodel;
                % Set up the source model
                grid = ft_prepare_sourcemodel(cfgin);
                % Add to leadfield config
                obj.config.ft_prepare_leadfield.grid = grid;
                % NOTE
                % Doens't work, volume surface defaults to skin, no option for
                % ft_prepare_sourcemodel to change it
            end
            
            cfgin = obj.config.ft_prepare_leadfield;
            cfgin.elecfile = elecObj.elec_aligned;
            cfgin.hdmfile = hmObj.mri_headmodel;
            if obj.check_file(obj.leadfield)
                
                if ~isfield(cfgin, 'channel')
                    % Remove fiducial channels
                    cfgin.channel = elecObj.remove_fiducials();
                end
                
                % Compute leadfield
                leadfield = ft_prepare_leadfield(cfgin);
                save(obj.leadfield, 'leadfield');
            else
                fprintf('%s: skipping ft_prepare_leadfield, already exists\n',...
                    strrep(class(obj),'ftb.',''));
            end
        end
        
        function plot(obj, elements)
            %   elements
            %       cell array of head model elements to be plotted:
            %       'leadfield'
            %       can also include elements from previous stages
            %       'electrodes'
            %       'electrodes-aligned'
            %       'electrodes-labels'
            %       'scalp'
            %       'skull'
            %       'brain'
            %       'fiducials'
            
            unit = 'mm';
            
            % check if we should plot labels
            plot_labels = any(cellfun(@(x) isequal(x,'electrodes-labels'),elements));
            
            for i=1:length(elements)
                switch elements{i}
                    
                    case 'electrodes-projected'
                        hold on;
                        % Load data
                        lf = ftb.util.loadvar(obj.leadfield);
                        
                        if isfield(lf.cfg,'sensphil')
                            % Convert to mm
                            sens = ft_convert_units(lf.cfg.sensphil, unit);
                            
                            % Plot electrodes
                            if plot_labels
                                ft_plot_sens(sens,'style','ok','label','label');
                            else
                                ft_plot_sens(sens,'style','ok');
                            end
                        else
                            warning('no field sensphil');
                        end
                    
                    case 'leadfield'
                        hold on;
                        
                        % Load data
                        lf = ftb.util.loadvar(obj.leadfield);
                        
                        % Convert to mm
                        lf = ft_convert_units(lf, unit);
                        
                        % Plot inside points
                        plot3(...
                            lf.pos(lf.inside,1),...
                            lf.pos(lf.inside,2),...
                            lf.pos(lf.inside,3), 'k.');
                end
            end
            
            % plot previous steps
            if ~isempty(obj.prev)
                obj.prev.plot(elements);
            end
        end
    
    end
end

