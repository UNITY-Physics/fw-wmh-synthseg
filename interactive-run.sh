#!/usr/bin/env bash 

GEAR=fw-wmh-synthseg
IMAGE=flywheel/wmh-synthseg:0.0.2
LOG=wmh-synthseg-0.0.2-68de9a3725cbee1d3998483f
user=/Users/nbourke/GD/atom/

# Command:
docker run -it --rm --entrypoint bash\
	-v $user/unity/fw-gears/${GEAR}/app/:/flywheel/v0/app\
	-v $user/unity/fw-gears/${GEAR}/utils:/flywheel/v0/utils\
	-v $user/unity/fw-gears/${GEAR}/shared/utils:/flywheel/v0/shared/utils\
	-v $user/unity/fw-gears/${GEAR}/run.py:/flywheel/v0/run.py\
	-v $user/unity/fw-gears/${GEAR}/${LOG}/input:/flywheel/v0/input\
	-v $user/unity/fw-gears/${GEAR}/${LOG}/output:/flywheel/v0/output\
	-v $user/unity/fw-gears/${GEAR}/${LOG}/work:/flywheel/v0/work\
	-v $user/unity/fw-gears/${GEAR}/${LOG}/config.json:/flywheel/v0/config.json\
	$IMAGE
