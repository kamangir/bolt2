from bolt import logging
import logging

logger = logging.getLogger(__name__)


def validate():
    import tensorflow as tf

    logger.info("TensorFlow: {}".format(tf.__version__))
    logger.info(
        "{} GPU(s) available".format(len(tf.config.list_physical_devices("GPU")))
    )

    return True
