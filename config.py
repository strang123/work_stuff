import sys
#g
NOT_SET_YET = 777
HOST_HOST = 3
ROAD_WAR = 2
FOUR_TUNNEL = 1
KERNEL_IPSEC = 0
STRONG_IPSEC = 1
ipsec_type=NOT_SET_YET
tunnel_type=NOT_SET_YET

#A function that creates the config files for kernel ipsec
def kernel_ipsec():
	if tunnel_type == FOUR_TUNNEL:
		kernel_four_config()
	if tunnel_type == ROAD_WAR:
		kernel_road_config()
	if tunnel_type == HOST_HOST:
		kernel_host_config()
	print('Kernel ipsec files are being generated')
	return

#A functio nthat create the config files for strongswan
def strong_ipsec():
	if tunnel_type == FOUR_TUNNEL:
		strong_four_config()
	if tunnel_type == ROAD_WAR:
		strong_road_config()
	if tunnel_type == HOST_HOST:
		strong_host_config()
	print('Strongswan config files are being generated')
	return

def init():
	global ipsec_type
	global tunnel_type
	if sys.argv[1] == '0':
		ipsec_type = KERNEL_IPSEC		
	if sys.argv[1] == '1':
		ipsec_type = STRONG_IPSEC
	
	if sys.argv[2] == '1':
		tunnel_type = FOUR_TUNNEL
	if sys.argv[2] == '2':
		tunnel_type = ROAD_WAR
	if sys.argv[2] == '3':
		tunnel_type = HOST_HOST
	return

def run():
	if ipsec_type == KERNEL_IPSEC:
		kernel_ipsec()
	if ipsec_type == STRONG_IPSEC:
		strong_ipsec()
	return

def kernel_four_config():
	print("kernel four")
	config_file=open('ipsec.setkey', 'w+')
	print >>config_file, 'flush;'
	print >>config_file, 'spdflush;'
	print >>config_file, ''
	counter=0
	for i in range (0,int(sys.argv[3])):
		print >>config_file,'#'+str(i)+'a'

		print >>config_file,'add 172.16.1'\
		+str(i)+\
		'.1 172.16.1'\
		+str(i)+\
		'.10 esp 0x60'\
		+str(counter)+\
		' -m tunnel -E rijndael-cbc'\
		' 0xb0e39876daf6d4ee5aaa895a4733bd8'\
		+str(i)+\
		' -A hmac-sha1 0x8317954752bf255b5321fe19e54a7f8d0102030'\
		+str(i)+';'

		counter+=1
		print >>config_file,''
 
		print >>config_file,'add 172.16.1'\
		+str(i)+\
		'.10 172.16.1'\
		+str(i)+\
		'.1 esp 0x60'\
		+str(counter)+\
		' -m tunnel -E rijndael-cbc'\
		' 0xb0e39876daf6d4ee5aaa895a4733bd8'\
		+str(i)+\
		' -A hmac-sha1 0x8317954752bf255b5321fe19e54a7f8d0102030'\
		+str(i)+';'

		counter+=1
		print >>config_file,''

		print >>config_file,'spdadd 192.168.3'\
		+str(i)+\
		'.0/24 192.168.1'\
		+str(i)+\
		'.0/24 any -P out ipsec'
		print >>config_file,'esp/tunnel/172.16.1'\
		+str(i)+\
		'.1-172.16.1'\
		+str(i)+\
		'.10/require;'
		print >>config_file,'spdadd 192.168.1'\
		+str(i)+\
		'.0/24 192.168.3'\
		+str(i)+\
		'.0/24 any -P in ipsec'
		print >>config_file,'esp/tunnel/172.16.1'\
		+str(i)+\
		'.10-172.16.1'\
		+str(i)+\
		'.1/require;'
	

		print >>config_file,''
		
		
		print >>config_file,'#'+str(i)+'b'
		
		print >>config_file,'add 172.16.2'\
		+str(i)+\
		'.1 172.16.2'\
		+str(i)+\
		'.10 esp 0x60'\
		+str(counter)+\
		' -m tunnel -E rijndael-cbc'\
		' 0xb0e39876daf6d4ee5aaa895a4733bd'\
		+str(i)+\
		'8 -A hmac-sha1 0x8317954752bf255b5321fe19e54a7f8d010203'\
		+str(i)+'1;'
		
		counter+=1
		print >>config_file,''
		
		print >>config_file,'add 172.16.2'\
		+str(i)+\
		'.10 172.16.2'\
		+str(i)+\
		'.1 esp 0x60'\
		+str(counter)+\
		' -m tunnel -E rijndael-cbc'\
		' 0xb0e39876daf6d4ee5aaa895a4733bd'\
		+str(i)+\
		'8 -A hmac-sha1 0x8317954752bf255b5321fe19e54a7f8d010203'\
		+str(i)+'1;'
		
		counter+=1
		print >>config_file,''
		
		print >>config_file,'spdadd 192.168.4'\
		+str(i)+\
		'.0/24 192.168.2'\
		+str(i)+\
		'.0/24 any -P out ipsec'
		print >>config_file,'esp/tunnel/172.16.2'\
		+str(i)+\
		'.1-172.16.2'\
		+str(i)+\
		'.10/require;'
		print >>config_file,'spdadd 192.168.2'\
		+str(i)+\
		'.0/24 192.168.4'\
		+str(i)+\
		'.0/24 any -P in ipsec'
		print >>config_file,'esp/tunnel/172.16.2'\
		+str(i)+\
		'.10-172.16.2'\
		+str(i)+\
		'.1/require;'
		
		print >>config_file,''	
	return

def kernel_road_config():
	print("road")
	return
def kernel_host_config():
	print("host")
	return

def strong_four_config():
	print("strong four")
	return
def strong_road_config():
	print("strong road")
	return
def strong_host_config():
	print("strong host")
	return


init();
run();

