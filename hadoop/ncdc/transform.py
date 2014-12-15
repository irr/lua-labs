import sys
for line in sys.stdin:
    (year, temp) = line.strip().split()
    if (temp != "9999"):
        print "%s\t%s" % (year, temp)
