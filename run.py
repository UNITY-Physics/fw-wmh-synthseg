#!/usr/bin/env python
"""The run script."""
import logging
import os
import sys

# import flywheel functions
from flywheel_gear_toolkit import GearToolkitContext
from utils.command_line import exec_command
from utils.parser import parse_config
from shared.utils.curate_output import demo
from utils.join_data import housekeeping


# Add top-level package directory to sys.path
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))
# Verify sys.path
print("sys.path:", sys.path)

num_threads = os.environ.get('NTHREADS', '1')

# The gear is split up into 2 main components. The run.py file which is executed
# when the container runs. The run.py file then imports the rest of the gear as a
# module.

log = logging.getLogger(__name__)

def main(context: GearToolkitContext) -> None:
    # """Parses config and runs."""
    # subject_label, session_label, input_label, age = parse_config(context)
        # Add demographic data to the output
    print("concatenating demographics...")
    demographics = demo(context)

    # To get only the value and remove the index, you can access the specific value within the Series. The easiest way is to use the .iloc[0] or .item() method
    age = int(demographics['age'].iloc[0])
    subject_label = demographics['subject'].iloc[0]
    session_label = demographics['session'].iloc[0]

    # Print parsed values for debugging
    print(f"Subject Label: {subject_label}")
    print(f"Session Label: {session_label}")
    print(f"Age: {age} months")

    if context.config.get("age") is not None:
        demographics['age'] = context.config.get("age")
        demographics['age_source'] = 'user_input'
        print(f"Using user input age from config: {age} months")

    print("running main.sh...")
    command = "/flywheel/v0/app/main.sh"
    # Add the input path and age to the command
    command = f"{command} {subject_label} \"{session_label}\" {age} {num_threads}"
    exec_command(command,shell=True,cont_output=True)

    # housekeeping(demographics)

# Only execute if file is run as main, not when imported by another module
if __name__ == "__main__":  # pragma: no cover
    # Get access to gear config, inputs, and sdk client if enabled.
    with GearToolkitContext() as gear_context:

        # Initialize logging, set logging level based on `debug` configuration
        # key in gear config.
        gear_context.init_logging()

        # Pass the gear context into main function defined above.
        main(gear_context)
