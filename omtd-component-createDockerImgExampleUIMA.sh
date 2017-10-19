#!/bin/bash

OMTDSHAREDescriptorsFolderRoot="/home/ilsp/Desktop/OMTDTemp/"
OMTDSHAREDescriptorsFolder="omtds-dkpro-core-1.9.0-SNAPSHOT"
DockerRegistyHOST="snf-765691.vm.okeanos.grnet.gr"
GalaxyID="omtdDKPro"
DockerFile="omtd-component-executor-uima.dockerfile"
ComponentID="dkpro-core"
ComponentVersion="1.9.0-SNAPSHOT"

./omtd-component-createDockerImg.sh $DockerRegistyHOST $OMTDSHAREDescriptorsFolderRoot $OMTDSHAREDescriptorsFolder $GalaxyID $ComponentID $ComponentVersion $DockerFile
