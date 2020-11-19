# Dynanets
The purpose of this code is to track communities in dynamic networks. 

## Simplified analysis
<span style="color:red"> ... for a simplified example of the method, check out [the README in this branch](https://github.com/Eden-Kramer-Lab/dppm/tree/simplified).</span>

## Dependices
Download the following software packages, required to track dynamic communities and analyze the networks.

- Download the [The Brain Connectivity Toolbox](https://sites.google.com/site/bctnet/)
- Download this "generalized Louvain" MATLAB code for community detection [GenLouvain2.1](http://netwiki.amath.unc.edu/GenLouvain/GenLouvain)
- Download the [dynamic plex percolation method](https://github.com/nathanntg/dynamic-plex-propagation)
- Download the [export_fig, a MATLAB toolbox for exporting publication quality figures](https://github.com/altmany/export_fig)
- Download the [chronux toolbox](http://chronux.org/)

## Initial MATLAB setup
Rename the file `dynanets_defaults_local_example.m` --> `dynanets_defaults_local.m`

- Line 7, replace `'My-MAC'` with the name of the computer that's running the code. To find this name, type `system('hostname')` at the MATLAB command line.
- Line 8, replace  `'/Users/me/analysis/toolboxes/dpp/'` with a string to the directory where DPPM was installed.
- Line 9, replace `'/Users/me/analysis/toolboxes/BCT'` with a string to the directory where the Brain Connectivity Toolbox was installed.
- Line 10, replace `'/Users/me/analysis/toolboxes/GenLouvain-2.1'` with a string to the directory where the generalized Louvain code was installed.
- Line 11, replace `'/Users/me/analysis/toolboxes/export_fig'` with a string to the directory where export-fig was installed.
- Line 12, replace `'/Volumes/Data/Output_Data/'` with a string to an output write directory for data.
- Line 13, replace `'/Volumes/Data/Output_Data/'` with a string to an output write directory for figures.

You can enter information for a second system in Lines 13-18, if useful.

## Code organization
The central file of the pipeline is `main_dynanets.m`, which calls all other routines.
The code is organized into subfolders according to the tasks being done: 
- `1-build`: start a simulation or load existing data
- `2-preprocess`: apply simple preprocessing, like filtering
- `3-infer`: runs the network inference procedure (currently based on [maximum cross-correlation](http://math.bu.edu/people/mak/papers/Kramer_et_al_PRE_2009.pdf))
- `4-track`: runs the different community tracking algorithms implemented (DPPM, CPM, MMM)
- `5-analyze`: runs basic analysis of the results, and outputs visualizations.
- `simulation`: contains the code to run the simulations analyzed in the paper.

This pipeline configurations is based on the use of a structure called `cfg` where all the settings are stored (inspired by the approach implemented in [Fieldtrip toolbox](http://www.fieldtriptoolbox.org/)). Here are the options of the configuration:

    % Build simulation data
    cfg.data.run = true;
    cfg.data.patients = {'P1', 'P2'}; % list of the patients to be analyzed (used to search in folders)
    cfg.data.seizures = {{'S1', 'S2'}, {'S1', 'S2', 'S3'}}; % list of seizures for each patients
    cfg.data.build_fun = @my_build_fun; % function called to build the data segment to be analyzed (e.g., will create P1_S1.mat file)
    cfg.data.padding = [0 0]; % how much data to include pre- and post-seizure

    % Preprocessing settings
    cfg.preprocess.run = true; % runs the preprocessing step
    cfg.preprocess.ref = ''; % Choose the reference for re-referencing: '' (do nothing), 'cavg' (common average), 'bipolar' (only for simulations)
    cfg.preprocess.filt = 'firls'; % choice for the filter function
    cfg.preprocess.band = [4 50]; % Frequency band to keep

    % Inference settings
    cfg.infer.run = true; % runs the inference step
    cfg.infer.method = 'corr_0_lag'; % Choose the inference method: 'corr', 'corr_0_lag'
    cfg.infer.windowsize = 1; % Window size for net inference (s).
    cfg.infer.windowstep = 0.5;  % Window overlap (s)
    cfg.infer.smooth = false; % Use vote to smooth networks in time
    cfg.infer.scale  = true; % Scale variance of correlation using all time.
    
    % Network tracking through time
    cfg.track.run = true; % runs the tracking step
    cfg.track.method = { % list of methods to apply with their parameters (can add as many as wanted)
        struct('name', 'dpp', 'k', 2, 'm', 4);
        struct('name', 'mmm', 'gamma', 1, 'omega', 0.1);
        struct('name', 'cpm', 'min_clique', 4);
        };

    % Settings for figures
    cfg.fig.run = true; % runs the analysis step
    cfg.fig.type = '-djpeg'; % Choose the output format: '-djpeg', '-depsc', '-dpdf'
    cfg.fig.plotpadding = [0 0]; % Used in xlim in some figs, e.g. [0 0], PADDING
    cfg.fig.mmmthresh = 4; % used to clean the MMM plots (minimum com size, 0 = all)
    cfg.fig.analyze_seizures = true; % runs the seizure by seizure analysis step
    cfg.fig.custom_node_sort = @my_order; % define a different order for the nodes in the plots [optional]
    cfg.fig.custom_stats = @my_additional_stats; % run another function for additional analyses [optional]
    cfg.fig.analyze_population_fun = @population_results; % analyze patient by patient results [optional]
    cfg.fig.usetitle = true; % choose to use titles in plots
    cfg.fig.fontsize = 12; % font size used in plots
    
To run and analyze multiple scenarios, each multiple times, see the example cfg description in the simulation folder, `dynanets_sim_all.m`.

To run and analyze a single simulation scenario a single time, see the example cfg description in the simulation folder,
`dynanets_sim_individual.m`

## Simulations
The `simulation` folder contains the code to run the simulations from the paper. More specifically:
- `simulation\7-node-example` contains the code to generate Fig 1C
- `simulation\9-node-example` contains the code to generate Fig 1D
- all the other files are used to generate the data used in Fig 2-4. `dynanets_sim_all.m` is the core file that setups the parameters of the simulations and run the pipeline.

## Example simulation and network tracking analysis
To run an example simulation and analysis, first define `dynanets_defaults_local.m` as described above. Then, from the root `dppm` folder, run the following commands at the MATLAB prompt:

```
>> dynanets_defaults_local
>> run simulation/dynanets_sim_individual
```
