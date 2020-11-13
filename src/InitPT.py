prog_name = ""
#parse_res = {}
#var_value = {}
#var_type = {}
var_list = []
execute_string = ""
cycle_time = ""

def variable_name(pyAST): return pyAST[0]
def integer_literal(pyAST): return pyAST[0]
def real_literal(pyAST): return pyAST[0]

def milliseconds(pyAST):
    for e in pyAST:
        if e[0] == 'integer': return e[1]

def duration(pyAST):
    for e in pyAST:
        if e[0] == 'milliseconds': return "\'" + milliseconds(e[1]) + " ms\'"

def time_literal(pyAST):
    for e in pyAST:
        if e[0] == 'duration': return duration(e[1])

def bit_string_type_name(pyAST): return pyAST[0][0]

def field_selector(pyAST):
    return variable_name(pyAST[0][1])

def multi_element_variable(pyAST):
    var = variable_name(pyAST[0][1])
    keys = field_selector(pyAST[1][1])
    return var + "[\'" + keys + "\']"

def param_assignment(pyAST):
    #print(pyAST)
    ret = ""
    for e in pyAST:
        if e[0] == 'expression':
            if ret == "":
                ret += "'" + expression(e[1]) + "'"
            else:
                ret += "='" + expression(e[1]) + "'"
        elif e[0] == 'variable_name':
            if ret == "":
                ret += variable_name(e[1])
            else:
                ret += "='" + variable_name(e[1]) + "'"
    return ret

def function_call(pyAST):
    fn_name = ""
    params = ""
    for e in pyAST:
        if e[0] == 'derived_function_name': fn_name = e[1][0]
        elif e[0] == 'param_assignment':
            param = param_assignment(e[1])
            if params == "":
                params += param
            else:
                params += ", " + param
    return fn_name + "(" + params + ")"

def expression(pyAST):
    ret = ""
    for e in pyAST:
        if e[0] == 'variable_name': ret = ret + variable_name(e[1])
        elif e[0] == 'integer_literal': ret = ret + integer_literal(e[1])
        elif e[0] == 'real_literal': ret = ret + real_literal(e[1])
        elif e[0] == 'time_literal': ret = ret + time_literal(e[1])
        elif e[0] == 'logical_not': ret = ret + "not "
        elif e[0] == 'logical_and': ret = ret + " and "
        elif e[0] == 'logical_or': ret = ret + " or "
        elif e[0] == 'expression':
            ret = ret + "(" + expression(e[1]) + ")"
        elif e[0] == 'multi_element_variable':
            ret += multi_element_variable(e[1])
        elif e[0] == 'function_call': ret = ret + function_call(e[1])
        else:
            print(e[0])
    return ret

def simple_type_name(pyAST): return pyAST[0]

def simple_spec_init(pyAST):
    var_dt = {}
    if pyAST[0][0] == 'bit_string_type_name':
        var_dt['var_type'] = bit_string_type_name(pyAST[0][1])
        if var_dt['var_type'] == 'type_bool': var_dt['default'] = 'False'
        elif var_dt['var_type'] == 'type_byte': var_dt['default'] = '0'
    elif pyAST[0][0] == 'integer_type_name':
        var_dt['var_type'] = 'type_int'
        var_dt['default'] = '0'
    elif pyAST[0][0] == 'real_type_name':
        var_dt['var_type'] = 'type_real'
        var_dt['default'] = '0.0'
    elif pyAST[0][0] == 'simple_type_name':
        var_dt['var_type'] = simple_type_name(pyAST[0][1])
        if var_dt['var_type'] == 'TON':
            var_dt['default'] = "{\'Q\':False}"
        
    if len(pyAST) > 1:
        default_value = expression(pyAST[1][1])
        if var_dt['var_type'] == 'type_bool':
            var_dt['default'] = str(default_value.lower() == "true")
        elif var_dt['var_type'] in ['type_byte', 'type_int']:
            var_dt['default'] = default_value
        elif var_dt['var_type'] == 'type_real':
            var_dt['default'] = default_value
    
    return var_dt

def var_init_decl(pyAST):
    var_dt = {}
    var_dt['var_name'] = variable_name(pyAST[0][1])
    #parse_res[var_name] = []
    #var_value[var_name] = None
    var_dt.update(simple_spec_init(pyAST[1][1]))
    return var_dt

def inputVar(pyAST):
    for e in pyAST:
        #print(e[0])
        var_dt = var_init_decl(e[1])
        var_dt['is_input'] = True
        var_list.append(var_dt)
        #parse_res[var_name].append(var_value[var_name])

def input_declarations(pyAST): return inputVar(pyAST)
def input_output_declaration(pyAST): return inputVar(pyAST)

def Var(pyAST):
    for e in pyAST:
        var_dt = var_init_decl(e[1])
        var_dt['is_input'] = False
        var_list.append(var_dt)

def output_declarations(pyAST): return Var(pyAST)
def var_declarations(pyAST): return Var(pyAST)

def setVar(pyAST, vlist):
    l = []
    for j in range(len(vlist)):
        l.append('X')
    l[vlist.index(pyAST)] = 'True'
    return l

def if_statement(pyAST):
    ret = "if " + expression(pyAST[0][1]) + ":\n" 
    for l in statement_list(pyAST[1][1]).split('\n'):
        if l != '':
            ret += "    " + l + "\n"
    return ret

def assignment_statement(pyAST):
    ret = variable_name(pyAST[0][1]) + " = " + expression(pyAST[1][1]) + "\n"
    return ret

def fb_invocation(pyAST):
    params = ""
    for e in pyAST:
        #print(e[0])
        if e[0] == 'fb_name':
            fb_name = e[1][0]
        elif e[0] == 'param_assignment':
            param = param_assignment(e[1])
            #print(param)
            params += ", " + param
    return "PLC_timer(\'" + fb_name + "\'" + params + ")\n"


def statement_list(pyAST):
    ret = ""
    for e in pyAST:
        #print(e[0])
        if e[0] == 'assignment_statement':
            ret += assignment_statement(e[1])
        elif e[0] == 'if_statement':
            ret += if_statement(e[1])
        elif e[0] == 'fb_invocation':
            ret += fb_invocation(e[1])
    #print(ret)
    return ret

def function_block_body(pyAST):
    global execute_string
    for e in pyAST:
        #print(e[0])
        if e[0] == 'statement_list':
            execute_string += statement_list(e[1]) 

def program_declaration(pyAST):
    for e in pyAST:
        #print(e[0])
        if e[0] == 'program_type_name': prog_name = e[1][0]
        elif e[0] == 'input_declarations': input_declarations(e[1])
        elif e[0] == 'input_output_declarations': input_output_declarations(e[1])
        elif e[0] == 'output_declarations': output_declarations(e[1])
        elif e[0] == 'var_declarations': var_declarations(e[1])
        elif e[0] == 'function_block_body': function_block_body(e[1])

def configuration_declaration(pyAST):
    if isinstance(pyAST, str): return
    elif isinstance(pyAST, tuple):
        global cycle_time
        if pyAST[0] == 'time_literal':
            cycle_time = time_literal(pyAST[1])
        else: configuration_declaration(pyAST[1])
    else:
        for e in pyAST: configuration_declaration(e)


def ParseST(pyAST):
    if isinstance(pyAST, str): return
    if isinstance(pyAST, tuple):
        #print(pyAST[0])
        if pyAST[0] == 'program_declaration': program_declaration(pyAST[1])
        elif pyAST[0] == 'configuration_declaration': 
            configuration_declaration(pyAST[1])
        else:
            ParseST(pyAST[1])
    else:
        for e in pyAST:
            ParseST(e)


def InitPT(pyAST):
    ParseST(pyAST)
    return execute_string,cycle_time
