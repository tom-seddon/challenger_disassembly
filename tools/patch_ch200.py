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

    # Adjust version number.
    for addr in [0x8016,0xae74]:
        o=addr-0x8000
        data[o+0]='2'
        data[o+1]='0'
        data[o+2]='0'
        data[o+3]='P'

    # Reset all drive mappings on startup.
    data[0x4e]=0x7e
    data[0x4f]=0xab

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
