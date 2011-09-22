import epics

motors = [epics.Motor('13XRM:m%i' % (i+1)) for i in range(6)]

print 'Motor Name       EGU   OFFSET   DIR'
print '-----------------------------------'

for m in motors:
    print "%10s  %8s  %7s  %3s" % (m.DESC, m.EGU, str(m.OFF), m.get('DIR', as_string=True))



