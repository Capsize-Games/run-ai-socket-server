import base64
import json
import io
import numpy as np
import settings
import messagecodes as codes
from PIL import Image
# from database import DBConnection
from runner import SDRunner
from logger import logger
from exceptions import FailedToSendError
from simple_enqueue_socket_server import SimpleEnqueueSocketServer


class StableDiffusionRequestQueueWorker(SimpleEnqueueSocketServer):
    """
    A socket server that listens for requests and enqueues them to a queue
    """
    sdrunner = None

    def callback(self, data):
        """
        Handle a stable diffusion request message
        :return: None
        """
        reqtype = None
        try:
            # convert ascii to json
            data = json.loads(data.decode("ascii"))
            # get reqtype based on action in data
            self.image_size = data.get("W", None)
            reqtype = data["action"]
        except UnicodeDecodeError as err:
            logger.error(f"something went wrong with a request from the client")
            logger.error(f"UnicodeDecodeError: {err}")
            return
        except json.decoder.JSONDecodeError as err:
            logger.error(f"Improperly formatted request from client")
            return
        data["reqtype"] = reqtype

        self.reqtype = reqtype
        if reqtype in ["txt2img", "img2img", "inpaint", "outpaint"]:
            self.sdrunner.generator_sample(data, self.handle_image)
            logger.info("Image sample complete")
        elif reqtype == "convert":
            logger.info("Convert CKPT file")
            self.sdrunner.convert(data)
        elif reqtype == "update":
            logger.info("update to latest version")
            self.update_versions()
        else:
            logger.error(f"NO IMAGE RESPONSE for reqtype {reqtype}")

    def handle_image(self, image, options):
        opts = options["options"] if "options" in options else {"pos_x":0, "pos_y": 0}
        message = {
            "image": base64.b64encode(image).decode(),
            "reqtype": options["reqtype"],
            "pos_x": opts["pos_x"],
            "pos_y": opts["pos_y"],
        }
        if message is not None and message != b'':
            try:
                self.message_client(message)
                if not self.soc_connection:
                    raise FailedToSendError()
            except FailedToSendError as ect:
                logger.error("failed to send message")
                self.cancel()
                logger.error(ect)
                self.reset_connection()

    def prep_image(self, response, _options, dtype=np.uint8):
        # logger.info("sending response")
        buffered = io.BytesIO()
        Image.fromarray(response.astype(dtype), 'RGB').save(buffered)
        image = buffered.getvalue()
        return image

    def cancel(self):
        self.sdrunner.cancel()

    def response_queue_worker(self):
        """
        Wait for responses from the stable diffusion runner and send
        them to the client
        """

    def stop(self):
        super().stop()
        self.quit_event.set()

    def init_sd_runner(self):
        """
        Initialize the stable diffusion runner
        return: None
        """
        logger.info("Starting Stable Diffusion Runner")
        self.sdrunner = SDRunner(tqdm_callback=self.tqdm_callback)

    def do_start(self):
        # create a stable diffusion runner service
        self.start_thread(
            target=self.response_queue_worker,
            name="response queue worker"
        )
        sd_runner_thread = self.start_thread(
            target=self.init_sd_runner,
            name="init stable diffusion runner"
        )
        sd_runner_thread.join()

    def tqdm_callback(self, step, total_steps):
        msg = {
            "action": codes.PROGRESS,
            "step": step,
            "total":total_steps,
            "reqtype": self.reqtype
        }
        self.message_client(msg)

    def __init__(self, *args, **kwargs):
        """
        Initialize the worker
        """
        # self.db = DBConnection('database.db', b'key')
        #self.db.insert_txt2img_sample(1, 2, b'sample', 42, 100, 100, 10, 0.5, 'model', 'scheduler')

        self.model_base_path = kwargs.pop("model_base_path", None)
        self.max_client_connections = kwargs.get("max_client_connections", 1)
        self.port = kwargs.get("port", settings.DEFAULT_PORT)
        self.host = kwargs.get("host", settings.DEFAULT_HOST)
        self.do_timeout = kwargs.get("do_timeout", False)
        self.safety_model = kwargs.get("safety_model")
        self.model_version = kwargs.get("model_version")
        self.safety_feature_extractor = kwargs.get("safety_feature_extractor")
        self.safety_model_path = kwargs.get("safety_model_path"),
        self.safety_feature_extractor_path = kwargs.get("safety_feature_extractor_path")
        self.packet_size = kwargs.get("packet_size", settings.PACKET_SIZE)
        self.do_start()
        super().__init__(*args, **kwargs)