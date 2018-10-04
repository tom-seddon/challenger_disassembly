import sys

def range(start,finish,type,comment):
    print 'range{start $%04x;end $%04x; type %s;}; #%s'%(0x8000+start,
                                                         0x8000+finish,
                                                         type,
                                                         comment)

def main():
    with open('CH200.rom','rb') as f: data=[ord(x) for x in f.read()]

    # Find inline strings.
    offset=0
    while offset<len(data):
        def jsr(addr):
            return (data[offset+0]==0x20 and
                    data[offset+1]==(addr&0xff) and
                    data[offset+2]==((addr>>8)&0xff))
            
        if jsr(0xa917):
            # 255-terminated.
            offset+=3
            start=offset
            while offset<len(data) and data[offset]!=255: offset+=1
            range(start,offset,'texttable','auto call to a917')
            offset+=1           # skip 255
        elif jsr(0xa8d3) or jsr(0xa8d0):
            # stops 1 byte before next -ve byte.
            offset+=3
            start=offset
            while (offset<len(data) and
                   data[offset]!=0 and
                   (data[offset]&0x80)==0):
                offset+=1

            if data[offset]==0: offset+=1
            range(start,offset-1,'texttable','auto call to a8d3')
        elif (jsr(0xa8a5) or
              jsr(0xa8c2) or
              jsr(0xa89c) or
              jsr(0xa8ad) or
              jsr(0xa892)):
            # +1, then go until next BRK
            offset+=3
            start=offset
            offset+=1           # skip error code
            while offset<len(data) and (data[offset]!=0 and
                                        data[offset]<128):
                offset+=1
            range(start,offset-1,'texttable','auto call to dobrk')
            if data[offset]==0: offset+=1
        else: offset+=1

    # Sort out command table
    labels={}
    
    def do_command_table(start_addr,end_addr,label_suffix):
        offset=start_addr-0x8000
        while offset<end_addr-0x8000:
            text=''

            name_start_offset=offset
            while data[offset]>=32 and data[offset]<127:
                text+=chr(data[offset])
                offset+=1

            range(name_start_offset,offset-1,'texttable','')
            
            range(offset,offset+1,'dbytetable','')
            addr=data[offset+0]<<8|data[offset+1]
            label='%s%s'%(text.lower(),label_suffix)
            if addr in labels:
                print>>sys.stderr,'%s=$%04x and %s=$%04x'%(labels[addr],
                                                           addr,
                                                           label,
                                                           addr)
            else:
                print 'label{addr $%04x;name "%s";};'%(addr,label)
                labels[addr]=label
                
            offset+=2

            range(offset,offset,'bytetable','')
            offset+=1

    do_command_table(0x90b4,0x9145,'_command') # DFS/CHAL
    do_command_table(0x9148,0x918e,'_command') # UTILS
    do_command_table(0x9190,0x91a5,'_help') # help subjects

    # OSWORD 7f table
    offset=0xb8ad-0x8000
    while data[offset]!=0:
        range(offset,offset,'bytetable','') # FDC command
        range(offset+1,offset+2,'rtstable','') # routine address
        offset+=3
    range(offset,offset,'bytetable','') # terminator is data too

if __name__=='__main__': main()
