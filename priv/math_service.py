# A simple service for testing purposes
from nanoservice import Responder


def ping():
    return 'pong'


def add(x, y):
    return x + y


addr = 'ipc:///tmp/math-test-service.sock'
s = Responder(addr)
s.register('ping', ping)
s.register('add', add)

print('Starting serice on address {}'.format(addr))
s.start()
