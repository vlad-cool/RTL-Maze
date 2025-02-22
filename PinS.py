# PinS(Pin Supervior) is a very simple tool to attach pins in Quartus.
# This program does a minimum of checks, all the mistakes is your own issue.

import re
from sys import argv

macros = [
    ("CLK", ["Y2"]),
    ("SW", ["AB28", "AC28", "AC27", "AD27", "AB27", "AC26", "AD26", "AB26", 
            "AC25", "AB25", "AC24", "AB24", "AB23", "AA24", "AA23", "AA22", 
            "Y24", "Y23"]),
    ("KEY", ["M23", "M21", "N21", "R24"]),
    ("LEDR", ["G19", "F19", "E19", "F21", "F18", "E18", "J19", "H19", 
              "J17", "G17", "J15", "H16", "J16", "H17", "F15", "G15",
              "G16", "H15"]),
    ("LEDG", ["E21", "E22", "E25", "E24", "H21", "G20", "G22", "G21", "F17"]),
    ("HEX0", ["G18", "F22", "E17", "L26", "L25", "J22", "H22"]),
    ("HEX1", ["M24", "Y22", "W21", "W22", "W25", "U23", "U24"]),
    ("HEX2", ["AA25", "AA26", "Y25", "W26", "Y26", "W27", "W28"]),
    ("HEX3", ["V21", "U21", "AB20", "AA21", "AD24", "AF23", "Y19"]),
    ("HEX4", ["AB19", "AA19", "AG21", "AH21", "AE19", "AF19", "AE18"]),
    ("HEX5", ["AD18", "AC18", "AB18", "AH19", "AG19", "AF18", "AH18"]),
    ("HEX6", ["AA17", "AB16", "AA16", "AB17", "AB15", "AA15", "AC17"]),
    ("HEX7", ["AD17", "AE17", "AG17", "AH17", "AF17", "AG18", "AA14"]),
    ("LCD_DATA", ["L3", "L1", "L2", "K7", "K1", "K2", "M3", "M5"]),
    ("GPIO_", ["AB22", "AC15", 
               "AB21", "Y17", 
               "AC21", "Y16", 
               "AD21", "AE16", 
               "AD15", "AE15", 
               "AC19", "AF16", 
               "AD19", "AF15",
               "AF24", "AE21", 
               "AF25", "AC22", 
               "AE22", "AF21", 
               "AF22", "AD22", 
               "AG25", "AD25", 
               "AH25", "AE25", 
               "AG22", "AE24",
               "AH22", "AF26", 
               "AE20", "AG23", 
               "AF20", "AH26", 
               "AH23", "AG26"])
]

def get_macro_indices(text : str, max) -> tuple[int, int]:
    if text == "":
        return [max, 0]
    indices = [int(x) for x in text.split("_")]
    if len(indices) == 1:
        indices += indices
    if len(indices) > 2:
        stop("Bad macro indices.")
    return indices

def try_to_expand_macro(text : str) -> tuple[str]:
    try:
        for macro in macros:
            if text.startswith(macro[0]):
                result = []
                indices = get_macro_indices(text[len(macro[0]):], len(macro[1]) - 1)
                for index in range(indices[0], indices[1] - 1, -1):
                    result += [macro[1][index]]
                return result
        return [text]
    except:
        stop("Can't expand macro")

def stop(msg):
    print(msg)
    exit(-1)

if len(argv) < 3:
    stop("usage>python PinS.py [module.v] [file.qsf]")
code_path = argv[1]
qsf_path = argv[2]

def get_pins_plan(code):
    module_regex = re.compile(r"""
        \bmodule\s+(?P<module_name>[a-zA-Z_][a-zA-Z0-9_]*)\s*
        \((?P<interface>[^()]*)\)\s*;
    """, re.MULTILINE | re.DOTALL | re.VERBOSE)
    match = module_regex.search(code)
    if match is None:
        stop("There is no module.")
    interface = match.group("interface")
    if interface is None:
        stop("There is no interface in module.")
    ports = [line for line in interface.splitlines() if line.strip()]
    port_regex = re.compile(r"""^
        \s*(?P<ctype>input|output|inout)?
        \s*(?P<dtype>wire|reg)?
        \s?(?P<array>\[\d+:\d+\])?
        \s*(?P<name>[a-zA-Z_][a-zA-Z0-9_]*)
        \s*,?\s*(//)?[\w\s,/:\[\]]*
        (@{(?P<pins>[a-zA-Z0-9_,\s]+)})?
    """, re.MULTILINE | re.DOTALL | re.VERBOSE)
    plan = []
    for port in ports:
        info = port_regex.search(port)
        if info is None:
            print("Unhandled port [" + port + "]. Continue...")
            continue
        name = info.group("name")
        array = info.group("array")
        raw_pins = info.group("pins")
        if raw_pins is not None:
            raw_pins = re.sub(r"\s+", "", raw_pins)
        print(". " + name + (array if array else "(single)") + " @ " + (raw_pins if raw_pins else "X"))
        if array:
            array = [int(x) for x in array[1:-1].split(":")]
        if raw_pins is None:
            continue
        pins = []
        for pin in raw_pins.split(","):
            pins += try_to_expand_macro(pin)
        plan += [(name, array, pins)]
    return plan

def set_location(pin, port, container):
    assignment = f"set_location_assignment PIN_{pin} -to {port}"
    container += [assignment + "\n"]
    print("(+)", assignment)

plan = None
with open(code_path, "r") as code_file:
    plan = get_pins_plan(code_file.read())

qsf_lines = []
with open(qsf_path, "r") as qsf_file:
    for line in qsf_file:
        if line.startswith("set_location_assignment"):
            print("(-)", line[:-1])
            continue
        qsf_lines += [line]
qsf_lines += ["\n"]
for item in plan:
    name, array, pins = item
    if array is not None:
        pairs = zip([index for index in range(array[1], array[0] + 1)], pins[::-1])
        for pair in pairs:
            set_location(pair[1], name + "[" + str(pair[0]) + "]", qsf_lines)
    else:
        set_location(pins[0], name, qsf_lines)
with open(qsf_path, "w") as qsf_file:
    qsf_file.writelines(qsf_lines)
