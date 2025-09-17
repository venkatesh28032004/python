import os
import shutil
import sys
import re

print(f'arguments provided: {sys.argv}')

'''
checking arguments
'''
if len(sys.argv) < 2:
	print('please provide 1 arguments of module file')
	print('Exiting the script...')
	sys.exit()
elif len(sys.argv) > 2:
	print('You have provided more than 1 arguments, considering first argument....')

module_file = sys.argv[1]
tb_file = 'tb_' + module_file

'''
check module file exists or not
'''
if os.path.isfile(module_file) == False:
	print('module file given doesn\'t exist....\nExiting the script....')
	sys.exit()

'''
check tb file exists or not 
'''
if os.path.isfile(tb_file):
	print('testbench file already exists, overwrite the tb file? (Y/N): ', end='')
	opt = input()
	if opt == 'Y' or opt == 'y':
		print('Overwriting the tb file...')
		os.remove(tb_file)
		os.open(tb_file, os.O_RDWR | os.O_CREAT, 0o755)
	else:
		print('tb file is not changed\nExiting the script...')
		sys.exit()
else:
	print('testbench file doesnot exist, creating....')
	#tb_file = 'tb_' + module_file
	os.open(tb_file, os.O_RDWR | os.O_CREAT, 0o755)

'''
open module_file and get all the inputs and outputs to the respective lists
'''
inputs = []
outputs = []
input_pattern = re.compile(r'(?<=input\s)(\w+)(?=[,|\n])')
output_pattern = re.compile(r'output\s+(?:reg)?(.+)[,|\n]')
#output_pattern = re.compile(r'(?<=output\s).+(?=[,|\n])')



with open(module_file, 'r') as module_file_obj:
	content = module_file_obj.read()
	inputs = input_pattern.findall(content)
	outputs = output_pattern.findall(content)

print("inputs = ", inputs)	
print("outputs = ", outputs)
input_names = []
output_names = []
names = re.compile(r'[a-zA-Z_]+\w*')
input_names += [names.search(temp).group() for temp in inputs]
output_names += [names.search(temp).group() for temp in outputs]
input_names += output_names
print(input_names)
print(output_names)

with open(tb_file, 'w') as tb_file_obj:
	tb_file_obj.write(f'`include "{module_file}"\n')
	tb_file_obj.write(f'module {tb_file[:-2]}();\n')
	for input_values in inputs:
		tb_file_obj.write(f'\treg {input_values};\n')
	for output_values in outputs:
		if output_values[-1] == ',':
			output_values = output_values[:-1]
		tb_file_obj.write(f'\twire {output_values};\n')
	tb_file_obj.write(f'\t{module_file[:-2]} UUT (')
	ct = 1
	for values in input_names:
		tb_file_obj.write(f'\n\t\t\t.{values}({values})')
		if ct<len(input_names):
			tb_file_obj.write(', ')
		else:
			tb_file_obj.write(' ')
		ct+=1
	tb_file_obj.write('\n\t\t);\n\n\n')
	tb_file_obj.write(f'\tinitial begin\n\t\t$recordfile("{module_file[:-2]}.trn");\n\t\t$recordvars();\n\tend\n')
	tb_file_obj.write('\n\tinitial begin\n\n\t\t//enter your code here\n\n\t\t#150;\n\t\t$finish;\n\tend\n')
	tb_file_obj.write('\n\tinitial begin\n\n\t\t$monitor($time, "')
	for values in input_names:
		tb_file_obj.write(f' {values} = %0d,')
	ct = 1
	tb_file_obj.write('",')
	for values in input_names:
		tb_file_obj.write(f'{values}')
		if ct<len(input_names):
			tb_file_obj.write(', ')
		else:
			tb_file_obj.write(' ')
		ct+=1
	tb_file_obj.write(');\n\tend\n')
	tb_file_obj.write('endmodule')

print('Script completed')
