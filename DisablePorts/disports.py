import os
import platform
import subprocess
from pathlib import Path

FOLDER = Path(__file__).parent

def main():
    
    dis_bash = str(FOLDER)+"/disable.sh"
    dis_powr = str(FOLDER)+"/disable.ps1"
   
    os_name = platform.system()

    if os_name == "Windows":
        subprocess.run([dis_powr], capture_output=True, text=True)
    elif os_name == "Darwin":
        pass
    elif os_name == "Linux":
        res = subprocess.run([dis_bash], capture_output=True, text=True)
        print(res.stdout)
    else : 
        print("Operation System unkown")


if __name__ == "__main__":
    main()


