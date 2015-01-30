function vis_headmodel_elements(cfg)
%   cfg.elements
%       cell array of head model elements to be plotted: 
%           'electrodes', 'volume', 'leadfield'
%       TODO Add dipole
%   cfg.stage
%       struct of short names for each pipeline stage
%
%   See also ftb.get_stage

for i=1:length(cfg.elements)
    switch cfg.elements{i}
        case 'scalp'
            hold on;
            
            % Load data
            cfgtmp = ftb.get_stage(cfg, 'headmodel');
            cfghm = ftb.load_config(cfgtmp.stage.full);
            vol = ftb.util.loadvar(cfghm.files.mri_headmodel);
            
            % Plot the scalp
            if isfield(vol, 'bnd')
                switch vol.type
                    case 'bemcp'
                        ft_plot_mesh(vol.bnd(3),...
                            'edgecolor','none',...
                            'facealpha',0.8,...
                            'facecolor',[0.6 0.6 0.8]);
                    case 'dipoli'
                        ft_plot_mesh(vol.bnd(1),...
                            'edgecolor','none',...
                            'facealpha',0.8,...
                            'facecolor',[0.6 0.6 0.8]);
                    case 'openmeeg'
                        idx = vol.skin_surface;
                        ft_plot_mesh(vol.bnd(idx),...
                            'edgecolor','none',...
                            'facealpha',0.8,...
                            'facecolor',[0.6 0.6 0.8]);
                    otherwise
                        error(['ftb:' mfilename],...
                            'Which one is the scalp?');
                end
            elseif isfield(vol, 'r')
                ft_plot_vol(vol,...
                    'facecolor', 'none',...
                    'faceindex', false,...
                    'vertexindex', false);
            end
            
        case 'brain'
            hold on;
            
            % Load data
            cfgtmp = ftb.get_stage(cfg, 'headmodel');
            cfghm = ftb.load_config(cfgtmp.stage.full);
            vol = ftb.util.loadvar(cfghm.files.mri_headmodel);
            
            % Plot the scalp
            if isfield(vol, 'bnd')
                switch vol.type
                    case 'bemcp'
                        ft_plot_mesh(vol.bnd(1),...
                            'edgecolor','none',...
                            'facealpha',0.8,...
                            'facecolor',[0.6 0.6 0.8]);
                    case 'dipoli'
                        ft_plot_mesh(vol.bnd(3),...
                            'edgecolor','none',...
                            'facealpha',0.8,...
                            'facecolor',[0.6 0.6 0.8]);
                    case 'openmeeg'
                        idx = vol.source;
                        ft_plot_mesh(vol.bnd(idx),...
                            'edgecolor','none',...
                            'facealpha',0.8,...
                            'facecolor',[0.6 0.6 0.8]);
                    otherwise
                        error(['ftb:' mfilename],...
                            'Which one is the brain?');
                end
            else
                error(['ftb:' mfilename],...
                    'Which one is the brain?');
            end
            
        case 'electrodes'
            hold on;
            
            % Load data
            cfgtmp = ftb.get_stage(cfg, 'electrodes');
            cfghm = ftb.load_config(cfgtmp.stage.full);
            elec = ftb.util.loadvar(cfghm.files.elec_aligned);
            
            % Plot electrodes
            ft_plot_sens(elec,...
                'style', 'sk',...
                'coil', true);
            %'coil', false,...
            %'label', 'label');
            
        case 'leadfield'
            hold on;
            
            % Load data
            cfgtmp = ftb.get_stage(cfg, 'leadfield');
            cfghm = ftb.load_config(cfgtmp.stage.full);
            leadfield = ftb.util.loadvar(cfghm.files.leadfield);
            
            % dipole is in cm
            % Convert leadfield to cm
%             leadfield = ft_convert_units(leadfield, 'cm');
            
            % Plot inside points
            plot3(...
                leadfield.pos(leadfield.inside,1),...
                leadfield.pos(leadfield.inside,2),...
                leadfield.pos(leadfield.inside,3), 'k.');
            
        case 'dipole'
            hold on;
            
            % Load data
            cfgtmp = ftb.get_stage(cfg, 'dipolesim');
            cfghm = ftb.load_config(cfgtmp.stage.full);
            
            signal_components = {'signal','interference'};
            
            for i=1:length(signal_components)
                component = signal_components{i};
                if ~isfield(cfghm, component)
                    % Skip if component not specified
                    continue;
                end
                
                params = cfghm.(component).ft_dipolesimulation;
                if isfield(params, 'dip')
                    dip = params.dip;
                    ft_plot_dipole(dip.pos, dip.mom,...
                        ...'diameter',5,...
                        ...'length', 10,...
                        'color', 'blue',...
                        'units', 'mm');
                end
            end
            
        otherwise
            error(['fb:' mfilename],...
                'unknown element %s', cfg.elements{i});
    end
end

end

