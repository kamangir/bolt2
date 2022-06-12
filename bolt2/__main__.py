import argparse

from . import *


from bolt import logging
import logging

logger = logging.getLogger(__name__)


parser = argparse.ArgumentParser(
    description="bolt2-{:.2f}".format(version))
parser.add_argument("task", type=str, help="validate")
args = parser.parse_args()

success = False
if args.task == "validate":
    success = validate()
else:
    logger.error('bolt2: unknown task "{}".'.format(args.task))

if not success:
    logger.error("bolt2.{} failed.".format(args.task))
