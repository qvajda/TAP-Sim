from sys import *
cmt = '//'

files = []
target = ''
main = ''
with open(argv[1],'r') as tomake :
	line = tomake.readline()
	while(line.strip() == ''):
		line = tomake.readline()
	firstline = line.strip().split()
	if (firstline[0] == cmt and firstline[1] == 'target') or firstline[0] == '//target' :
		target = firstline[len(firstline) - 1]
	done = False
	while not done:
		line = tomake.readline().strip()
		if not line:
			done = True
		if line.startswith(cmt + ' include') or line.startswith(cmt + 'include') :
			splited = line.split()
			files.append(open(splited[len(splited)-1],'r'))
		else :
			done = True
	while True:
		if not line:
			break
		else:
			main+=line
			line = tomake.readline()
with open(target,'w') as fTarget :
	fTarget.write(main.strip() + '\n')
	for f in files :
		fTarget.write('\n' + f.read().strip() + '\n')
	for f in files :
		f.close()
	
