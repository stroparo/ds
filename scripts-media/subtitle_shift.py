import fileinput
import re
import time

lines = [ line for line in fileinput.input() ]

# Test:
base = time.mktime(time.strptime('00:01:02', '%H:%M:%S'))
secs = 120
res = time.strftime('%H:%M:%S', time.localtime(base + secs))
print(res)

# TODO
