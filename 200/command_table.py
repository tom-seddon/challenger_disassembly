def range(start,finish,type,comment):
    print 'range{start $%04x;end $%04x; type %s;}; #%s'%(0x8000+start,
                                                         0x8000+finish,
                                                         type,
                                                         comment)

def main():
    with open('CH200.rom','rb') as f: data=[ord(x) for x in f.read()]

    # Add stuff for command table.
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
            while offset<len(data) and (data[offset]&0x80)==0: offset+=1
            range(start,offset-1,'texttable','auto call to a8d3')
        elif (jsr(0xa8a5) or
              jsr(0xa8c2) or
              jsr(0xa89c) or
              jsr(0xa8ad) or
              (jsr(0xa892) and offset!=0xbcaf-0x8000)):
            # +1, then go until next BRK
            offset+=3
            start=offset
            while offset<len(data) and data[offset]!=0: offset+=1
            range(start,offset,'texttable','auto call to dobrk')
            offset+=1           # skip 0
        else: offset+=1

if __name__=='__main__': main()
