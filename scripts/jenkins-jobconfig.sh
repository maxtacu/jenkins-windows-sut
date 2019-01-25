# First locate where your jenkins is installed on linux machine and edit the JNKSPATH variable
# bash jenkins-jobconfig.sh <path-to-jenkins> <build-name>
JNKSPATH=${1:-"/var/lib/jenkins"}
JOBNAME=${2:-"CI-build"} # Build name that will be in Jenkins
mkdir -p "$PATH/jobs/$JOBNAME" && cp ../job-config/config.xml "$PATH/jobs/$JOBNAME"
chown jenkins:jenkins "$PATH/jobs/$JOBNAME"
echo "Config was created successfully"