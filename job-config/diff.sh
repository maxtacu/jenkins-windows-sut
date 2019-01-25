#!/bin/bash
DIFF=$(diff job-config/config.xml /var/lib/jenkins/jobs/Test-build/config.xml)       
if [[ "$DIFF" == "" ]];
then
        echo "No differences"
else
        echo "Differences detected"
fi
