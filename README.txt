# Dynanets (simplified)
The purpose of this code is to track communities in dynamic networks. 

Here, we assume:
- You have in hand a time-indexed binary network `C[nodes,nodes,time]` with time axis `t[time]`.
- You would like to apply DPPM to this network.
- You would like to visualize the results.

## Dependicies
- Download the [DPPM Toolbox] (this repository)
- Download the [The Brain Connectivity Toolbox](https://sites.google.com/site/bctnet/)
- Download the [Dynamic plex percolation method](https://github.com/nathanntg/dynamic-plex-propagation)

## Run it

See the example analysis in `simplified_code_example.m`.