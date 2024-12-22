FROM bradmears/pydev:latest

###
### FT232H
###  
RUN apt update && \
    apt upgrade -y && \
    apt install -y \
        python3-venv \
        libusb-dev \
        libusb-1.0-0 \
        unzip \
        picocom
                
# Install the Adafruit Blinka library so I can use the FT232H.
# This has to be installed with pip and to avoid polluting the
# global library space, I install it in a virtual environment
RUN python3 -m venv --system-site-packages /usr/local/home/venv/Blinka && \
    . /usr/local/home/venv/Blinka/bin/activate &&  \
    pip3 install pyftdi Adafruit-Blinka && \
    deactivate

###
### LabJack
###
RUN python3 -m venv --system-site-packages /usr/local/home/venv/LabJack && \
    . /usr/local/home/venv/LabJack/bin/activate &&  \
    pip3 install --no-cache-dir labjack-ljm==1.21.0 && \
    deactivate

RUN mkdir /app
COPY examples /app/examples

# Unpack the Intel Linux distro . These lines are different in the raspberry-pi branch.
COPY LabJack-LJM_2024-06-10.zip /app
WORKDIR /app

# Install the LabJack SW and then immediately delete Kipling
RUN unzip *.zip && \
    ./labjack_ljm_installer.run -- --no-restart-device-rules && \
    rm /app/LabJack-LJM_*.zip && \
    rm -rf /opt/labjack_kipling  # kipling is broken so I can save that space

###
### ESP32
###    



###
### Rigol O-scope screen grab utilities
###

# As of 2024-12-21, there is bug in recent versions of setuptools and we have to install a
# an older version for the ds1054z install to succeed.
# Use the command 'ds1054z' to interat with o-scope
RUN pip3 install --upgrade pip wheel pip-tools && \
    pip install --upgrade setuptools==70.0.0 && \
    pip3 install pypandoc pyvisa && \
    pip3 install ds1054z

# One day I will install this one too but right now it has some issues. See my Lab Notes
# from 2024-12-21
# RUN pip3 install rigol-ds1000z

###
### BusPirate
###
WORKDIR /app
RUN git clone https://github.com/juhasch/pyBusPirateLite.git
WORKDIR /app/pyBusPirateLite
RUN python3 ./setup.py build install

###
### Container setup
###
WORKDIR /usr/local/home/
COPY bashrc.pydev_hw /usr/local/home/
RUN cat bashrc.pydev_hw >> bashrc && \
    rm bashrc.pydev_hw

CMD ["/bin/bash"]
