# A simple service for testing purposes
from nanoservice import Service


def ping():
    return 'pong'


def add(x, y):
    return x + y


addr = 'ipc:///tmp/exns.sock'
s = Service(addr)
s.register('ping', ping)
s.register('add', add)

print('Starting serice on addres {}'.format(addr))
s.start()
