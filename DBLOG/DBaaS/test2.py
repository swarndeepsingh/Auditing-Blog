
import subprocess
print(subprocess.Popen('python test.py',shell=False,creationflags=subprocess.CREATE_NEW_CONSOLE,).pid)
