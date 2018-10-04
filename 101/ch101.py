import sys

def range(start,finish,type,comment):
    print 'range{start $%04x;end $%04x; type %s;}; #%s'%(0x8000+start,
                                                         0x8000+finish,
                                                         type,
                                                         comment)
    
def main():
    with open('CH101','rb') as f: data=[ord(x) for x in f.read()]

    # Find inline strings
    offset=0
    while offset<len(data):
        def jsr(*addrs):
            for addr in addrs:
                if (data[offset+0]==0x20 and
                    data[offset+1]==(addr&0xff) and
                    data[offset+2]==((addr>>8)&0xff)):
                    return True
            return False

        if jsr(0xa933,0xa930):
            # stops 1 byte before next -ve byte.
            offset+=3
            start=offset
            while (offset<len(data) and
                   data[offset]!=0 and
                   (data[offset]&0x80)==0):
                offset+=1

            if data[offset]==0: offset+=1
            range(start,offset-1,'texttable','auto call to a933')
        elif jsr(0xa90d,0xa8f2,0xa905):
            # 0-terminated
            offset+=3
            start=offset
            while offset<len(data):
                if data[offset]==0:
                    offset+=1
                    break
                if offset>start and data[offset]>=128: break
                offset+=1

            range(start,offset-1,'texttable','auto call to a90d')
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

    do_command_table(0x905e,0x90fa,'_command') # DFS/CHAL
    do_command_table(0x90fd,0x9142,'_command') # UTILS
    do_command_table(0x9145,0x9159,'_help')    # help subjects

if __name__=='__main__': main()
