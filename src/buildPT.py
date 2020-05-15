prog_name = ""
parse_res = {}
var_value = {}
var_type = {}
execute_list = []
cycle_time = ()

def variable_name(pyAST): return pyAST[0]
def integer_literal(pyAST): return pyAST[0]
def real_literal(pyAST): return pyAST[0]

def milliseconds(pyAST):
    for e in pyAST:
        if e[0] == 'integer': return int(e[1][0])

def duration(pyAST):
    for e in pyAST:
        if e[0] == 'milliseconds': return "ms", milliseconds(e[1])

def time_literal(pyAST):
    for e in pyAST:
        if e[0] == 'duration': return duration(e[1])

def bit_string_type_name(pyAST): return pyAST[0]

def param_assignment(pyAST):
    return variable_name(pyAST[0][1]), expression(pyAST[1][1])

def function_call(pyAST):
    fn_name = ""
    param_list = []
    for e in pyAST:
        if e[0] == 'derived_function_name': fn_name = e[1][0]
        elif e[0] == 'param_assignmemt': param_list.append(param_assignment(e[1]))

def expression(pyAST):
    ret = ""
    for e in pyAST:
        if e[0] == 'variable_name': ret = ret + variable_name(e[1])
        elif e[0] == 'integer_literal': ret = ret + integer_literal(e[1])
        elif e[0] == 'real_literal': ret = ret + real_literal(e[1])
        elif e[0] == 'logical_not': ret = ret + "not "
        elif e[0] == 'logical_and': ret = ret + " and "
        elif e[0] == 'logical_or': ret = ret + " or "
        elif e[0] == 'expression':
            ret = ret + "(" + expression(e[1]) + ")"
        elif e[0] == 'function_call': function_call(e[1])
        else:
            print(e[0])
    return ret

def simple_spec_init(pyAST, var_name):
    if pyAST[0][0] == 'bit_string_type_name':
        var_type[var_name] = bit_string_type_name(pyAST[0][1])
        if var_type[var_name] == 'type_bool': var_value[var_name] = False
        elif var_type[var_name] == 'type_byte': var_value[var_name] = 0
    elif pyAST[0][0] == 'integer_type_name':
        var_type[var_name] = 'type_int'
        var_value[var_name] = 0
    elif pyAST[0][0] == 'real_type_name':
        var_type[var_name] = 'type_real'
        var_value[var_name] = 1.0
    elif pyAST[0][0] == 'simple_type_name':
        var_type[var_name] = 'type_func'
        
    if len(pyAST) > 1:
        default_value = expression(pyAST[1][1])
        if var_type[var_name] == 'type_bool':
            var_value[var_name] = default_value.lower() == "true"
        elif var_type[var_name] in ['type_byte', 'type_int']:
            var_value[var_name] = int(default_value)
        elif var_type[var_name] == 'type_real':
            var_value[var_name] = float(default_value)

def var_init_decl(pyAST):
    var_name = variable_name(pyAST[0][1])
    parse_res[var_name] = []
    var_value[var_name] = None
    simple_spec_init(pyAST[1][1], var_name)
    return var_name

def inputVar(pyAST):
    for e in pyAST:
        var_name = var_init_decl(pyAST[1])
        parse_res[var_name].append(var_value[var_name])

def input_declarations(pyAST): return inputVar(pyAST)
def input_output_declaration(pyAST): return inputVar(pyAST)

def Var(pyAST):
    for e in pyAST:
        var_name = var_init_decl(pyAST[1])
        parse_res[var_name].append('X')

def output_declarations(pyAST): return Var(pyAST)
def var_declarations(pyAST): return Var(pyAST)

def setVar(pyAST, vlist):
    l = []
    for j in range(len(vlist)):
        l.append('X')
    l[vlist.index(pyAST)] = 'True'
    return l

def if_statement(pyAST):
    exp = expression(pyAST[0][1])
    st_list = statement_list(pyAST[1][1])
    return ("if", exp, st_list)

def assignment_statement(pyAST):
    ret = "var_value['" + variable_name(pyAST[0][1]) + "'] = " + expression(pyAST[1][1])
    return ret

def statement_list(pyAST):
    ret = []
    for e in pyAST:
        if e[0] == 'assignment_statement':
            ret.append(assignment_statement(e[1]))
        elif e[0] == 'if_statement':
            ret.append(if_statement(e[1]))
        elif e[0] == 'fb_invocation':
            ret.append(fb_invocation(e[1]))
    return ret

def function_block_body(pyAST):
    for e in pyAST:
        if e[0] == 'statement_list':
            execution_list = statement_list(e[1])

def program_declaration(pyAST):
    for e in pyAST:
        if e[0] == 'program_type_name': prog_name = e[1][0]
        elif e[0] == 'input_declarations': input_declarations(e[1])
        elif e[0] == 'input_output_declarations': input_output_declarations(e[1])
        elif e[0] == 'output_declarations': output_declarations(e[1])
        elif e[0] == 'var_declarations': var_declarations(e[1])
        elif e[0] == 'function_block_body': function_block_body(e[1])

def configuration_declaration(pyAST):
    if isinstance(pyAST, str): return
    elif isinstance(pyAST, tuple):
        if pyAST[0] == 'time_literal': cycle_time = time_literal(pyAST[1])
    else:
        for e in pyAST: configuration_declaration(e)


def InitPT(pyAST):
    if isinstance(pyAST, str): return
    if isinstance(pyAST, tuple):
        if pyAST[0] == 'program_declaration': program_declaration(pyAST[1])
        elif pyAST[0] == 'configuration_declaration': 
            configuration_declaration(pyAST[1])
    else:
        for e in pyAST:
            InitPT(e)

def buildPT(pyAST):
    InitPT(pyAST)
    
