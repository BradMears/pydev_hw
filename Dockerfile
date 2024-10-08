FROM bradmears/pydev:latest

###
### FT232H
###  
RUN apt update && \
    apt upgrade -y && \
    apt install -y \
        python3-venv \
        libusb-dev

# Install the Adafruit Blinka library so I can use the FT232H.
# This has to be installed with pip and to avoid polluting the
# global library space, I install it in a virtual environment
RUN python3 -m venv /usr/local/home/venv/Blinka && \
    . /usr/local/home/venv/Blinka/bin/activate &&  \
    pip3 install pyftdi Adafruit-Blinka && \
    deactivate

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
