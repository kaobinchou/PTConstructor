import copy
Input_bool = {}
Input_not_bool = {}
not_Input = {}
exec_str = ""
cycle_time = 0
Timer = 0
var = {} #The variable values at the beginning of a cycle
var_t = {} #The variable values after current cycle

def DIV(EN, IN1, IN2, ENO):
    #print(type(IN2))
    if eval(EN):
        exec(ENO + "=True")
        #if type(IN1)!=type(""): IN1=str(IN1)
        #if type(IN2)!=type(""): IN2=str(IN2)
        return eval("float(" + IN1 + ")/float(" + IN2 + ")")
    else:
        exec(ENO + "=False")

def MUL(EN, IN1, IN2, ENO):
    if eval(EN):
        exec(ENO + "=True")
        #if type(IN1)!=type(""): IN1=str(IN1)
        #if type(IN2)!=type(""): IN2=str(IN2)
        return eval("float(" + IN1 + ")*float(" + IN2 + ")")
    else:
        exec(ENO + "=False")

def MOVE(EN, IN, ENO):
    if eval(EN):
        exec(ENO + "=True")
        #if type(IN)!=type(""): IN=str(IN)
        return eval(IN)
    else:
        exec(ENO + "=False")

def parse_time(time_str):
    t = time_str.replace("'","").split()
    if t[1] == 'ms':
        return int(t[0])/1000
    elif t[1] == 's':
        return int(t[0])
    else: return 0

def PLC_timer(name, IN, PT):
    if var[IN]:
        exec(name + "[\'Q\'] = True")
        Timer = parse_time(PT)
    else:
        exec(name + "[\'Q\'] = False")
        Timer = 0

def init_var():
    for k,v in var.items():
        globals()[k] = v

def store_var():
    #res = "for k,v in var.items():\n"
    for k,v in var.items():
        #print(k)
        exec("var_t['" + k + "']=" + k)

def compare_var():
    #res = "for k,v in var.items():\n"
    is_altered = False
    for k,v in var.items():
        print(k + ":" + str(v))
        exec("if var[" + k + "]!=" + k + ": is_altered=True")
        if is_altered: break
    return is_altered

def execute_cycle():
    #var_new = copy.deepcopy(var)
    is_altered = False
    lines = exec_str.split('\n')
    #print(exec_str)
    i = 0
    while i < len(lines):
        #print(lines[i])
        exec_s = lines[i]
        #print(i)
        if lines[i].startswith('if '):
            while(lines[i+1].startswith('    ')):
                exec_s += "\n" + lines[i+1]
                i += 1
        #print(exec_s)
        if exec_s != '':
            #print("try")
            exec(exec_s)
            #print("ssucs")
            for k,v in var.items():
                #print(k + ":" + v)
                if eval("var['" + k + "']!=" + k):
                    exec("var_t['" + k + "']=" + k + "\n" + k + "=var['" + k + "']")
                    is_altered=True
                #print(is_altered)
        i += 1
    #print(type(is_altered))
    return is_altered

def exec_Input(res):
    global var, var_t
    init_var()
    is_altered = execute_cycle()
    #print(is_altered)
    while is_altered:
        store_var()
        #print(var)
        res_s = str(max(Timer,cycle_time))
        #print(var_t)
        for k,v in var_t.items(): res_s += "," + v
        #print("test")
        res.append(res_s)
        print(res)
        var = copy.deepcopy(var_t)
        #init_var()
        is_altered = execute_cycle()
        #print(is_altered)
    #print(res)
    return res

def execute_by_Input(res):
    #res = []
    #var = {}
    global var
    for k,i in Input_bool.items(): # boolean inputs
        var = copy.deepcopy(Input_bool)
        var.update(copy.deepcopy(Input_not_bool))
        var.update(copy.deepcopy(not_Input))
        if k.lower() in ['start','stop']:
            continue
        var[k] = str(var[k]=='False')
        #print(var)
        res = exec_Input(res)

    for k,i in Input_not_bool.items(): # non-boolean inputs
        var = copy.deepcopy(Input_bool)
        var.update(copy.deepcopy(Input_not_bool))
        var.update(copy.deepcopy(not_Input))
        if '.' in var[k]:
            var[k] = str(float(var[k])+1.0)
        else:
            var[k] = str(int(var[k])+1)
        #print(var)
        res = exec_Input(res)

    return res

def buildPT(var_list, exec_string, cycle_t):
    # set cycle time
    global cycle_time
    cycle_time = parse_time(cycle_t)
    # collect all variable name as column name of output file
    var_names = ["Time"]
    var_def = [0]
    # store execute commands
    global exec_str
    exec_str = exec_string
    #print(exec_str)
    for v in var_list:
        var_names.append(v['var_name'])
        var_def.append(v['default'])
        if v['is_input']:
            if v['var_type'] == 'type_bool':
                if v['var_name'].lower()=='start':
                    Input_bool[v['var_name']] = 'True'
                else:
                    Input_bool[v['var_name']] = v['default']
            else:
                Input_not_bool[v['var_name']] = v['default']
        else:
            not_Input[v['var_name']] = v['default']
    res = []
    res.append(var_names)
    res.append(var_def)
    print(res)
    res = execute_by_Input(res)
    return res
