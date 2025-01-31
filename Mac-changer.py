import argparse #imports argparse so we can input the new mac address from the command line
import re #imports regular expression so that we can check if the format for our mac address is right
import subprocess #imports subprocess to let us use shell scripting lines in python
import sys #imports sys for our system error when we used stderr or standard error

#got the validate_mac from my shell scipt and modified it

def validate_mac(mac_address): #defines our validate_mac function to check that the mac address is in the correct format.
    return re.fullmatch(r"([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}", mac_address) is not None #defines our format for a mac address using regular expression module.

#got this error_exit from my shell script and modified it

def error_exit(message): #creates a function named error_exit that will handle any outputs of an error that we encounter
    print(f"Error: {message}", file=sys.stderr) #prints Error and (message), our reason for the error.
    sys.exit(1) #uses sys module to exit, (1), meaning there was an error and we want to stop our code, this happens after our error message was displayed.

#got this run_command from my shell scipt being changed by chatGPT

def run_command(command): #defineds a run_command function that is a shell command, hence using subprocess module
    try:
        subprocess.run(command, shell=True, check=True, stderr=subprocess.PIPE) #uses subprocess command, shell=True lets us run the shell script, check=True checks if we have a return number that is 1 or more meanign an error occured.
        #stderr=subprocess takes all errors and stores them rather than printing them.
    except subprocess.CalledProcessError as e: #If we encounter an error with return number 1 or greater, we raise our "CalledProcessError"
        error_exit(e.stderr.decode().strip()) #If an error occured, we call our error_exit funtion as well as taking errors and decoding the byte to be striped of whitespace, basically cleaning up our error to the be output from our error_exit. Since our error_exit has the last line "sys.exit(1)," our code is exited once the error occurs.

#I knew how to put in argparse, with some pieces from my shell script

def main(): #defines main for argparse to take command line input
    parser = argparse.ArgumentParser(description="change mac address") #decribes our arparse arguments
    parser.add_argument("-i", "--interface", required=True, help="Your interface network") #adds an argument for the network inerface that we are on
    parser.add_argument("-m", "--mac", required=True, help="new desired mac address") #adds an argument for the new desired Mac address
    
#same thing i knew this but with some help from ChatGPT
    
    args = parser.parse_args() #calls args and 
    interface, new_mac = args.interface, args.mac #passes in our interface for our argument interface and passes in the new_mac for our argument mac

#got these from above
   
    if not validate_mac(new_mac): #if not complient with our validate_mac function then we call error and exit, this checks if the new mac address is in the right format
        error_exit("") #exits with the error displayed.
    
#Got these lines from a suggestion from chatGPT with explainations
    
    if subprocess.run(f"ip link show {interface}", shell=True, stderr=subprocess.DEVNULL).returncode != 0: #if our shell script checks the interface, shell=true says we can run shell script, stderr=subprocess.DEVNULL stops the errors, and we see if the interface check wasn't equal to 0, if it wasnt then there was an error and we call our error_exit function
       #stderr=subprocess.DEVNULL uses our subprocess module and haults all system errors from being output.
        error_exit(f"Network interface {interface} does not exist.") #calls our error_exit function and says that the given network interface does not exist.

#straight from chatGPT from a suggestion from my given shell script

    run_command(f"sudo ip link set dev {interface} down") #takes down the network, disconnects it to allow us to change it
    run_command(f"sudo ip link set dev {interface} address {new_mac}") #takes the now "down" interface and puts in our new desired mac address
    run_command(f"sudo ip link set dev {interface} up") #takes the network a turns it back on, or up now that our mac address was changed.

#me, i got this almost directly from my shell scipt

    print(f"MAC address for {interface} successfully changed to {new_mac}.") #prints out that for our network we successfully changed our mac address to the new mac address

#calls from argparse which i know

if __name__ == "__main__": #calls for main from argparse.
    main()
