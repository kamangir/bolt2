import argparse

from .. import version
from .utils import *

app_name = "bolt2.bootstrap"


parser = argparse.ArgumentParser(app_name)
parser.add_argument("task", type=str, help="validate")
args = parser.parse_args()

success = False
if args.task == "validate":
    success = validate()
else:
    logger.error('{}: unknown task "{}".'.format(app_name, args.task))

if not success:
    logger.error("{}.{} failed.".format(app_name, args.task))
