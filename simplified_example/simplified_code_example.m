% Run dppm with default settings given a time-indexed binary network.
%
% Given C   = [nodes, nodes, time] = time-indexed binary network.
%       k,m = 2,4                  = for a 2-plex of size 4. 

clear

%---- Load toolboxes ------------------------------------------------------

% REPLACE WITH YOUR PATH.
localpath       = '';

BCT_toolbox_path = [localpath '/BCT/'];
DPP_toolbox_path = [localpath '/dynamic-plex-propagation/'];
DPPM_toolbox_path= [localpath '/dppm/'];

% Addpath to dpp                            (https://github.com/nathanntg/dynamic-plex-propagation)
addpath(genpath(DPP_toolbox_path));
% Addpath to Brain Connectivity Toolbox     (https://sites.google.com/site/bctnet/)
addpath(genpath(BCT_toolbox_path));
% Addpath to compute community statistics   (https://github.com/Eden-Kramer-Lab/dppm)
addpath(genpath([DPPM_toolbox_path '5-analyze/']))

%---- Load & format example data ------------------------------------------

% REPLACE WITH YOUR DATA.
load('C_example.mat')                       % Load data.
nets = [];  nets.C = C;  nets.t = t;        % Format it for DPPM.

%---- Run DPPM ------------------------------------------------------------
k = 2; m = 4;                               % Set default DPPM parameters
[track.vertices, track.communities] = dpp(C, k,m);

%---- Compute community statistics ----------------------------------------
stats = community_stats(track);

%---- Plot the results ----------------------------------------------------

% Density plot
subplot(3,1,1)
plot_density(nets);

% Plot the number of coms through time
subplot(3,1,2)
plot(t, stats.nb_com);
ylim([0, max(stats.nb_com)+1]);
xlabel('Time (s)')
ylabel('Number of Communities')

% Community participation over time.
subplot(3,1,3)
cc_nowhite = colorcube;
cc_nowhite = cc_nowhite(1:end-1,:);
participation = stats.participation;
colormap(cc_nowhite)
imagescwithpcolor(t, (1:size(C,1)), participation')
xlabel('Time (s)')
ylabel('Node')