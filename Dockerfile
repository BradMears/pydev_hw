FROM bradmears/pydev:latest

ENV TZ=US \
    DEBIAN_FRONTEND=noninteractive

RUN apk update && \
apk upgrade && \
apk add \
    py3-pip \
    python3-dev \
    gcc \
    musl-dev \
    libusb

# Install the Adafruit Blinka library so I can use the FT232H.
# This has to be installed with pip and best-practice with pip in Alpine
# is to install it in a virtual environment
RUN python3 -m venv /usr/local/home/venv/Blinka && \
    . /usr/local/home/venv/Blinka/bin/activate &&  \
    pip3 install pyftdi Adafruit-Blinka && \
    deactivate

WORKDIR /usr/local/home/
COPY bashrc.pydev_hw /usr/local/home/
RUN cat bashrc.pydev_hw >> bashrc && \
    rm bashrc.pydev_hw

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

CMD ["/bin/bash"]
