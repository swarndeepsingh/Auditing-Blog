from refreshOSFamily import iTopOperations as OSF
from refreshbrands import iTopOperations as brands
from refreshmodels import iTopOperations as models
from refreshlocations import iTopOperations as locations
from test import iTopOperations as test
from refreshvirtualhosts import iTopOperations as vhosts
from refreshservers import iTopOperations as servers
from addVirtualMachines import iTopOperations as vm
from addCloudServers import iTopOperations as cloudsrvrs

def main():

	# 1. get OS Family
	# 2. get brands
	# 3. get models
	# 4 . get locations
	# 5. get servers (including physical hosts, virtual hosts, excluding: vm guests, cloud servers)
	# 6. get virtual host as hypervisor and map with virtual host server
	# 7. get VMs
	# 8. get Xen
	# 9. get Azure
	# 10. get AWS
	
	OSF.getNewOSFamilies()
	brands.getbrands()
	models.setmodels()
	locations.setlocations()
	servers.setservers()
	vhosts.setvmhosts()
	vm.addVirtualMachines()
	cloudsrvrs.addCloudServers()
	
	
	
main()
