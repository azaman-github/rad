
source_file="c:/tutorial\python/q_and_a.txt"
out_file="example.dat"
marker_found = False

wfh = open(out_file, "w" )

lno = 0
with  open(source_file, "r")  as  rfh:
    while True:
        #line = rfh.readline().strip("\n")
        try:
            line = rfh.readline()
        except Exception as  e :
            continue
        lno += 1
        if line  == "\n"  :
             #print("Empty line found")
             if marker_found : 
                 wfh.write(line)
                 continue
        
        #if  len(line)  ==  0:
        # continue
        if line  == "":
            #print(lno)
            break
        
        lines = line.strip("\n")

        if lines  == "+Example_Start" :
            marker_found=True
            #print("Marker start found")
            continue

        if lines  == "Example_End"  :
           #print("Marker End found")
           if marker_found : 
                rfh.close()
                wfh.close()
                break
        elif  lines.startswith("=") :
                continue
        elif  lines.startswith("{") :
                continue
        else:
             if marker_found : 
                 wfh.write(lines + "\n")

