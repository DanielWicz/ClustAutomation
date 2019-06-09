#!/bin/bash
# Constants
## Current directory, where the scripts was started
curdir=${1}
## Directory of ligand, most of time named the same as the ligand
ligname=${2}
## Directory for results
RESULTDIR=${3}
## Name for complex in the initial trajectory
initcomplex=${4}
## Name for complex in the initial trajectory
initsolv=${5}
## Complex name for the output
complex=${6}
## Receptor name for the output
receptor=${7}
## Ligand name for the output
ligand=${8}
## Clustering method
method=${9}
## Cut-off Range
cutoff=${10}
### GROMACS tools ###
## Which gmx start should be used
gmx="${11}"
trjconv="${gmx} trjconv"
makendx="${gmx} make_ndx"
grompp="${gmx} grompp"
cluster="${gmx} cluster"
echo ${cluster}
### DIRECTORY AND FILES ###
LOGNAME=${12}
# Name for the temporary directory for clustering.
FOLDNAME=${16}
# Name for the input trajectory
name_xtc=${13}
# Name for the force field directory
FFFILES=${14}
# Name for the topology file
TOPOL=${15}.top
# GMX command for starting gromacs
GMXDIR=${17}
# Modules
if [[ ${GMXDIR} =~ "module"  ]]
then
    module purge
    eval ${GMXDIR}
else
    export PATH=${GMXDIR}:${PATH}
fi
# Test Gromacs
${gmx} > /dev/null 2>&1
if [[ $? -eq 0 ]]
then
    echo -e " \n"$(date +%H:%M:%S)  "### GROMACS software is working ### \n" | tee -a ${curdir}/${LOGNAME}
else
    echo -e " \n"$(date +%H:%M:%S)  "### GROMACS software is not working ### \n" | tee -a ${curdir}/${LOGNAME}
    echo -e " \n"$(date +%H:%M:%S)  "### EXITING WITH ERROR ### \n" | tee -a ${curdir}/${LOGNAME}
    exit 1
fi
cd ${curdir}
if [ -d "${RESULTDIR}" ]; then
    if [ -d "${RESULTDIR}_BACKUP" ]; then
        echo -e " \n"$(date +%H:%M:%S)  "### Result ${RESULTDIR}_BACKUP directory exists Exiting calculataions ### \n" | tee -a ${curdir}/${LOGNAME}
        mkdir -p ${curdir}/${RESULTDIR}
        mv ${curdir}/${LOGNAME} ${curdir}/${RESULTDIR}
        exit 1
    else
        echo -e " \n"$(date +%H:%M:%S)  "### Result ${RESULTDIR} directory exists, creating backup ${RESULTDIR}_BACKUP ### \n" | tee -a ${curdir}/${LOGNAME}
        mv ${RESULTDIR} ${RESULTDIR}_BACKUP
        rm -r ${RESULTDIR}
    fi
fi
mkdir -p ${curdir}/${RESULTDIR}
mv ${curdir}/${LOGNAME} ${curdir}/${RESULTDIR}
if [[ -f STD_ERR0 ]]
then
    rm STD_ERR0
fi
echo -e " \n"$(date +%H:%M:%S)  "### Starting preparation of trajectory files files ### \n" | tee -a ${curdir}/${LOGNAME}
echo -e " \n"$(date +%H:%M:%S)  "Current directory ${curdir}" | tee -a ${curdir}/${LOGNAME}
echo -e " \n"$(date +%H:%M:%S)  "Creating directory ${FOLDNAME}" | tee -a ${curdir}/${LOGNAME}
mkdir -p ${FOLDNAME}
echo -e " \n"$(date +%H:%M:%S)  "Creating directory ${FOLDNAME}/${ligname}" | tee -a ${curdir}/${LOGNAME}
mkdir -p ${FOLDNAME}/${ligname}
echo -e " \n"$(date +%H:%M:%S)  "Removing PBC and centering to trajectroy file ${name_xtc}.xtc" | tee -a ${curdir}/${LOGNAME}
echo "$initcomplex" "$initcomplex" | ${trjconv} -f ${name_xtc}.xtc -o ${name_xtc}_out.xtc -n index.ndx -s ${name_xtc}.tpr -pbc mol -center -n  >> ${curdir}/STD_ERR0 2>&1
lackofiles=`sed -En 's;\s+File\s.([A-Za-z0-9\_\.]+).\s.+;\1;p' STD_ERR0`
if [[ ! -z ${lackofiles} ]]
then
    echo -e " \n"$(date +%H:%M:%S)  "There is a lack of files ${lackofiles}" | tee -a ${curdir}/${LOGNAME}
    echo -e " \n"$(date +%H:%M:%S)  "Look for more in the GROMACS_prePBSAERRORS file" | tee -a ${curdir}/${LOGNAME}
    if [ -f ${curdir}/STD_ERR0 ]; then
        mv ${curdir}/STD_ERR0 ${curdir}/${RESULTDIR}/GROMACS_prePBSAERRORS
    fi
        echo -e " \n"$(date +%H:%M:%S)  "### EXITING WITH ERROR ### \n" | tee -a ${curdir}/${LOGNAME}
    exit 1
fi
echo -e " \n"$(date +%H:%M:%S)  "Removing PBC and centering to gro file ${name_xtc}.gro" | tee -a ${curdir}/${LOGNAME}
echo "$initcomplex" "$initcomplex" | ${trjconv} -f ${name_xtc}.xtc -dump 0 -o ${name_xtc}_out.gro -s ${name_xtc}.tpr -pbc mol -center -n index.ndx  >> ${curdir}/STD_ERR0 2>&1


echo -e " \n"$(date +%H:%M:%S)  "Moving ${name_xtc}_out.xtc to ${FOLDNAME}/${ligname}" | tee -a ${curdir}/${LOGNAME}
mv ${name_xtc}_out.xtc ${curdir}/${FOLDNAME}/${ligname}/.
echo -e " \n"$(date +%H:%M:%S)  "Moving ${name_xtc}_out.gro to ${FOLDNAME}/${ligname}" | tee -a ${curdir}/${LOGNAME}
mv ${name_xtc}_out.gro ${curdir}/${FOLDNAME}/${ligname}/.

echo -e " \n"$(date +%H:%M:%S)  "Changing group name ${initcomplex} to ${receptor} in ${name_xtc}_out.mdp" | tee -a ${curdir}/${LOGNAME}
cat ${name_xtc}.mdp | sed -e "s:${initcomplex}:${receptor}:g" > ${name_xtc}_temp.mdp
# Custom groups !!!! Change it !
echo -e " \n"$(date +%H:%M:%S)  "Changing group name ${initsolv} to ${receptor} in ${name_xtc}_out.mdp" | tee -a ${curdir}/${LOGNAME}
cat ${name_xtc}_temp.mdp | sed -e "s:${initsolv}:${ligand}:g" > ${name_xtc}_out.mdp
rm -f ${name_xtc}_temp.mdp
echo -e " \n"$(date +%H:%M:%S)  "Moving ${name_xtc}_out.mdp to ${FOLDNAME}/${ligname}" | tee -a ${curdir}/${LOGNAME}
mv ${name_xtc}_out.mdp ${curdir}/${FOLDNAME}/${ligname}/.


echo -e " \n"$(date +%H:%M:%S)  "Moving ${TOPOL} to ${FOLDNAME}/${ligname}" | tee -a ${curdir}/${LOGNAME}
cp ${curdir}/"${TOPOL}" ${curdir}/${FOLDNAME}/${ligname}/.
echo -e " \n"$(date +%H:%M:%S)  "Moving *.inp from ${FFFILES} to ${FOLDNAME}/${ligname}" | tee -a ${curdir}/${LOGNAME}
cp  ${curdir}/${FFFILES}/*.itp ${curdir}/${FOLDNAME}/${ligname}/.
declare -a listofitp=(${curdir}/${FOLDNAME}/${ligname}/*.itp)
for itp in ${listofitp[@]}
do
    sed -i 's;#include "../restraints/[a-zA-Z_.\"0-9]\+;;g' ${itp}
done
echo -e " \n"$(date +%H:%M:%S)  "Going to ${FOLDNAME}" | tee -a ${curdir}/${LOGNAME}
cd ${curdir}/${FOLDNAME}


echo -e " \n"$(date +%H:%M:%S)  "Going to ${ligname}" | tee -a ${curdir}/${LOGNAME}
cd ${ligname}
echo -e " \n"$(date +%H:%M:%S)  "Changing ${TOPOL} to fit the requirements" | tee -a ${curdir}/${LOGNAME}

# Groups to exclude are custom, so they have to be changed!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
cat ${TOPOL} | sed -e "s:\"toppar\/:\":g" | grep -v "HETA" | grep -v "POT" | grep -v "CLA" | grep -v "TIP3" > temp_${TOPOL}

rm ${TOPOL}
mv temp_${TOPOL} ${TOPOL}
cat ${TOPOL} >> ${curdir}/STD_ERR0 2>&1
echo -e " \n"$(date +%H:%M:%S)  "Creating index.ndx file for ${complex}, ${receptor}, ${ligand} groups" | tee -a ${curdir}/${LOGNAME}
echo -e "2 | 3 | 4 \n" "name 6 receptor \n" "name 5 ligand \n" "6 | 5 \n" "name 7 complex \n" "q \n"  | ${makendx} -o index.ndx -f ${name_xtc}_out.gro >> ${curdir}/STD_ERR0 2>&1
echo -e " \n"$(date +%H:%M:%S)  "Creating ${name_xtc}_out.tpr file for ${complex}, ${receptor}, ${ligand} groups" | tee -a ${curdir}/${LOGNAME}
echo "$complex" | ${grompp} -f ${name_xtc}_out.mdp -c ${name_xtc}_out.gro -r ${name_xtc}_out.gro -n index.ndx -o ${name_xtc}_out.tpr -maxwarn 2 >> ${curdir}/STD_ERR0 2>&1
if [ ! -f ${name_xtc}_out.tpr ]; then
    echo -e " \n"$(date +%H:%M:%S)  "File preparation failed. Exiting..." | tee -a ${curdir}/${LOGNAME}
    mkdir -p ${curdir}/${RESULTDIR}
    if [ -f ${curdir}/STD_ERR0 ]; then
        mv ${curdir}/STD_ERR0 ${curdir}/${RESULTDIR}/GROMACS_prePBSAERRORS
    fi
    echo -e " \n"$(date +%H:%M:%S)  "Look for more in GROMACS_prePBSAERRORS file" | tee -a ${curdir}/${LOGNAME}
    mv ${curdir}/${LOGNAME} ${curdir}/${RESULTDIR}
    rm -r ${curdir}/${FOLDNAME}
    exit 1
fi

echo -e " \n"$(date +%H:%M:%S)  "Going to ${FOLDNAME}/${ligname}" | tee -a ${curdir}/${LOGNAME}
cd ${curdir}/${FOLDNAME}/${ligname}
#### HERE BEGINS CLUSTERING ###
echo -e " \n"$(date +%H:%M:%S)  "### Starting clustering!!! ### \n" | tee -a ${curdir}/${LOGNAME}

echo "$complex" "$complex" | ${cluster} -f ${name_xtc}_out.xtc -s ${name_xtc}_out.tpr -n index.ndx -o ${name_xtc}_clust.xpm -dist -sz -fit -tu ns -cl clustered.xtc -noav -method ${method} -cutoff ${cutoff} >> ${curdir}/STD_ERR0 2>&1
echo -e " \n"$(date +%H:%M:%S)  "Obtaining the best representative from the cluster" | tee -a ${curdir}/${LOGNAME}
echo "$complex" | ${trjconv} -s ${name_xtc}_out.tpr -f clustered.xtc -n index.ndx -dump 0 -o ${name_xtc}_clustered.gro >> ${curdir}/STD_ERR0 2>&1

echo -e " \n"$(date +%H:%M:%S)  "Creating Results..." | tee -a ${curdir}/${LOGNAME}

if [ -f ${curdir}/${FOLDNAME}/${ligname}/cluster.log ]; then
    mv ${curdir}/${FOLDNAME}/${ligname}/cluster.log ${curdir}/${RESULTDIR}
fi
if [ -f ${curdir}/${FOLDNAME}/${ligname}/${name_xtc}_clustered.gro ]; then
    mv ${curdir}/${FOLDNAME}/${ligname}/${name_xtc}_clustered.gro ${curdir}/${RESULTDIR}
fi
if [ -f ${curdir}/STD_ERR0 ]; then
    mv ${curdir}/STD_ERR0 ${curdir}/${RESULTDIR}/GROMACS_prePBSAERRORS
fi
rm -r ${curdir}/${FOLDNAME}
echo -e " \n"$(date +%H:%M:%S)  "\n########################################" | tee -a ${curdir}/${RESULTDIR}/${LOGNAME}
echo -e " \n"$(date +%H:%M:%S)  "### Script created by Daniel Wiczew  ###" | tee -a ${curdir}/${RESULTDIR}/${LOGNAME}
echo -e " \n"$(date +%H:%M:%S)  "### Contact: daniel.wiczew@gmail.com ###" | tee -a ${curdir}/${RESULTDIR}/${LOGNAME}
echo -e " \n"$(date +%H:%M:%S)  "########################################\n" | tee -a ${curdir}/${RESULTDIR}/${LOGNAME}
exit 0