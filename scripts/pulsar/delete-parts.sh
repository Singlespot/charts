#!/bin/bash

function delete_component() {
	namespace=$1
	component=$2
	case $component in
		alert-manager|broker|loki|prometheus|proxy|recovery|toolset|zookeeper)
			type=sts
			;;
		bookie|pulsar-manager)
			type=sts,job
			;;
		grafana)
			type=deploy
			;;
		pulsar-init)
			type=job
			;;
		*)
			echo -e \\n"Component $component unknown."
			exit
			;;
	esac
	for str in $(kubectl --namespace ${namespace} get $type -o json | jq -r ".items[] | select(.metadata.name | test(\".*${component}.*\")) | .kind + \"/\" + .metadata.name"); do
		kubectl --namespace ${namespace} delete $str
	done
}

function delete_type() {
	namespace=$1
	IFS=":" read -ra ARRAY <<< "$2"
	type=${ARRAY[0]}
	name=${ARRAY[1]}
	if [ -z "$name" ]; then
		objs=$(kubectl --namespace ${namespace} get $type -o jsonpath={.items[*].metadata.name})
	else
		objs=$(kubectl --namespace ${namespace} get $type -o json | jq -r ".items[] | .metadata.name" | grep ${name})
	fi
	for obj in $objs; do
		kubectl --namespace ${namespace} delete $type $obj
	done
}

ALL_COMPONENTS="alert-manager,bookie,broker,grafana,loki,prometheus,proxy,pulsar-init,pulsar-manager,recovery,toolset,zookeeper"
ALL_TYPES="deploy,sts,pvc,svc,job,cm,secret"

all=false
components=''
namespace=''
types=''

while getopts ac:n:t: FLAG; do
	case $FLAG in
	a)
		all=true
		;;
	c)
		components=$OPTARG
		;;
	n)
		namespace=$OPTARG
		;;
	t)
		types=$OPTARG
		;;
	\?) # unrecognized option
		echo -e \\n"Option $OPTARG not allowed."
		;;
	esac
done

if [ "$namespace" = "" ]; then
	echo "namespace is missing"
	exit 1
fi

if [ "$all" = true ]; then
	components=$ALL_COMPONENTS
	types=$ALL_TYPES
fi

if [ "$components" = "all" ]; then
	components=$ALL_COMPONENTS
fi
IFS=',' read -ra COMPONENTS <<< "$components"
for comp in "${COMPONENTS[@]}"; do
		delete_component $namespace $comp
done

if [ "$types" = "all" ]; then
	types=$ALL_TYPES
fi
IFS=',' read -ra TYPES <<< "$types"
for type in "${TYPES[@]}"; do
		delete_type $namespace $type
done
