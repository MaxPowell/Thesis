import matplotlib.pyplot as plt
import csv
import sys
import numpy as np
from matplotlib.ticker import FuncFormatter


if(len(sys.argv) == 1):
	print "Usage: python script <csv1> <csv2> ... <csv1_legend> <csv2_legend> ... <output_dir>"
	sys.exit(1)


NUMBER_REPETITIONS = 2 # If experiments are run only once, change to 1
MARKER_SIZE = 2

AVG_STYLE_1 = 'r'
AVG_STYLE_2 = 'b'
AVG_STYLE_3 = 'g'
AVG_STYLE_4 = 'c'
AVG_STYLE_5 = 'k'
AVG_SIZE = 1

FORMATTED_LIST=['Speed', 'Sent', 'Received', 'Dropped', 'CPUs', 'Cycles', 'Page_faults', 'Time', 'SSL_handshakes']


def y_fmt(y, pos):
    decades = [1e9, 1e6, 1e3 ]
    suffix  = ["G", "M", "K" ]
    if y == 0:
        return str(0)
    for i, d in enumerate(decades):
        if np.abs(y) >= d:
			print i, d, np.abs(y)
			val = y/int(d)
			return '{val:s} {suffix}'.format(val=str(val), suffix=suffix[i])
            
    return y


def compute_average(key, data):
	mean=[]
	for speed in get_speed_list(data):
		indices = [i for i, x in enumerate(data['Speed'].tolist()) if x==speed]
		total=0
		for index in indices:
			total+=data[key][index]
		total=total/len(indices)
		mean.append(total)
	return mean


def set_legend(x_axis, y_axis):
	fig, ax = plt.subplots()	# Comment out these 2 lines in case of error with formatter
	ax.yaxis.set_major_formatter(FuncFormatter(y_fmt))

	if(x_axis == 'Speed'):
		plt.xlabel("Speed (Mbps)")
	
	if(y_axis == 'Sent'):
		plt.ylabel("Packets sent")
	elif(y_axis == 'Received'):
		#plt.ylabel("Packets analyzed")
		plt.ylabel("Packets per second")
		plt.ylim([10000, 50000]) 
	elif(y_axis == 'Dropped'):
		plt.ylabel("Packets dropped")
	elif(y_axis == 'CPUs'):
		plt.ylabel("CPUs used")
	elif(y_axis == 'Cycles'):
		plt.ylabel("CPU cycles (GHz)")
		plt.ylim([0, 3.2])
	elif(y_axis == 'Page_faults'):
		plt.ylabel("Page faults (M/sec)")
	elif(y_axis == 'Time'):
		plt.ylabel("Bro execution time (s)")
	elif(y_axis == 'SSL_handshakes'):
		plt.ylabel("SSL handshakes")
	else:
		plt.ylabel(y_axis+" (Hz)")
	

def set_style(num):
	if(num==0):
		return AVG_STYLE_1
	elif(num==1):
		return AVG_STYLE_2
	elif(num==2):
		return AVG_STYLE_3
	elif(num==3):
		return AVG_STYLE_4
	elif(num==4):
		return AVG_STYLE_5
	else:
		return 'y'


def to_Herz(data, y_axis):
	i=0
	while i<len(data[y_axis]):
		data[y_axis][i]=(data[y_axis][i]/data['Time'][i]) 
		# We divide by total time to obtain Hz
		i+=1

def get_speed_list(data):
	return data['Speed'][:len(data['Speed'])/NUMBER_REPETITIONS]


def plot_data(x_axis, y_axis):
	set_legend(x_axis, y_axis)
	plt.grid(color='darkgrey', linestyle='-', linewidth=1)	
	i=0
	while i<num_files:
		csv_file = sys.argv[i+1]
		data_struct = np.genfromtxt(csv_file, delimiter=',', names=True)
		SPEED_LIST = get_speed_list(data_struct)
		if(y_axis not in FORMATTED_LIST):
			to_Herz(data_struct, y_axis) # Convert to MHz

		if("Received" in y_axis):
			to_Herz(data_struct, y_axis) # This is done to obtain packets per second
		
		plt.plot(SPEED_LIST, compute_average(y_axis, data_struct), set_style(i), markersize=AVG_SIZE, label=sys.argv[i+1+num_files])
		i+=1
	
	plt.rcParams.update({'font.size': 18}) # Change font size
	plt.legend()
	plt.savefig(output_dir+y_axis+'_'+x_axis+'.pdf', bbox_inches='tight')
	plt.clf()


	
num_files = (len(sys.argv)-2)/2 #executable name and output dir are not files
output_dir = sys.argv[len(sys.argv)-1]
data_aux = np.genfromtxt(sys.argv[1], delimiter=',', names=True)

for name in data_aux.dtype.names[1:]:
	plot_data('Speed', name)



