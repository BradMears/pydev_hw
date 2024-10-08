"""
Demonstrates how to set a single digital state on a LabJack.

Relevant Documentation:

LJM Library:
    LJM Library Installer:
        https://labjack.com/support/software/installers/ljm
    LJM Users Guide:
        https://labjack.com/support/software/api/ljm
    Opening and Closing:
        https://labjack.com/support/software/api/ljm/function-reference/opening-and-closing
    eWriteName:
        https://labjack.com/support/software/api/ljm/function-reference/ljmewritename

T-Series and I/O:
    Modbus Map:
        https://labjack.com/support/software/api/modbus/modbus-map
    Digital I/O:
        https://labjack.com/support/datasheets/t-series/digital-io

"""
from time import sleep
from labjack import ljm


# Open first found LabJack
handle = ljm.openS("ANY", "ANY", "ANY")  # Any device, Any connection, Any identifier

info = ljm.getHandleInfo(handle)
print("Opened a LabJack with Device type: %i, Connection type: %i,\n"
      "Serial number: %i, IP address: %s, Port: %i,\nMax bytes per MB: %i" %
      (info[0], info[1], info[2], ljm.numberToIP(info[3]), info[4], info[5]))

deviceType = info[0]

# Setup and call eWriteName to set a DIO state on the LabJack.
if deviceType == ljm.constants.dtT4:
    # Setting FIO4 on the LabJack T4. FIO0-FIO3 are reserved for AIN0-AIN3.
    name = "FIO7"

    # If the FIO/EIO line is an analog input, it needs to first be changed to a
    # digital I/O by reading from the line or setting it to digital I/O with the
    # DIO_ANALOG_ENABLE register.

    # Reading from the digital line in case it was previously an analog input.
    ljm.eReadName(handle, name)
else:
    # Setting FIO0 on the LabJack T7 and T8.
    name = "FIO0"

state = 1
for ii in range(10):
    ljm.eWriteName(handle, name, state)
    state = int(not state)
    print("\nSet %s state : %f" % (name, state))
    sleep(2)

# Close handle
ljm.close(handle)
