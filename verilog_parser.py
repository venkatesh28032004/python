import os
import shutil
import sys
import re
import pprint

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
#tb_file = 'tb_' + module_file

'''
check module file exists or not
'''
if os.path.isfile(module_file) == False:
	print('module file given doesn\'t exist....\nExiting the script....')
	sys.exit()

'''
check "WORKDIR" file exists or not 
'''
if os.path.isdir("./WORKDIR"):
	print('WORKDIR already exists, overwrite the directory? (Y/N): ', end='')
	opt = input()
	if opt == 'Y' or opt == 'y':
		print('Overwriting WORKDIR...')
		shutil.rmtree("./WORKDIR")
		os.mkdir("./WORKDIR")
	else:
		print('WORKDIR is not changed\nExiting the script...')
		sys.exit()
else:
	print('WORKDIR doesnot exist, creating....')
	#tb_file = 'tb_' + module_file
	os.mkdir("./WORKDIR")

################################### used function definitions #############################################
def has_width(line):
	line = line.strip()
	if line.startswith('['):
		return True
	else:
		return False

def find_width(line):
	temp = line.split()
	return temp[0]

def remove_width(line):
	temp = line.split()
	temp = temp[1:]
	final = [tmp[:-1] for tmp in temp]
	return final

############################################# parse_input #####################################################

def parse_input(module_file):
	input_pattern = re.compile(r'input\s(.*?);')
	raw_inputs = []
	with open(module_file) as fp:
		raw_inputs = re.findall(input_pattern, fp.read())
		# inputs contain raw inputs. make dictionary with key as width and value as
		# variable name
	inputs = []
	for line in raw_inputs:
		line = line.replace('\n', '')
		inputs += [line]
	
	# inputs contain all the raw inputs without \n

	input_dict = {}
	for line in inputs:
		if has_width(line):
			width = find_width(line)
			input_variables = remove_width(line) # return a list of variables
			for variables in input_variables:
				input_dict.setdefault(width, [])
				input_dict[width] += [variables]
		else:
			for variables in line.split(','):
				input_dict.setdefault('1', [])
				input_dict['1'] += [variables]
	return input_dict

########################################### parse_output ###############################################

def parse_output(module_file):
	input_pattern = re.compile(r'output\s(.*?);')
	raw_inputs = []
	with open(module_file) as fp:
		raw_inputs = re.findall(input_pattern, fp.read())
		# inputs contain raw inputs. make dictionary with key as width and value as
		# variable name
	inputs = []
	for line in raw_inputs:
		line = line.replace('\n', '')
		inputs += [line]
	
	# inputs contain all the raw inputs without \n

	input_dict = {}
	for line in inputs:
		if has_width(line):
			width = find_width(line)
			input_variables = remove_width(line) # return a list of variables
			for variables in input_variables:
				input_dict.setdefault(width, [])
				input_dict[width] += [variables]
		else:
			for variables in line.split(','):
				input_dict.setdefault('1', [])
				input_dict['1'] += [variables]
	return input_dict

############################################## parse_inout ###################################################
def parse_inout(module_file):
	input_pattern = re.compile(r'inout\s(.*?);')
	raw_inputs = []
	with open(module_file) as fp:
		raw_inputs = re.findall(input_pattern, fp.read())
		# inputs contain raw inputs. make dictionary with key as width and value as
		# variable name
	inputs = []
	for line in raw_inputs:
		line = line.replace('\n', '')
		inputs += [line]
	
	# inputs contain all the raw inputs without \n

	input_dict = {}
	for line in inputs:
		if has_width(line):
			width = find_width(line)
			input_variables = remove_width(line) # return a list of variables
			for variables in input_variables:
				input_dict.setdefault(width, [])
				input_dict[width] += [variables]
		else:
			for variables in line.split(','):
				input_dict.setdefault('1', [])
				input_dict['1'] += [variables]
	return input_dict

#################################################### parse_module ####################################################

def parse_module(module_file):
	module_pattern = re.compile(r'([a-zA-Z0-9_]+)\s([a-zA-Z0-9_]+)\s\((.*?)\);', re.DOTALL)
	raw_modules = []
	with open(module_file) as fp:
		raw_modules = re.findall(module_pattern, fp.read())
	
	i = 0
	line = []
	while i < len(raw_modules)-1:
		line += [raw_modules[i][0], raw_modules[i][1]]
		i += 1
	
	return line
	# line has even index = instance , odd index = instance name




########################################################################################################################################################################


def main():
	inputs = parse_input(module_file)
	outputs = parse_output(module_file)
	inouts = parse_inout(module_file)
	modules = parse_module(module_file)

	# writing the contents to respective file (i.e inputs, output, inouts, modules)

	os.mkdir(f"./WORKDIR/{modules[0]}")
	with open(f"./WORKDIR/{modules[0]}/inputs.txt", "w+") as fp:
		for keys in inputs:
			for values in inputs[keys]:
				temp = values.strip()
				fp.write(f"{temp}, {keys}\n")

	with open(f"./WORKDIR/{modules[0]}/outputs.txt", "w+") as fp:
		for keys in outputs:
			for values in outputs[keys]:
				temp = values.strip()
				fp.write(f"{temp}, {keys}\n")

	with open(f"./WORKDIR/{modules[0]}/inouts.txt", "w+") as fp:
		for keys in inouts:
			for values in inouts[keys]:
				temp = values.strip()
				fp.write(f"{temp}, {keys}\n")

	with open(f"./WORKDIR/{modules[0]}/modules.txt", "w+") as fp:
		idx = 0
		for value in modules:
			if idx%2==0:
				fp.write(f"{value} ,")
			else:
				fp.write(f"{value}\n")
			idx+=1




	############################# Checking errors ###############################

	############################# 1. missing semicolon###########################
	# every line need to have semicolon or comma
	lines = []
	with open(module_file) as fp:
		lines = fp.readlines()

	dont_consider = False
	i = 0
	for line in lines:
		i += 1
		if "//" in line:
			continue
		elif r'/*' in line:
			dont_consider = True
		elif r'*/' in line:
			dont_consider = False
			continue
		elif '`timescale' in line:
			continue
		
		if dont_consider==False and not (line.strip().endswith(',') or line.strip().endswith(';')) and line.strip()!="" and not (line.strip().endswith('begin') or line.strip().endswith('end')):
			print(f"ERRO1: missing semicolon ';' in line {i}")
			






	############################# 2. unmatched begin end ########################

	pattern_begin_end = re.compile(r'(begin).*?(end)', re.DOTALL)
	lines = []
	with open(module_file) as fp:
		lines = fp.readlines()
	
	idx = 1
	begin = False
	end = False
	module_begin = False
	module_end = False
	for line in lines:
		if ('begin' in line) and end==False:
			begin = True
		elif 'end' in line and begin==False:
			print(f'ERRO3: missing endmodule/end for the module/always {i}')
			begin = False
			end = False
		elif 'end' in line and begin==True:
			begin = False
			end = False

		if ('module' in line) and module_end==False:
			module_begin = True
		elif 'endmodule' in line and module_begin==False:
			print(f'ERRO3: missing endmodule/end for the module/always {i}')
			module_begin = False
			module_end = False
		elif 'endmodule' in line and begin==True:
			module_begin = False
			module_end = False


	###################### 3. unmatched paranthesis ##################################
	lines = []
	with open(module_file) as fp:
		lines = fp.readline()
	idx = 1
	for line in lines:
		count_open = line.count('(')
		count_close = line.count(')')
		if count_open == count_close:
			continue
		else:
			print(f"ERRO2: missing parenthesis in line {idx}")
		idx += 1




	

	############# 4. illegal names( port name or instance name ) #############
	pattern_1 = re.compile(r'input\s[0-9](.*?);', re.DOTALL)
	pattern_2 = re.compile(r'\([.]+\)')
	pattern_3 = re.compile(r'output\s[0-9](.*?);', re.DOTALL)
	pattern_4 = re.compile(r'inout\s[0-9](.*?);', re.DOTALL)
	lines = []
	with open(module_file) as fp:
		lines = fp.readlines()
	flag = False
	idx = 1
	for line in lines:
		temp = re.findall(pattern_1, line)
		if temp!= []:
			flag = True
		temp = re.findall(pattern_2, line)
		if temp!= []:
			flag = True
		temp = re.findall(pattern_3, line)
		if temp!= []:
			flag = True
		temp = re.findall(pattern_4, line)
		if temp!= []:
			flag = True
		
		if flag:
			print(f"ERRO4: illegal port name {temp[0]} in line {idx}")
			flag = False
		idx += 1







	################ 5. duplicate port name ######################33
	lst = []
	for key in inputs:
		for variables in inputs[key]:
			lst += [variables.strip()]
	l = 1
	for val in lst:
		if lst[:l].count(val) != 1:
			print(f'ERRO5: duplicate port name {val} in line {l}')
		l += 1
	
	



	
	################### 6. direction missing #############################
	lines = []
	with open(module_file) as fp:
		lines = fp.readlines()
	idx = 1
	for line in lines:
		flag = False
		if line.strip().startswith('['):
			flag = True
		if flag:
			print(f'ERRO6: missing direction for the port in line {idx}')
		idx += 1




	################## 7. comma misuse in port list ########################
	pattern = re.compile(r'module\s+\w+\s\(.*?,\)')
	lines = []
	with open(module_file) as fp:
		lines = fp.readlines()
	idx = 1
	for line in lines:
		flag = False
		temp = re.findall(pattern, line)
		if temp != []:
			flag = True
		if flag:
			print(f'ERRO7: comma misuse in port list in module definition in line {idx}')
		idx += 1





	################## 8. multiple widths on same port ####################
	pattern = re.compile(r'\[.*?\]\s\[.*?\]')
	lines = []
	with open(module_file) as fp:
		lines = fp.readlines()
	idx = 1
	for line in lines:
		flag = False
		temp = re.findall(pattern, line)
		if temp != []:
			flag = True
		if flag:
			print(f'ERRO8: multiple widths on same port in line {idx}')
		idx += 1
		


	################### 9. case sensitivity issue #####################3
	lines = []
	with open(module_file) as fp:
		lines = fp.readlines()
	idx = 1
	for line in lines:
		if 'Input' in line or 'Output' in line:
			print(f'ERRO9: case sensitivity issue of port direction in line {idx}')
		idx += 1




	################# 10. missing comma b/w ports #####################
	lines = []
	with open(module_file) as fp:
		lines = fp.readlines()
	idx = 1
	for line in lines:
		module_begin = False
		module_end = False
		if ('module' in line) and module_end==False:
			module_begin = True
		elif 'endmodule' in line and module_begin==False:
			print(f'ERRO:missing endmodule/end for the module/always {i}')
			module_begin = False
			module_end = False
		elif 'endmodule' in line and begin==True:
			module_begin = False
			module_end = False
		
		dont_consider = False
		comma_flag = False
		if "//" in line:
			continue
		elif r'/*' in line:
			dont_consider = True
		elif r'*/' in line:
			dont_consider = False
			continue
		elif '`timescale' in line:
			continue
		
		if dont_consider==False and not (line.strip().endswith(',') or line.strip().endswith(';')) and line.strip()!="" and not (line.strip().endswith('begin') or line.strip().endswith('end')):
			comma_flag = True
		if comma_flag and module_begin:
			print(f'ERRO10: missing comma between ports in module definition in	line {idx}')
		idx += 1




	################# 11. duplicate instance names ################
	idx = 0
	for module in modules:
		if modules[:idx+1].count(module) > 1 and idx%2!=0:
			print(f"ERRO11: Instance name {module} is already defined in line {idx}")
			# find the occurance of instance name at module[idx]
			# or find the second occurance of module[idx]
			
		idx += 1
		#lines = []
		#	with open(module_file) as fp:
		#		lines = fp.readline()
		#	idx = 1
		#	occurance = 0
		#	for line in lines:
		#		if 

main()
print("script completed")
	
