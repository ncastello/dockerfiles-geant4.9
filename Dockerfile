FROM rootproject/root-ubuntu16:latest

LABEL author="nuria.castello.mor@gmail.com" \
    version="1.0" \
    description="Docker image for GEANT4 DAMIC simulation"

USER 0

# uid (-u) and group IDs (-g) are fixed to 1000 to be used for development
# purposes
RUN useradd -u 1000 -md /home/gebicuser -ms /bin/bash gebicuser \
    && usermod -a -G builder gebicuser

# Correct base image to include ROOT python module
ENV PYTHONPATH="${PYTHONPATH}:/usr/local/lib/root"
# Include ROOT libraries
ENV LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:/usr/local/lib/root"

RUN apt-get update && apt-get -y install \
    cmake build-essential \
	qt4-dev-tools \
    libxerces-c-dev \
    libgl1-mesa-dev \
    libxmu-dev \
    libmotif-dev \
    libexpat1-dev \
    libboost-all-dev \
    xfonts-75dpi \
    xfonts-100dpi \
    imagemagick \
    wget \
    vim \
    && apt-get autoremove && rm -rf /var/lib/apt/lists/*


# Download, extract and install GEANT4
RUN mkdir -p /opt/geant4.9 \
    && cd /opt/geant4.9 \
    && wget http://geant4.cern.ch/support/source/geant4.9.6.p04.tar.gz \
    && tar -xzf geant4.9.6.p04.tar.gz && rm geant4.9.6.p04.tar.gz \
    && mkdir -p /opt/geant4.9-build && cd /opt/geant4.9-build \
    && cmake /opt/geant4.9/geant4.9.6.p04 \
       -DGEANT4_BUILD_MULTITHREADED=ON \
       -DGEANT4_USE_GDML=ON \
       -DGEANT4_USE_QT=ON \
       -DGEANT4_USE_XM=ON \
       -DGEANT4_USE_OPENGL_X11=ON \
       -DGEANT4_USE_RAYTRACER_X11=ON \
       -DGEANT4_INSTALL_DATA=ON \
       -Wno-dev \
    && make -j`grep -c processor /proc/cpuinfo` \
    && make install \
    && echo '. /usr/local/bin/geant4.sh' >> ~gebicuser/.bashrc \
    && /bin/bash -c ". /usr/local/bin/geant4.sh" \
    && chown gebicuser:gebicuser ~gebicuser/.bashrc && chown -R gebicuser:gebicuser /opt/geant4.9


# Download, extract and install DAWN
RUN mkdir /opt/DAWN  \
    && cd /opt/DAWN \
    && wget http://geant4.kek.jp/~tanaka/src/dawn_3_90b.tgz \
    && cd /opt/DAWN \
    && tar -xzf dawn_3_90b.tgz \
    && rm dawn_3_90b.tgz \
    && cd /opt/DAWN/dawn_3_90b \
    && DAWN_PS_PREVIEWER="NONE" \
    && make clean \
    && make guiclean \
    && make \
    && make install \
    && chown -R gebicuser:gebicuser /opt/DAWN


# Install GEANT4 Python Environments
RUN cd /opt/geant4.9/geant4.9.6.p04/environments/g4py \
    && sed -e 's/lib64/lib/g' configure > configure_edit_lib64 \
    && sed -e 's/python3.3/python3.4 python3.3/g' configure_edit_lib64 > configure_edit_lib64_python34 \
    && chmod +x configure_edit_lib64_python34 \
    && cp -rp /opt/geant4.9/geant4.9.6.p04/environments/g4py /opt/geant4.9/geant4.9.6.p04/environments/g4py27 \
    && cd /opt/geant4.9/geant4.9.6.p04/environments/g4py27 \
    && mkdir -p /opt/geant4.9/geant4.9.6.p04/environments/g4py27/python27 \
    && chown -R gebicuser:gebicuser /opt/geant4.9/geant4.9.6.p04/environments/g4py27/python27 \
    && /bin/bash -c "./configure_edit_lib64_python34 linux64 --enable-openglxm \
        --enable-raytracerx --enable-openglx --with-g4install-dir=/usr/local \
        --with-boost-libdir=/usr/lib/x86_64-linux-gnu \
        --with-boost-python-lib=boost_python-py27 \
        --prefix=/opt/geant4.9/geant4.9.6.p04/environments/g4py27/python27 \
        --with-xercesc-libdir=/usr/lib/x86_64-linux-gnu" \
    && make -j`grep -c processor /proc/cpuinfo` \
    && make install \
    && cp -r /opt/geant4.9/geant4.9.6.p04/environments/g4py27/python27/lib/* /usr/local/lib/python2.7/dist-packages/

# Boot and gebic source container with GEANT4 started
WORKDIR /gebic

# Download gebic-gelatuca code from repository
RUN cd /gebic && git clone https://github.com/ncastello/gebic-gelatuca.git \
    && cd gebic-gelatuca && mkdir build && cd build \
    && cmake .. && make install \

# Download gebic-gelatuca code from repository
RUN cd /gebic && git clone https://github.com/ncastello/gebic-georoel.git \
    && cd gebic-gelatuca && mkdir build && cd build \
    && cmake .. && make install \
    && chown -R gebicuser:gebicuser /gebic

USER gebicuser

ENV HOME /home/gebicuser
ENV PATH="${PATH}:/gebic/gebic-gelatuca/bin:/gebic/gebic-georoel/bin"

ENTRYPOINT ["/bin/bash"]


