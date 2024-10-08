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
        unzip
                
# Install the Adafruit Blinka library so I can use the FT232H.
# This has to be installed with pip and to avoid polluting the
# global library space, I install it in a virtual environment
RUN python3 -m venv /usr/local/home/venv/Blinka && \
    . /usr/local/home/venv/Blinka/bin/activate &&  \
    pip3 install pyftdi Adafruit-Blinka && \
    deactivate

###
### LabJack
###
RUN python3 -m venv /usr/local/home/venv/LabJack && \
    . /usr/local/home/venv/LabJack/bin/activate &&  \
    pip3 install --no-cache-dir labjack-ljm==1.21.0 && \
    deactivate

RUN mkdir /app

# The filename of the .zip file will change when the version updates and I 
# download a new one. So use a wildcard to grab what should be exactly one 
# matching file.
COPY labjack_src/LabJack-LJM_*.zip /app
COPY labjack_src/list_connections.py /app
WORKDIR /app
RUN unzip *.zip && \
    ./labjack_ljm_installer.run -- --no-restart-device-rules && \
    rm /app/LabJack-LJM_*.zip && \
    rm -rf /opt/labjack_kipling  # kipling is broken so I can save that space

###
### ESP32
###    



###
### Rigol O-scope screen grab utility
###

# Man, installing this screen grab utility for the Rigol is a lot of work for something
# I rarely use.
# And now I found that it requires python 3.7. Newer versions won't do. I'm hitting pause
# on this for a while.
#RUN curl https://pyenv.run | bash && \
#    pip3 install -U pyvisa pypi pipenv && \
#    git clone https://github.com/rdpoor/rigol-grab.git && \
#    cd rigol-grab && \
#    pipenv install && \    
#    echo "Done installing rigol-grab"
#COPY rigol-grab.sh /app

###
### Container setup
###
WORKDIR /usr/local/home/
COPY bashrc.pydev_hw /usr/local/home/
RUN cat bashrc.pydev_hw >> bashrc && \
    rm bashrc.pydev_hw

CMD ["/bin/bash"]
