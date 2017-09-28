#!/usr/bin/python
from string import Template
import os
import json

def read_file_2_string(f):
    with open(f) as file: 
        return file.read()

def write_file_2_string(f,s):
    with open(f,"w+") as file: 
        return file.write(s)

g_group_define_file = "group.json"
g_group_my_cnf_file = "tpl_my.cnf"
g_group_init_sh_file = "tpl_init.sh"

#begin tpl make
cnf_tpl_instance = Template(read_file_2_string(g_group_my_cnf_file))
init_sh_tpl_instance = Template(read_file_2_string(g_group_init_sh_file))

def_str = read_file_2_string(g_group_define_file)
def_info = json.loads(def_str)
seed_str = ""
def_dict = {}
for srv in def_info["servers"]:
    idx = "{}:{}".format(srv["mysql_server_bind_ip"],srv["mysql_mgr_port"])
    if seed_str is not "":
        seed_str = seed_str + "," + idx
    else:
        seed_str = idx

    srv_dict = {}
    srv_dict["mysql_port"]=srv["mysql_port"]
    srv_dict["mysql_sock"]=srv['mysql_sock']
    srv_dict["mysql_base_dir"]=srv['mysql_base_dir']
    srv_dict["mysql_data_dir"]=srv['mysql_data_dir']
    srv_dict["mysql_server_id"]=srv['mysql_server_id']
    srv_dict["mysql_server_bind_ip"]=srv['mysql_server_bind_ip']
    srv_dict["mysql_group_local_address"]=idx
    srv_dict["mysql_group_name"]=def_info["mysql_group_name"]
    srv_dict["mysql_group_seed"]=''

    def_dict[idx] = srv_dict

# fill seed str
for k in def_dict.keys():
    file_name = "my-"+k.replace(":","-").replace(".","-") + ".cnf"
    def_dict[k]["mysql_group_seed"] = seed_str
    def_dict[k]["mysql_cnf"] = file_name

    if not os.path.exists("dist/"+k): os.mkdir("dist/"+k)

    rs = cnf_tpl_instance.substitute(def_dict[k])
    write_file_2_string("dist/"+k + "/" + file_name,rs)

    file_name = "dist/"+k+"/init.sh"
    rs = init_sh_tpl_instance.substitute(def_dict[k])
    write_file_2_string(file_name,rs)

