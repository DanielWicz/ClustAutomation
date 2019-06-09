# GMXCLUST automation script
This script was used during structure preparation during writing my master in computational chemistry
regarding G-quadruplex binding anti-cancer drugs. 
## Getting started
### Prerequisites
* Bash version 4.2 (It should work also on older versions)
* GROMACS 2016 or 2018
### Running the program
To run the program you have to prepare a directory with directories containing simulation results,
for example, directory `4DA3` with directories `1a 1b 1c`. These directories should
contain force field files, analyzed trajectory, and an index file named index.ndx.

After the directories are like above, the directories should be indicated in the 
the input file, an example of such input file is shown on the repository (see `INPUT.inp` for more).
Then the program is called `./RUNSCRIPT.sh INPUT.inp` (remember to give proper permissions with chmod).

The output is a structure from the most populated cluster centroid. Which can be further used as a
representative average structure in other calculations (like quantum chemistry, which was in my case).

## Input arguments for input file
There is several arguments which are explained below:

`GROMACDIR [str]` - Directory where the GROMACS executable resides.
For example it could be `/usr/local/gromacs/intel-16.0.3.210/2018.4/bin/`.

`GROMOD [str]` - Command for loading the groamcs enviroment variables from a script.
For example `module load gromacs/2018.4-intel16.0.3.210`.

`STRUCTLIST [array]` - List of the subdirectories with the GROMACS simulation data.
For example, `1a 1b 1c`. These directories should contain the trajectory file, index.ndx
, the directory with force field files, topology file and an mdp file for the used trajectory.

`DIRLIST [array]` - Directory with directories, which contain simulation files (see above).
Every such directory should contain the directories listed in the `STRUCTLIST`. 

`INPCOMPLEX [string]` - Name used in the index.ndx for the protein complex.

`INPSOLV [string]` - Name used in the index.ndx for the solvent and ions.

`OUTCOMPNAME [string]` - Name used for the complex in the output.

`OUTRECEPTORNAME [string]` - Name used for the receptor in the output.

`OUTLIGNAME [string]` - Name used for the ligand in the output.

`ALLLOGNAME [string]` - Name used for the output log for all the calculations.

`METHOD [string]` - Clustering method, to this point only GROMOS was tested, you can try
to use different methods, which are implemented in the GROMACS software.

`CUTOFF [float]` - Cut-off range for the clustering algorithm, more in the GROMACS manual.

`OUTPUTRECEPTORNAME [string]` - Name used for the receptor in the output.

`FFFILES [string]` - Directory where the force field files (these with the .itp extension) reside.

`GMXSTART [string]` - GMX program which is used to the run GROMACS, for example the `gmx_mpi` or just `gmx`.

`OUTPUTDIR [string]` - Name for the output directory in every directory from `STRUCTLIST`.
For example, every `1a 1b 1c` will contain such result directory, in this directory logs for the simulation
and the top cluster centroid will reside.

`CLUSTLOG [string]` - Name for the log in every directory from `STRUCTLIST`.

`XTCTOCLUST [string]` - Name for the trajectory file used in the clustering.
The same name will be used for the `tpr, mdp` files, so be careful here.

`TOPOLFILE [string]` - Name for the topology file (the one with .top extension).

`CLUSTERTEMP [string]` - Name for the clustering temporary directory in every of the `STRUCTLIST` directories.



