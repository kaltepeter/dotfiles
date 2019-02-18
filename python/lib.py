COLORS = dict([
    ('CLEANUP', '\033[94m'),
    ('CREATE', '\033[92m'),
    ('INSTALL', '\033[92m'),
    ('SKIP', '\033[93m'),
    ('FAIL', '\033[31m'),
    ('DEFAULT', '\033[39m'),
    ('UNDEFINED', '\033[37m'),
    ('STATUS', '\033[36m')
  ])

def typed_message(message, message_type=None):
  color = COLORS.setdefault(message_type, COLORS['UNDEFINED'])
  tagged_type = "%s[%s] ..." % (color, message_type)
  print("%26s %s %s" % (tagged_type, COLORS['DEFAULT'], message))
