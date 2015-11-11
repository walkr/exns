# A simple service for testing purposes
from nanoservice import Service
from nanoservice.encoder import JSONEncoder


def ping():
    return 'pong'


def uppercase(string):
    return string.upper()


addr = 'ipc:///tmp/string-test-service.sock'
s = Service(addr, encoder=JSONEncoder())
s.register('ping', ping)
s.register('uppercase', uppercase)

print('Starting serice on address {}'.format(addr))
s.start()
