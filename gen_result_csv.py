#!/usr/bin/python
"""
make a csv from TA result,cell-cgi, and mapinfo csv
by: hugh.wang@ericsson.com
ver: 0.0.1 20/04/2015
"""
def make_bingroup():
    bingroup = {}
    import string
    ascii = string.ascii_uppercase
    num = 0
    for c in ascii:
        bingroup_k = "A"+c
        if num < 1000:
            bingroup_v = str(num)+"-->"+str(num+ 1000)
            num += 1000
        else:
            bingroup_v = str(num)+"-->"+str(num+ 500)
            bingroup[bingroup_k] = bingroup_v
            num += 500
        bingroup[bingroup_k] = bingroup_v

    for c in ascii:
        bingroup_k = "B"+c
        if c >= "D":
            if num < 25000:
                bingroup_v = str(num)+"-->"+str(num+ 5000)
                num += 5000
            else:
                bingroup_v = str(num)+"-->UPWARDS"
                bingroup[bingroup_k] = bingroup_v
                break
        else:
            bingroup_v = str(num)+"-->"+str(num+ 500)
            num += 500
        bingroup[bingroup_k] = bingroup_v
    return bingroup

def enb_handling(enb_file):
    with open(enb_file,'rb') as in_f:
        for line in in_f:
            line_sep = line.split()
            cgi = line_sep[0]
            ue_range = line_sep[1].split("_")[0]
            ue_counts = line_sep[2]
            try:
                cgis[cgi][ue_range] = ue_counts
            except:
                cgis[cgi] = {ue_range:ue_counts}

def fill_cgis(cgis,full_lst):
    for cgi in cgis:
        for key in full_lst:
            if key not in cgis[cgi].keys():
                cgis[cgi][key] = 0

#generate cell cgi relations
file_dir = '/home/hugh/tmp/TA_14042015/'
file_name = file_dir + "/" + "result_get_cgis.txt"
cgi_cell = {}
with open(file_name,'rb') as f:
    for line in f:
        line_sep = line.split()
        cell = line_sep[1]
        cgi = line_sep[2] + "/" + line_sep[3]
        cgi_cell[cgi] = cell

bingroup = make_bingroup()
full_lst = sorted(bingroup.keys())
#make a enb file
#{enb:{cgi:{ue_range:ue_count...}...}...}
enbs = {}
import os
file_dir = '/home/hugh/tmp/TA_14042015/TA_Results_14042015'
for file_name in os.listdir(file_dir):
    if file_name.endswith(".txt"):
        enb_file = file_dir + "/" + file_name
        if os.stat(enb_file).st_size == 0:
            continue
        cgis = {}
        enb = file_name.split(".")[0]
        enb_handling(enb_file)
        fill_cgis(cgis,full_lst)
        enbs[enb] = cgis
import csv
def get_mapinfo(file_name):
    with open(file_name, 'rb') as f:
        reader = csv.DictReader(f)
        for row in reader:
            cell = row['CELL']
            cells[cell] = {}
            cells[cell]['ANTENNA_DIR'] = row['ANTENNA_DIR']
            cells[cell]['ANTENNA_NAME'] = row['ANTENNA_NAME']
            cells[cell]['RET_tilt'] = row['RET_tilt']
            cells[cell]['RET_maxTilt'] = row['RET_maxTilt']
            cells[cell]['RET_SourceCell'] = row['RET_SourceCell']

cells = {}
file_dir = '/home/hugh/tmp/TA_14042015'
file_name = file_dir + "/" + 'CELLS_200m_LTE800.csv'
get_mapinfo(file_name)
file_name = file_dir + "/" + 'CELLS_200m_LTE1800.csv'
get_mapinfo(file_name)

out_file = file_dir + "/" + "out_result.csv"
with open(out_file,"wb") as out_f:
    out_f.write("Site,Cell,CGI,UE_range,UE_Count,RET_tilt,RET_maxTilt,RET_SourceCell,ANTENNA_DIR,ANTENNA_NAME"+"\n")
    for enb in sorted(enbs.keys()):
        for cgi in sorted(enbs[enb].keys()):
            for ue_range in sorted(enbs[enb][cgi].keys()):
                    out_f.write(enb + "," + \
                                cgi_cell[cgi] + "," + \
                                cgi + "," + \
                                ue_range+"_"+bingroup[ue_range] + "," + \
                                str(enbs[enb][cgi][ue_range]) + "," + \
                                cells[cgi_cell[cgi]]['RET_tilt'] + "," + \
                                cells[cgi_cell[cgi]]['RET_maxTilt'] + "," + \
                                cells[cgi_cell[cgi]]['RET_SourceCell'] + "," + \
                                cells[cgi_cell[cgi]]['ANTENNA_DIR'] + "," + \
                                cells[cgi_cell[cgi]]['ANTENNA_NAME'] + "\n")
                                
