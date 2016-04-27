# A simple service for testing purposes
from nanoservice import Responder
from nanoservice.encoder import JSONEncoder


def ping():
    return 'pong'


def uppercase(string):
    return string.upper()


addr = 'ipc:///tmp/string-test-service.sock'
s = Responder(addr, encoder=JSONEncoder())
s.register('ping', ping)
s.register('uppercase', uppercase)

print('Starting serice on address {}'.format(addr))
s.start()
