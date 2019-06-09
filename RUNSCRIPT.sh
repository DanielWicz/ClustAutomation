#!/bin/bash
# Constants
INPUTDAT=${1}
# Path to gromac's bin folder
GROMACSDIR=`sed -En 's,GROMACDIR=\s*([a-zA-Z0-9/\\s]+),\1,p' ${INPUTDAT}`
GROMACSMODULLE=`sed -En 's,GROMOD=\s*([a-zA-Z0-9/\./\ /\-]+),\1,p' ${INPUTDAT}`
# List of subdirectories to check
declare -a sublist=(`sed -En 's,STRUCTLIST=\s*([a-zA-Z0-9/\]+),\1,p' ${INPUTDAT}`)
# List of directiories to check
declare -a dirlist=(`sed -En 's,DIRLIST=\s*([a-zA-Z0-9/\]+),\1,p' ${INPUTDAT}`)
# Input for complex name in the oryginal trajectory
recname=`sed -En 's,INPCOMPLEX=\s*([a-zA-Z0-9/\]+),\1,p' ${INPUTDAT}`
# Input for solvent name in the oryginal trajectory
solvname=`sed -En 's,INPSOLV=\s*([a-zA-Z0-9/\]+),\1,p' ${INPUTDAT}`
# Output complex name
outcompname=`sed -En 's,OUTCOMPNAME=\s*([a-zA-Z0-9/\]+),\1,p' ${INPUTDAT}`
# Output receptor name
outrecname=`sed -En 's,OUTRECEPTORNAME=\s*([a-zA-Z0-9/\]+),\1,p' ${INPUTDAT}`
# Output ligand name
outligname=`sed -En 's,OUTLIGNAME=\s*([a-zA-Z0-9/\]+),\1,p' ${INPUTDAT}`
# Current dir, where the script was started
startdir=`pwd`
# Name of the cumulative log file (in the comparision to the log file for the subsequent clustering)
ALLLOGNAME=`sed -En 's,ALLLOGNAME=\s*([a-zA-Z0-9/\]+),\1,p' ${INPUTDAT}`
# Clustering method
METHOD=`sed -En 's,METHOD=\s*([a-zA-Z0-9/\]+),\1,p' ${INPUTDAT}`
# Cut-off range for the clustering
CUTOFF=`sed -En 's,CUTOFF=\s*([a-zA-Z0-9/\]+),\1,p' ${INPUTDAT}`
# GMX command for starting gromacs
GMXSTART=`sed -En 's,GMXSTART=\s*([a-zA-Z0-9/\]+),\1,p' ${INPUTDAT}`
# Directory name for the results in the subsequent clustering caculation directory
RESULTDIR=`sed -En 's,OUTPUTDIR=\s*([a-zA-Z0-9/\]+),\1,p' ${INPUTDAT}`
# Log name for the subsequent clustering calculation calculation directory
CLUSTLOG=`sed -En 's,CLUSTLOG=\s*([a-zA-Z0-9/\]+),\1,p' ${INPUTDAT}`
# Name for the input trajectory
XTCTOCLUST=`sed -En 's,XTCTOCLUST=\s*([a-zA-Z0-9/\]+),\1,p' ${INPUTDAT}`
# Name for the force field directory
FFFILES=`sed -En 's,FFFILES=\s*([a-zA-Z0-9/\/.]+),\1,p' ${INPUTDAT}`
# Name for the topology file
TOPFILE=`sed -En 's,TOPOLFILE=\s*([a-zA-Z0-9/\]+),\1,p' ${INPUTDAT}`
# Name for the temporary directory for clustering.
CLUSTERTEMP=`sed -En 's,CLUSTERTEMP=\s*([a-zA-Z0-9/\]+),\1,p' ${INPUTDAT}`
UNITFILE="unitclustering.sh"
rm ${ALLLOGNAME}.log
# Checking files
echo -e " \n"$(date +%H:%M:%S)  "${INPUTDAT} checking..." | tee -a ${startdir}/${ALLLOGNAME}.log
if [[ -z ${INPUTDAT// } ]]; then
    echo -e " \n"$(date +%H:%M:%S)  "${INPUTDAT} can not be empty! Please specify Input name." | tee -a ${startdir}/${ALLLOGNAME}.log
    echo -e " \n"$(date +%H:%M:%S)  "EXITING WITH AN ERROR!!!!" | tee -a ${startdir}/${ALLLOGNAME}.log
    exit
else
    echo -e " \n"$(date +%H:%M:%S)  "${INPUTDAT} is ok" | tee -a ${startdir}/${ALLLOGNAME}.log
fi

echo -e " \n"$(date +%H:%M:%S)  "${UNITFILE} checking..." | tee -a ${startdir}/${ALLLOGNAME}.log
if [[ -f ${UNITFILE} ]]; then
    echo -e " \n"$(date +%H:%M:%S)  "The ${UNITFILE} is not present!!! Please copy it to the same directory as this script" | tee -a ${startdir}/${ALLLOGNAME}.log
    echo -e " \n"$(date +%H:%M:%S)  "EXITING WITH AN ERROR!!!!" | tee -a ${startdir}/${ALLLOGNAME}.log
    exit
else
    echo -e " \n"$(date +%H:%M:%S)  "${UNITFILE} is ok" | tee -a ${startdir}/${ALLLOGNAME}.log
fi

# Checking variables
echo -e " \n"$(date +%H:%M:%S)  "${ALLLOGNAME} checking..." | tee -a ${startdir}/${ALLLOGNAME}.log
if [[ -z ${ALLLOGNAME// } ]]; then
    echo -e " \n"$(date +%H:%M:%S)  "${ALLLOGNAME} can not be empty! Please specify alllog  filename." | tee -a ${startdir}/${ALLLOGNAME}.log
    echo -e " \n"$(date +%H:%M:%S)  "EXITING WITH AN ERROR!!!!" | tee -a ${startdir}/${ALLLOGNAME}.log
    exit
else
    echo -e " \n"$(date +%H:%M:%S)  "${ALLLOGNAME} is ok" | tee -a ${startdir}/${ALLLOGNAME}.log
fi

echo -e " \n"$(date +%H:%M:%S)  "${recname} checking..." | tee -a ${startdir}/${ALLLOGNAME}.log
if [[ -z ${recname// } ]]; then
    echo -e " \n"$(date +%H:%M:%S)  "${recname} can not be empty! Please specify complex name in the trajectory" | tee -a ${startdir}/${ALLLOGNAME}.log
    echo -e " \n"$(date +%H:%M:%S)  "EXITING WITH AN ERROR!!!!" | tee -a ${startdir}/${ALLLOGNAME}.log
    exit
else
    echo -e " \n"$(date +%H:%M:%S)  "${recname} is ok" | tee -a ${startdir}/${ALLLOGNAME}.log
fi

echo -e " \n"$(date +%H:%M:%S)  "${solvname} checking..." | tee -a ${startdir}/${ALLLOGNAME}.log
if [[ -z ${solvname// } ]]; then
    echo -e " \n"$(date +%H:%M:%S)  "${solvname} can not be empty! Please specify complex name in the trajectory" | tee -a ${startdir}/${ALLLOGNAME}.log
    echo -e " \n"$(date +%H:%M:%S)  "EXITING WITH AN ERROR!!!!" | tee -a ${startdir}/${ALLLOGNAME}.log
    exit
else
    echo -e " \n"$(date +%H:%M:%S)  "${solvname} is ok" | tee -a ${startdir}/${ALLLOGNAME}.log
fi

echo -e " \n"$(date +%H:%M:%S)  "${outcompname} checking..." | tee -a ${startdir}/${ALLLOGNAME}.log
if [[ -z ${outcompname// } ]]; then
    echo -e " \n"$(date +%H:%M:%S)  "${outcompname} can not be empty! Please specify output complex name." | tee -a ${startdir}/${ALLLOGNAME}.log
    echo -e " \n"$(date +%H:%M:%S)  "EXITING WITH AN ERROR!!!!" | tee -a ${startdir}/${ALLLOGNAME}.log
    exit
else
    echo -e " \n"$(date +%H:%M:%S)  "${outcompname} is ok" | tee -a ${startdir}/${ALLLOGNAME}.log
fi

echo -e " \n"$(date +%H:%M:%S)  "${outligname} checking..." | tee -a ${startdir}/${ALLLOGNAME}.log
if [[ -z ${outligname// } ]]; then
    echo -e " \n"$(date +%H:%M:%S)  "${outligname} can not be empty! Please specify output ligand name." | tee -a ${startdir}/${ALLLOGNAME}.log
    echo -e " \n"$(date +%H:%M:%S)  "EXITING WITH AN ERROR!!!!" | tee -a ${startdir}/${ALLLOGNAME}.log
    exit
else
    echo -e " \n"$(date +%H:%M:%S)  "${outligname} is ok" | tee -a ${startdir}/${ALLLOGNAME}.log
fi

echo -e " \n"$(date +%H:%M:%S)  "${METHOD} checking..." | tee -a ${startdir}/${ALLLOGNAME}.log
if [[ -z ${METHOD// } ]]; then
    echo -e " \n"$(date +%H:%M:%S)  "${METHOD} can not be empty! Please specify clustering method." | tee -a ${startdir}/${ALLLOGNAME}.log
    echo -e " \n"$(date +%H:%M:%S)  "EXITING WITH AN ERROR!!!!" | tee -a ${startdir}/${ALLLOGNAME}.log
    exit
else
    echo -e " \n"$(date +%H:%M:%S)  "${METHOD} is ok" | tee -a ${startdir}/${ALLLOGNAME}.log
fi

echo -e " \n"$(date +%H:%M:%S)  "${CUTOFF} checking..." | tee -a ${startdir}/${ALLLOGNAME}.log
if [[ -z ${CUTOFF// } ]]; then
    echo -e " \n"$(date +%H:%M:%S)  "${CUTOFF} can not be empty! Please specify clustering cut-off range." | tee -a ${startdir}/${ALLLOGNAME}.log
    echo -e " \n"$(date +%H:%M:%S)  "EXITING WITH AN ERROR!!!!" | tee -a ${startdir}/${ALLLOGNAME}.log
    exit
else
    echo -e " \n"$(date +%H:%M:%S)  "${CUTOFF} is ok" | tee -a ${startdir}/${ALLLOGNAME}.log
fi

echo -e " \n"$(date +%H:%M:%S)  "${GMXSTART} checking..." | tee -a ${startdir}/${ALLLOGNAME}.log
if [[ -z ${GMXSTART// } ]]; then
    echo -e " \n"$(date +%H:%M:%S)  "${GMXSTART} can not be empty! Please specify gmx starting command (i.e. gmx_mpi)." | tee -a ${startdir}/${ALLLOGNAME}.log
    echo -e " \n"$(date +%H:%M:%S)  "EXITING WITH AN ERROR!!!!" | tee -a ${startdir}/${ALLLOGNAME}.log
    exit
else
    echo -e " \n"$(date +%H:%M:%S)  "${GMXSTART} is ok" | tee -a ${startdir}/${ALLLOGNAME}.log
fi

echo -e " \n"$(date +%H:%M:%S)  "${RESULTDIR} checking..." | tee -a ${startdir}/${ALLLOGNAME}.log
if [[ -z ${RESULTDIR// } ]]; then
    echo -e " \n"$(date +%H:%M:%S)  "${RESULTDIR} can not be empty! Please specify directory name for the results." | tee -a ${startdir}/${ALLLOGNAME}.log
    echo -e " \n"$(date +%H:%M:%S)  "EXITING WITH AN ERROR!!!!" | tee -a ${startdir}/${ALLLOGNAME}.log
    exit
else
    echo -e " \n"$(date +%H:%M:%S)  "${RESULTDIR} is ok" | tee -a ${startdir}/${ALLLOGNAME}.log
fi

echo -e " \n"$(date +%H:%M:%S)  "${CLUSTLOG} checking..." | tee -a ${startdir}/${ALLLOGNAME}.log
if [[ -z ${CLUSTLOG// } ]]; then
    echo -e " \n"$(date +%H:%M:%S)  "${CLUSTLOG} can not be empty! Please specify clustering log name." | tee -a ${startdir}/${ALLLOGNAME}.log
    echo -e " \n"$(date +%H:%M:%S)  "EXITING WITH AN ERROR!!!!" | tee -a ${startdir}/${ALLLOGNAME}.log
    exit
else
    echo -e " \n"$(date +%H:%M:%S)  "${CLUSTLOG} is ok" | tee -a ${startdir}/${ALLLOGNAME}.log
fi

echo -e " \n"$(date +%H:%M:%S)  "${XTCTOCLUST} checking..." | tee -a ${startdir}/${ALLLOGNAME}.log
if [[ -z ${XTCTOCLUST// } ]]; then
    echo -e " \n"$(date +%H:%M:%S)  "${XTCTOCLUST} can not be empty! Please specify trajectory name for the clustering." | tee -a ${startdir}/${ALLLOGNAME}.log
    echo -e " \n"$(date +%H:%M:%S)  "EXITING WITH AN ERROR!!!!" | tee -a ${startdir}/${ALLLOGNAME}.log
    exit
else
    echo -e " \n"$(date +%H:%M:%S)  "${XTCTOCLUST} is ok" | tee -a ${startdir}/${ALLLOGNAME}.log
fi

echo -e " \n"$(date +%H:%M:%S)  "${FFFILES} checking..." | tee -a ${startdir}/${ALLLOGNAME}.log
if [[ -z ${FFFILES// } ]]; then
    echo -e " \n"$(date +%H:%M:%S)  "${FFFILES} can not be empty! Please specify force field directory name, if it in the same directory, just type dot." | tee -a ${startdir}/${ALLLOGNAME}.log
    echo -e " \n"$(date +%H:%M:%S)  "EXITING WITH AN ERROR!!!!" | tee -a ${startdir}/${ALLLOGNAME}.log
    exit
else
    echo -e " \n"$(date +%H:%M:%S)  "${FFFILES} is ok" | tee -a ${startdir}/${ALLLOGNAME}.log
fi

echo -e " \n"$(date +%H:%M:%S)  "${TOPFILE} checking..." | tee -a ${startdir}/${ALLLOGNAME}.log
if [[ -z ${TOPFILE// } ]]; then
    echo -e " \n"$(date +%H:%M:%S)  "${TOPFILE} can not be empty! Please specify topology filename." | tee -a ${startdir}/${ALLLOGNAME}.log
    echo -e " \n"$(date +%H:%M:%S)  "EXITING WITH AN ERROR!!!!" | tee -a ${startdir}/${ALLLOGNAME}.log
    exit
else
    echo -e " \n"$(date +%H:%M:%S)  "${TOPFILE} is ok" | tee -a ${startdir}/${ALLLOGNAME}.log
fi

# Modules
if [[ -z ${GROMACSDIR// } && -z ${GROMACSMODULLE// } ]]; then
    echo -e " \n"$(date +%H:%M:%S)  "You have to set either GROMACDIR or GROMOD in ${INPUTDAT}" | tee -a ${startdir}/${ALLLOGNAME}.log
    echo -e " \n"$(date +%H:%M:%S)  "EXITING WITH AN ERROR!!!!" | tee -a ${startdir}/${ALLLOGNAME}.log
    exit
fi
if [[ ! -z ${GROMACSDIR// } && ! -z ${GROMACSMODULLE// } ]]; then
    echo -e " \n"$(date +%H:%M:%S)  "You have to set either GROMACDIR or GROMOD in ${INPUTDAT}, but not both" | tee -a ${startdir}/${ALLLOGNAME}.log
    echo -e " \n"$(date +%H:%M:%S)  "EXITING WITH AN ERROR!!!!" | tee -a ${startdir}/${ALLLOGNAME}.log
    exit
fi
if [[ ! -z ${GROMACSMODULLE// } ]]; then
    GROMACSDIR=`echo "${GROMACSMODULLE}"`
fi
# Main Program
# For loop for going to the receptor directory
echo -e " \n"$(date +%H:%M:%S)  "### STARTING THE CLUSTERING CALCULATIONS ###" | tee -a ${startdir}/${ALLLOGNAME}.log
for dir in ${dirlist[@]}
do
    # Going to the receptor directory
    echo -e " \n"$(date +%H:%M:%S)  "Going in to ${dir}" | tee -a ${startdir}/${ALLLOGNAME}.log
    cd ${dir}
    echo -e " \n"$(date +%H:%M:%S)  "You are in directory `pwd`" | tee -a ${startdir}/${ALLLOGNAME}.log
    # For loop for going to the ligand directory
    for sim in ${sublist[@]}
    do
        IFS=',':${IFS}
        set -- ${sim}
        # Going to the ligand directory
        cd ${1}
        echo -e " \n"$(date +%H:%M:%S)  "Going in to ${1}" | tee -a ${startdir}/${ALLLOGNAME}.log
        cp ${startdir}/${UNITFILE} .
        echo -e " \n"$(date +%H:%M:%S) "Starting calculations  for ${dir}/${1}" | tee -a ${startdir}/${ALLLOGNAME}.log
        chmod 755 ${UNITFILE}
        curdir=`pwd`
        echo "Current directory ${curdir}" | tee -a ${startdir}/${ALLLOGNAME}.log
        sleep 1
        ./${UNITFILE} "${curdir}" "${1}" "${RESULTDIR}" "${recname}" "${solvname}" "${outcompname}" "${outrecname}" "${outligname}"\
         "${METHOD}" "${CUTOFF}" "${GMXSTART}" "${CLUSTLOG}" "${XTCTOCLUST}" "${FFFILES}" "${TOPFILE}" "${CLUSTERTEMP}" "${GROMACSDIR}"
        if [[ $? -eq 0 ]]; then
                    echo -e " \n"$(date +%H:%M:%S) "Calculations  for ${dir}/${1} finished successfully" | tee -a ${startdir}/${ALLLOGNAME}.log
            echo -e " \n"$(date +%H:%M:%S)  "Going back to directory ${dir}" | tee -a ${startdir}/${ALLLOGNAME}.log
            rm ${UNITFILE}
            cd ..
        else
            echo -e " \n"$(date +%H:%M:%S)  "An error occurred !! EXITING!!" | tee -a ${startdir}/${ALLLOGNAME}.log
            echo -e " \n"$(date +%H:%M:%S)  "Clustering FAILED!" | tee -a ${startdir}/${ALLLOGNAME}.log
            exit
        fi
    done
    cd ..
done