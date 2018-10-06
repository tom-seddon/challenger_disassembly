#!/usr/bin/python
import os,os.path,argparse

##########################################################################
##########################################################################
#
# Patch Challenger 2.00 ROM for standalone BBC B use.
#
##########################################################################
##########################################################################

def main(options):
    with open(options.input_path,'rb') as f: data=[ord(x) for x in f.read()]

    def poke(addr,x): data[addr-0x8000]=x
    def pokestr(addr,s):
        for i in range(len(s)): data[addr+i-0x8000]=ord(s[i])

    # Adjust version number.
    pokestr(0x8016,'200A')
    pokestr(0xae74,'200A')
    
    # Reset all drive mappings on startup.
    poke(0x804e,0x7e)
    poke(0x804f,0xab)

    # Make *CAT look less of a mess.
    pokestr(0x8fbb,'Directory :'+chr(0xea))
    pokestr(0x8eb0,'Drive '+chr(0xea))
    poke(0x8f3f,6)
    pokestr(0x8ef8,'('+chr(0xea))

    # Fix up *STAT, which now looks a mess.
    poke(0x9065,0x0a)

    # Create output data.
    for i in range(len(data)):
        if isinstance(data[i],str): data[i]=ord(data[i])

    data=''.join([chr(x) for x in data])

    if options.output_path is not None:
        with open(options.output_path,'wb') as f: f.write(data)

        if options.inf:
            with open(options.output_path+'.inf','wb'): pass

##########################################################################
##########################################################################

if __name__=='__main__':
    parser=argparse.ArgumentParser(description='patch Challenger 2.00 ROM')

    parser.add_argument('-o',dest='output_path',metavar='FILE',help='write patched CH200 ROM to %(metavar)s')

    parser.add_argument('--inf',action='store_true',help='if -o provided, write 0-byte .inf file too')

    parser.add_argument('input_path',metavar='FILE',help='read CH200 ROM from %(metavar)s')

    main(parser.parse_args())
