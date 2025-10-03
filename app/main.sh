#! /bin/bash
#
# Run script for flywheel/infant_recon-all Gear.
#
# Authorship:  Niall Bourke
#
##############################################################################
# Define directory names and containers

subject=$1
session="${2// /_}" # replace spaces with underscores
# age=$3
# num_threads=$4
base_filename=${subject}_${session}

echo "file base name: $base_filename"

FLYWHEEL_BASE=/flywheel/v0
INPUT_DIR=$FLYWHEEL_BASE/input/
OUTPUT_DIR=$FLYWHEEL_BASE/output
WORKDIR=$FLYWHEEL_BASE/work
CONFIG_FILE=$FLYWHEEL_BASE/config.json
CONTAINER='[flywheel/mri_WMHsynthseg]'

export FREESURFER_HOME=/usr/local/freesurfer/8.1.0
export SUBJECTS_DIR=$WORKDIR  # or wherever you want outputs
source $FREESURFER_HOME/SetUpFreeSurfer.sh

# Force correct Perl environment for Flywheel
export PATH=$FREESURFER_HOME/mni/bin:$PATH
export PERL5LIB=$FREESURFER_HOME/mni/share/perl5

# which nu_correct
# nu_correct -help

# # Verify nu_correct is now available
# which nu_correct || echo "Still missing nu_correct after sourcing"
# echo "Current user: $(whoami)"
# echo "Current UID/GID: $(id)"
# echo "nu_correct permissions:"
# ls -la /usr/local/freesurfer/8.1.0/mni/bin/nu_correct
# echo "Can execute nu_correct:"
# test -x /usr/local/freesurfer/8.1.0/mni/bin/nu_correct && echo "YES" || echo "NO"
# echo "Directory permissions:"
# ls -ld /usr/local/freesurfer/8.1.0/mni/bin/

# echo "=== FILESYSTEM MOUNT INFO ==="
# mount | grep -E "(noexec|nosuid)"
# cat /proc/mounts | grep -E "(noexec|nosuid)"

# echo "=== DIRECT BINARY TEST ==="
# /usr/local/freesurfer/8.1.0/mni/bin/nu_correct --help 2>&1
# echo "Exit code: $?"

# echo "=== SYSTEM RESOURCES ==="
# df -h
# free -h
# ulimit -a

# echo "=== SECURITY CONTEXT ==="
# id
# ls -laZ /usr/local/freesurfer/8.1.0/mni/bin/nu_correct 2>/dev/null || echo "No SELinux context"
# echo "============================="
# echo "permissions"
# ls -ltra /flywheel/v0/

mkdir $FLYWHEEL_BASE/work
chmod 777 $FLYWHEEL_BASE/work

##############################################################################
# Handle INPUT file

# Find input file In input directory with the extension
input_file=`find $INPUT_DIR -iname '*.nii' -o -iname '*.nii.gz'`

# Check that input file exists
if [[ -e $input_file ]]; then
  echo "${CONTAINER}  Input file found: ${input_file}"

    # Determine the type of the input file
  if [[ "$input_file" == *.nii ]]; then
    type=".nii"
  elif [[ "$input_file" == *.nii.gz ]]; then
    type=".nii.gz"
  fi
  
else
  echo "${CONTAINER}: No inputs were found within input directory $INPUT_DIR"
  exit 1
fi

##############################################################################
# Set initial exit status
exit_status=0

# Run mri_WMHsynthseg with options
if [[ -e $input_file ]]; then
  echo "Running mri_WMHsynthseg..."
  /usr/local/freesurfer/8.1.0/bin/mri_WMHsynthseg --i $input_file --o /flywheel/v0/output/${base_filename}_desc-wmhsynthseg.nii.gz --csv_vols /flywheel/v0/output/${base_filename}_desc-wmhsynthseg_volumes.csv --save_lesion_probabilities 
  exit_status=$?
fi

# Organize output files
# zip -r $OUTPUT_DIR/$base_filename.zip $WORKDIR/$base_filename
# mri_convert --out_orientation RAS $WORKDIR/$base_filename/mri/norm.mgz ${OUTPUT_DIR}/${base_filename}_desc-norm.nii.gz
# cp $WORKDIR/$base_filename/mri/aseg.nii.gz $OUTPUT_DIR/${base_filename}_desc-aseg_dseg.nii.gz

# Handle Exit status
if [[ $exit_status == 0 ]]; then
  echo -e "${CONTAINER} Success!"
  exit 0
else
  echo "${CONTAINER}  Something went wrong! mri_WMHsynthseg exited non-zero!"
  exit 1
fi
