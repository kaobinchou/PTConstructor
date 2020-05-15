import sys
import fileinput
#from optparse import OptionParser
import argparse
from pyPEG import parse
from iec_grammar import *
from buildPT import *
import re
#from test import test
#import test
r = re.compile

def print_ast(ast,n):
    str_o = ""
    for i in range(n):
        str_o = str_o + "    "
    if type(ast) == type([]):
        for e in ast:
            print_ast(e, n)
    elif type(ast) == type(()):
        print(str_o + ast[0])
        print_ast(ast[1], n+1)
    elif type(ast) == type(""):
        print(str_o + ast)

optParser = argparse.ArgumentParser(description='State Progress Table Constructor.')
optParser.add_argument('inputFile', help="Source PLC code (structure text only) as input file")
optParser.add_argument("-o", "--output", dest="outputFile", type=argparse.FileType('w'), default=sys.stdout, help="place generated PT in file")
#optParser.add_option("--version", action="callback", callback=printInfo, help="show version info")
args = optParser.parse_args()

comment = r(r"(\(\*.*?\*\))|({.*?})", re.S)
def iec(): return iec_source,

pragma = r(r"\s*\(\*\s*\@(\w+)\s*:=\s*'(.*?)'\s*\*\)\s*")
empty = r(r"^\s*$")

try:
    files = fileinput.input(args.inputFile)

    ast = parse(iec, files, True, comment)
    #t = test()
    #print(t.print_())
    #test.print_()
    #print(ast)
    print_ast(ast, 0)
    #varl, l = buildPT(ast, [], [])
    #result = [varl]
    #result.extend(l)
    #for i in result:
    #    args.outputFile.write(','.join(map(str, i))+'\n')

except KeyboardInterrupt:
    sys.stderr.write("\n")
    sys.exit(1)
except:
    me, parm, tb = sys.exc_info()
    sys.stderr.write(str(parm) + "\n")
    sys.exit(5)
