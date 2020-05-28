#!/bin/bash

###################
#
# Author : Byte13.org
# Last modification : 27.05.2020 08:15
#
# Purpose : extract inventory of ClusteRoles, Roles, Rules and Bindings 
#
# Pre-requisits : 
#        Running kubernetes cluster
#	 Enough credentials to read all ClusteRoles, Roles, Rules and Bindings 
#
###################

###################
#
# User variables section
#
CURDATETIME=`date +%Y%m%d%H%M`
ROLESOUTPUTFILE=k8s_roles-members-rights_${CURDATETIME}.csv
CLROLESOUTPUTFILE=k8s_clusterroles-members-rights_${CURDATETIME}.csv
#
# End of user varaibles section. Nothing to modify on the rest of this script
###################

# Get full list of all namespaces
NSLIST=$(kubectl get namespaces -o=jsonpath="{range .items[*]}[{.metadata.name}] {end}" | sed 's/\[//g; s/\]//g')
#echo ${NSLIST} | sed 's/ /\n/g; s/\[//g; s/\]//g'



function GetRolesRules () {

    echo "Namespace|Role|apiGroups|Resources|ResourceNames|Verbs|MemberType|Member" >>${ROLESOUTPUTFILE}

    for NS in ${NSLIST} ; do

        ROLESLIST=""
        # Get full list of roles in namespace
        ROLESLIST=$(kubectl get roles -n ${NS} -o=jsonpath="{range .items[*]}[{.metadata.name}] {end}" | sed 's/\[//g; s/\]//g')
        #echo ${ROLESLIST} | sed 's/ /\n/g; s/\[//g; s/\]//g'
        ROLESCOUNT=$(kubectl get roles -n ${NS} -o=jsonpath="{range .items[*]}[{.metadata.name}] {'\n'} {end}" | wc -l)

        a=0
        z=$((ROLESCOUNT-1))
        #for ROLE in ${ROLESLIST}; do 
        for a in $(seq 0 ${z}) ; do

       	    ROLE=$(kubectl get role -n ${NS} -o=jsonpath="{.items[${a}].metadata.name}")
            echo "Namespace ${NS} - RBAC rules in role ${ROLE}..."

            RULESLIST=$(kubectl get roles ${ROLE} -n ${NS} -o=jsonpath="{.rules[*].apiGroups}")
	    RULESCOUNT=$(kubectl get roles ${ROLE} -n ${NS} -o=jsonpath="{range .rules[*]}{.apiGroups}{'\n'} {end}" | wc -l)

            # Get rules
            b=0
            y=$((RULESCOUNT-1))
	    APIGRP=""
	    RESOURCES=""
	    RESNAME=""
	    VERBS=""
            #for RULES in ${RULESLIST}; do
            for b in $(seq 0 ${y}) ; do

                # Get rights
	        # All-in-one
	        #kubectl get role ${ROLE} -n ${NS} -o=jsonpath="{.rules[${b}].apiGroups}{'\n'} \
	        #                                               {.rules[${b}].resources}{'\n'} \
	        #						    {.rules[${b}].resourceNames}{'\n'} \
                #						    {.rules[${b}].verbs}{'\n'}"

                # One by one
	        APIGRPS=$(kubectl get role ${ROLE} -n ${NS} -o=jsonpath="{.rules[${b}].apiGroups}")
	        RESOURCES=$(kubectl get role ${ROLE} -n ${NS} -o=jsonpath="{.rules[${b}].resources}")
	        RESNAMES=$(kubectl get role ${ROLE} -n ${NS} -o=jsonpath="{.rules[${b}].resourceNames}")
	        VERBS=$(kubectl get role ${ROLE} -n ${NS} -o=jsonpath="{.rules[${b}].verbs}")


		MEMBERSLIST=$(GetRolesBindings ${NS} ${ROLE})

		for MEMBER in ${MEMBERSLIST} ; do
	            echo "${NS}|${ROLE}|${APIGRPS}|${RESOURCES}|${RESNAMES}|${VERBS}|${MEMBER}"
	            echo "${NS}|${ROLE}|${APIGRPS}|${RESOURCES}|${RESNAMES}|${VERBS}|${MEMBER}" >>${ROLESOUTPUTFILE}
		done

	    #b=$((b+1))
            done

        #a=$((a+1)) 
        done
    done

    # Alternative with jsonpath filters, only
    #kubectl get roles -A -o=jsonpath='{range .items[*]}{"################ Namespace : "}{@.metadata.namespace}{"\n"}{"Role : "}{@.metadata.name}{"\n"}{range @.rules[*]}{"    apiGroup : "}{@.apiGroups}{"\n"}{"        Resource : "}{@.resources}{"\n"}{"        ResourceName : "}{@.resourceNames}{"\n"}{"        Verbs : "}{@.verbs}{"\n"}{end}{"\n"}{end}'
}


function GetClusteRolesRules () {

    CLUSTERROLESLIST=""
    # Get full list of cluster roles
    CLUSTERROLESLIST=$(kubectl get clusterroles -o=jsonpath="{range .items[*]}[{.metadata.name}] {'\n'} {end}" | sed 's/\[//g; s/\]//g')
#echo ${CLUSTERROLESLIST} | sed 's/ /\n/g; s/\[//g; s/\]//g'
    CLUSTERROLESCOUNT=$(kubectl get clusterroles -o=jsonpath="{range .items[*]}[{.metadata.name}] {'\n'} {end}" | wc -l)

    echo "Namespace|ClusetrRole|apiGroups|Resources|ResourceNames|Verbs|MemberType|Member" >>${CLROLESOUTPUTFILE}

    a=0
    z=$((CLUSTERROLESCOUNT-1))
    #for CLUSTERROLE in ${CLUSTERROLESLIST}; do 
    for a in $(seq 0 ${z}) ; do

        CLUSTERROLE=$(kubectl get clusterrole -o=jsonpath="{.items[${a}].metadata.name}")
        echo "RBAC rules in cluster role ${CLUSTERROLE}..."

        RULESLIST=$(kubectl get clusterroles ${CLUSTERROLE} -o=jsonpath="{.rules[*].apiGroups}")
        RULESCOUNT=$(kubectl get clusterroles ${CLUSTERROLE} -o=jsonpath="{range .rules[*]}{.apiGroups}{'\n'} {end}" | wc -l)

        # Get rules
        b=0
        y=$((RULESCOUNT-1))
        APIGRP=""
        RESOURCES=""
        RESNAMES=""
        VERBS=""
        #for RULES in ${RULESLIST}; do
        for b in $(seq 0 ${y}) ; do

            # Get rights
            # All-in-one
            #kubectl get role ${CLUSTERROLE} -o=jsonpath="{.rules[${b}].apiGroups}{'\n'} \
            #                                               {.rules[${b}].resources}{'\n'} \
            #						    {.rules[${b}].resourceNames}{'\n'} \
            #						    {.rules[${b}].verbs}{'\n'}"

            # One by one
            APIGRPS=$(kubectl get clusterrole ${CLUSTERROLE} -o=jsonpath="{.rules[${b}].apiGroups}")
            RESOURCES=$(kubectl get clusterrole ${CLUSTERROLE} -o=jsonpath="{.rules[${b}].resources}")
            RESNAMES=$(kubectl get clusterrole ${CLUSTERROLE} -o=jsonpath="{.rules[${b}].resourceNames}")
            VERBS=$(kubectl get clusterrole ${CLUSTERROLE} -o=jsonpath="{.rules[${b}].verbs}")

	    MEMBERSLIST=$(GetClusterRolesBindings ${CLUSTERROLE})

	    for MEMBER in ${MEMBERSLIST} ; do
                echo "N/A|${CLUSTERROLE}|${APIGRPS}|${RESOURCES}|${RESNAMES}|${VERBS}|${MEMBER}"
                echo "N/A|${CLUSTERROLE}|${APIGRPS}|${RESOURCES}|${RESNAMES}|${VERBS}|${MEMBER}" >>${ROLESOUTPUTFILE}
            done

        #b=((b+1))
        done

    a=$((a+1)) 
    done

    # Alternative with jsonpath filters, only
    #kubectl get clusterroles -o=jsonpath='{range .items[*]}{"################ Cluster Role : "}{@.metadata.name}{"\n"}{range @.rules[*]}{"    apiGroup : "}{@.apiGroups}{"\n"}{"        Resource : "}{@.resources}{"\n"}{"        ResourceName : "}{@.resourceNames}{"\n"}{"        Verbs : "}{@.verbs}{"\n"}{end}{"\n"}{end}'
}

function GetRolesBindings () {

    ns=${1}
    rn=${2}

    kubectl get rolebindings -n ${ns} -o=jsonpath="{range .items[?(.roleRef.name == '${rn}')]} {range @.subjects[*]} {@.kind}{'|'}{@.name}{'\n'} {end}"
}


function GetClusterRolesBindings () {

    crn=$1

    kubectl get clusterrolebindings -o=jsonpath="{range .items[?(.roleRef.name == '${crn}')]} {range @.subjects[*]} {@.kind}{'|'}{@.name}{'\n'} {end}"

}

GetRolesRules
GetClusteRolesRules
