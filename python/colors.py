#!/usr/bin/env python3
from lib import typed_message

typed_message('Yo', 'SKIP')
typed_message('Yo', 'SKIP')

typed_message('Yo', 'SKIP')

typed_message('Yo')
typed_message('Yo', '*****')
typed_message('Yo', 'NOPE')

