# A simple service for testing purposes
from nanoservice import Service


def ping():
    return 'pong'


def uppercase(string):
    return string.upper()


addr = 'ipc:///tmp/string-service.sock'
s = Service(addr)
s.register('ping', ping)
s.register('uppercase', uppercase)

print('Starting serice on addres {}'.format(addr))
s.start()
