import sys

def infrange(start,finish,type,comment):
    print 'range{start $%04x;end $%04x; type %s;}; #%s'%(0x8000+start,
                                                         0x8000+finish,
                                                         type,
                                                         comment)

def main():
    with open('CHADFS.rom','rb') as f: data=[ord(x) for x in f.read()]

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

        if jsr(0x8346,0x834d,0x834f,0x8329):
            # 0-terminated
            offset+=3
            start=offset
            while offset<len(data):
                if data[offset]==0:
                    offset+=1
                    break
                offset+=1
            infrange(start,offset-1,'texttable','auto')
        elif jsr(0x9186):
            offset+=3
            start=offset
            while offset<len(data):
                if data[offset]>=0x80:
                    offset+=1
                    break
                offset+=1
            infrange(start,offset-1,'texttable','auto')
        else: offset+=1

    # extended vectors table
    for i in range(8):
        offset=0x9b70+i*3-0x8000
        infrange(offset,offset+1,'addrtable','')
        infrange(offset+2,offset+2,'bytetable','')

    # command table
    labels={}
    def do_command_table(start_addr,end_addr,label_suffix):
        offset=start_addr-0x8000
        while offset<end_addr-0x8000:
            text=''

            name_start_offset=offset
            while data[offset]>=32 and data[offset]<127:
                text+=chr(data[offset])
                offset+=1

            infrange(name_start_offset,offset-1,'texttable','')
            
            infrange(offset,offset+1,'dbytetable','')
            addr=data[offset+0]<<8|data[offset+1]
            label='%s%s'%(text.lower(),label_suffix)
            if addr in labels:
                print>>sys.stderr,'%s=$%04x and %s=$%04x'%(labels[addr],
                                                           addr,
                                                           label,
                                                           addr)
            else:
                print 'label{addr $%04x;name "%s";};'%(addr+1,label)
                labels[addr]=label
                
            offset+=2

            infrange(offset,offset,'bytetable','')
            offset+=1

    do_command_table(0x9df2,0x9e84,'_command')
    

if __name__=='__main__': main()
