function cfg = infer_nets(cfg)
% Infer the networks using different approaches

global dynanets_default;

for i = 1 : length(cfg.data.patients)
    pat = cfg.data.patients{i};
    for j = 1 : length(cfg.data.seizures{i})
        sz = cfg.data.seizures{i}{j};
        
        fprintf(['3-infer using ' cfg.infer.method ': ' pat '_' sz '\n'])
        fprintf(['... read in the preprocessed data, ' pat '_' sz '/' prepdata_filename(cfg) '.mat \n'])
        
        data_file = [dynanets_default.outdatapath '/' pat '_' sz '/' nets_filename(cfg) '.mat'];
        if cfg.infer.run || ~exist(data_file, 'file')
            s = load([dynanets_default.outdatapath '/' pat '_' sz '/' prepdata_filename(cfg) '.mat']);
                            
            if strcmp(cfg.infer.method ,'corr') || strcmp(cfg.infer.method, 'corr_0_lag') == 1                  
                %----------------------------------------------------------
                % Use correlation method
                %----------------------------------------------------------
                
                % Assume variables:  d = data, t = time axis
                d = s.ECoG.Data;
                t = s.ECoG.Time;
                          
                % Determine if using global correlation variance scale, and if so, compute it.
                if ismember(cfg.infer.scale, {'global', 'win'})
                    fprintf('... computing empirical scale of correlation from all data. \n')
                    scale = compute_correlation_scale(d,t,cfg);
                else
                    scale = 1;
                end
                
                % Divide the data into windows, with overlap.
                i_total = 1+floor((t(end)-t(1)-cfg.infer.windowsize) / cfg.infer.windowstep);       % # intervals.
                
                % Output variables.
                t_net   = zeros(i_total,1);
                C_net   = NaN(size(d,2), size(d,2), i_total);
                mx_net  = NaN(size(d,2), size(d,2), i_total);
                lag_net = NaN(size(d,2), size(d,2), i_total);
                rho_net = NaN(size(d,2), size(d,2), i_total);
                
                parfor k=1:i_total                          %For each window,
                    
%                     nchar = fprintf(num2str(k))
                    
                    t_start = t(1) + (k-1) * cfg.infer.windowstep; %#ok<PFBNS> %... get window start time [s],
                    t_stop  = t_start + cfg.infer.windowsize;                  %... get window stop time [s],
                    indices = t >= t_start & t < t_stop;                       %... find indices for window in t,
                                        
                    % Build the functional networks.
                    if cfg.infer.scale == "global"
                        [C,mx,lag,rho] = infer_network_correlation_analytic(d(indices,:), 'scale', scale); %#ok<PFBNS>
                    elseif cfg.infer.scale == "win"
                        [C,mx,lag,rho] = infer_network_correlation_analytic(d(indices,:), 'scale', scale(k)); %#ok<PFBNS>
                    else
                        [C,mx,lag,rho] = infer_network_correlation_analytic(d(indices,:)); %#ok<PFBNS>
                    end
                    
                    if strcmp(cfg.infer.method, 'corr_0_lag') == 1 
                        C(lag == 0) = 0;
                    end
                    
                    % Save the results.
                    t_net(k)       = t_start;                %Save window start time [s].
                    C_net(:,:,k)   = C;                      %Save the binary functional network.
                    mx_net(:,:,k)  = mx;                     %Save the max(abs(cc)) values.
                    lag_net(:,:,k) = lag;                    %Save the lag @ max(abs(cc)).
                    rho_net(:,:,k) = rho;                    %Save the p-value of max(abs(cc)).
                    
                    %N = length(C);
                    %fprintf(['... inferring nets: ' num2str(i_total-k) ' ' num2str(t_start,3) ' ' num2str(t_stop,3) ...
                    %         ' d=' num2str(sum(C(:))/(N*(N-1)),3) '\n'])
%                     fprintf(repmat('\b', 1, nchar));
                end
                
                nets.C   = C_net;
                nets.mx  = mx_net;
                nets.lag = lag_net;
                nets.rho = rho_net;
                nets.t   = t_net;
                
            end
            
            % Save the electrode position in nets.
            nets.xy = s.ECoG.Position;
            
            if cfg.infer.smooth
                nets.C = network_temporal_vote(nets.C, 3);
            end
            
            % Save results in a different file
            save(data_file, 'nets', 'cfg');
            clear nets s;
        else
            fprintf(['... nets file exists and not re-netted: ' data_file '\n'])
        end
    end
end

end
