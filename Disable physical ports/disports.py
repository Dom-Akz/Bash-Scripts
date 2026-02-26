import os
import platform
import subprocess



def main():
    os_name = platform.system()

    if os_name == "Windows":
        # execute powershell scripts : 
        subprocess.run(["powershell ./disable.ps1"])
    elif os_name == "Darwin":
        pass
    elif os_name == "Linux":
        # execute bash
        res = subprocess.run(["./disable.sh"], capture_output=True, text=True)
        print(res.stdout)
    else : 
        print("Operation System unkown")


if __name__ == "__main__":
    main()


