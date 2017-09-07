#!/usr/bin/env python

import os,sys
import fastq
import time

def getContentOf(target_list, seq):
  # add a 1 for each nucleotide in target_list
  target_count = sum(1 for x in seq if x in target_list)
  return float(target_count)
  
def qual_stat(qstr):
    q20 = 0
    q30 = 0
    for q in qstr:
        qual = ord(q) - 33
        if qual >= 30:
            q30 += 1
            q20 += 1
        elif qual >= 20:
            q20 += 1
    return q20, q30

def stat(filename):
    reader = fastq.Reader(filename)
    total_count = 0
    q20_count = 0
    q30_count = 0
    min_len = 150
    max_len = 150
    read_num = 0
    Count_GC = 0
    while True:
        read = reader.nextRead()
        if read == None:
            break
        total_count += len(read[3])
        if min_len > len(read[3]):
		min_len = len(read[3])
	if max_len < len(read[3]):
                max_len = len(read[3])
	read_num = read_num + 1
        q20, q30 = qual_stat(read[3])
        q20_count += q20
        q30_count += q30
        Count_GC += getContentOf(['G', 'C', 'g', 'c'], read[1])


    #print "total bases","\t",total_count
    #print "q20 bases","\t",q20_count
    #print "q30 bases","\t",q30_count
    #print "q20 percents","\t",100 * float(q20_count)/float(total_count)
    #print "q30 percents","\t",100 * float(q30_count)/float(total_count)
    #print "Read Length Distributon","\t",min_len,  max_len
    #print "Mean Read Length","\t",float(total_count)/float(read_num)
    print "Total bases\tQ20 bases\tQ30 bases\tQ20 percents\tq30 percents\tGC Cntent\tRead Length Distributon\tMean Read Length"
    print total_count,"\t",q20_count,"\t",q30_count,"\t",100 * float(q20_count)/float(total_count),"\t",100 * float(q30_count)/float(total_count),"\t",100 * float(Count_GC)/float(total_count),"\t",min_len,"-",max_len,"\t",float(total_count)/float(read_num)

def main():
    if len(sys.argv) < 2:
        print("usage: python q30.py <fastq_file>")
        sys.exit(1)
    stat(sys.argv[1])

if __name__ == "__main__":
    time1 = time.time()
    main()
    time2 = time.time()
    #print('Time used: ' + str(time2-time1))
