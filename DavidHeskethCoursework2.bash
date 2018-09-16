#!/bin/bash

firstID=$1
searchID=$firstID


#colour data to more effectively show new entries
################################################
RED='\033[0;31m'
NC='\033[0m'
################################################

#checks if there has been a PId provided
################################################
if [[ -z $searchID ]]
then
    read -p "please provide a PID: " searchID
fi
################################################

#print network data to a file
#################################
sudo netstat -ap > netstat.tmp
#################################

#loop through 3 generations of parents printing the ID, Command Name, and network connections
#if no id has been provided then it searches on $$
#does this by searching through the ps information for the current search ID
#if the function hits the root of the streed (pid 1) then it breaks out of the loop
##############################################################
for i in {0..3}
do
        echo -e "${RED} PID: $searchID at parent depth $i ${NC}"
        echo Command Name: `ps -p ${searchID:-$$} -o cmd=`
        echo Network Connections:
        cat netstat.tmp|egrep "(Proto| $searchID/)"

        searchID=`ps -p ${searchID:-$$} -o ppid=`
        if [[ (($searchID <1)) ]]
        then
                break
        fi
done
#############################################################




#This function runs a similar selection of code where except instead of iterating
#over a predetermined number, it iterates over  selection of PIDs and searches for the children of each of these
#it then calls a similar function which searches for the children of the pocess id it has been passed
#this function goes three deep in a single family line before going to the next family line
#############################################################
function FindChildren
{
        sID=$1
        depth=1
        childPIDs=`ps --ppid $sID|grep -v PID|awk '{print $1}'`
        counter=1

        for i in $childPIDs
        do
                sID=$i
                echo -e "${RED} PID: $sID child $counter at depth $depth ${NC} "
                echo Command Name: `ps -p ${sID} -o cmd=`
                echo Network Connections:
 cat netstat.tmp|egrep "(Proto| $sID/)"
                ((counter++))
                FindGrandChildren $sID
        done

}
###########################################################


#these functions do as above but wih future generations, displaying pid, cmd, and netstat information as relevant
################################################################
function FindGrandChildren
{
        cID=$1
        depth=2
        gChildPIDs=`ps --ppid $cID|grep -v PID|awk '{print $1}'`
        counter=1
        for i in $gChildPIDs
        do
                cID=$i
                echo -e "${RED} PID: $cID :child $counter at depth $depth ${NC}"
                echo Command Name: `ps -p ${cID} -o cmd=`
                echo Network Connections:
                cat netstat.tmp|egrep "(Proto| $cID/)"
                ((counter++))
                FindGreatGrandChildren $cID
        done
}

function FindGreatGrandChildren
{
        gID=$1
        depth=3
        gGChildPIDs=`ps --ppid $gID|grep -v PID|awk '{print $1}'`
        counter=1
        for i in $gGChildPIDs
        do
                gID=$i
                echo -e "${RED}PID: $gID child $counter at depth $depth ${NC}"
                echo Command Name: `ps -p ${gID} -o cmd=`
                echo Network Connections:
                cat netstat.tmp|egrep "(Proto| $gID/)"
                ((counter++))
        done
}
################################################################

#calls the first find children function
FindChildren $firstID

#removes the created files
rm netstat.tmp
