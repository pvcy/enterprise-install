import base64
from Cryptodome.Random import get_random_bytes


print(base64.b64encode(get_random_bytes(32)).decode())
