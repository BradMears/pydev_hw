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

# Unpack the RPi-specific distro. These three lines are why we need
# a separate branch for raspberry-pi. The '2000' in the filename
# indicates that the file is from the year 2000. LabJack doesn't
# support the RPi very well.
# ADD copies and unpacks the archive in one fell swoop
ADD LabJackM-1.2000-openSUSE-Linux-aarch64-release.tar.gz /app
WORKDIR /app/LabJackM-1.2000-openSUSE-Linux-aarch64 

# Wow. This is an ugly hack. The LabJackM.run file returns a non-zero
# exit code when run inside a container. But if I call it as I do below,
# I can hide that exit code from Docker and pretend everything is A-OK. 
# This appears to work. Or at least the problems are not obvious.
RUN pip3 install --no-cache-dir labjack-ljm==1.21.0 && \
    bash -c "./LabJackM.run -- --no-restart-device-rules || echo 'Installer puked. Everything is A-OK'"
#    ./LabJackM.run -- --no-restart-device-rules 


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
