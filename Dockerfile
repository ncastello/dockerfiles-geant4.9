FROM rootproject/root-ubuntu16:latest

LABEL author="nuria.castello.mor@gmail.com" \
    version="1.0" \
    description="Docker image for GEANT4 DAMIC simulation"

USER 0

# uid (-u) and group IDs (-g)
RUN useradd -u 1000 -md /home/ncastello -ms /bin/bash ncastello \
    && usermod -a -G builder ncastello

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
    && echo '. /usr/local/bin/geant4.sh' >> ~ncastello/.bashrc \
    && mkdir -p /data && chown -R ncastello:ncastello /data \
    && chown ncastello:ncastello ~ncastello/.bashrc && chown -R ncastello:ncastello /opt/geant4.9


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
    && chown -R ncastello:ncastello /opt/DAWN


# Install GEANT4 Python Environments
RUN cd /opt/geant4.9/geant4.9.6.p04/environments/g4py \
    && sed -e 's/lib64/lib/g' configure > configure_edit_lib64 \
    && sed -e 's/python3.3/python3.4 python3.3/g' configure_edit_lib64 > configure_edit_lib64_python34 \
    && chmod +x configure_edit_lib64_python34 \
    && cp -rp /opt/geant4.9/geant4.9.6.p04/environments/g4py /opt/geant4.9/geant4.9.6.p04/environments/g4py27 \
    && cd /opt/geant4.9/geant4.9.6.p04/environments/g4py27 \
    && mkdir -p /opt/geant4.9/geant4.9.6.p04/environments/g4py27/python27 \
    && chown -R ncastello:ncastello /opt/geant4.9/geant4.9.6.p04/environments/g4py27/python27 \
    && /bin/bash -c "./configure_edit_lib64_python34 linux64 --enable-openglxm \
        --enable-raytracerx --enable-openglx --with-g4install-dir=/usr/local \
        --with-boost-libdir=/usr/lib/x86_64-linux-gnu \
        --with-boost-python-lib=boost_python-py27 \
        --prefix=/opt/geant4.9/geant4.9.6.p04/environments/g4py27/python27 \
        --with-xercesc-libdir=/usr/lib/x86_64-linux-gnu" \
    && make -j`grep -c processor /proc/cpuinfo` \
    && make install \
    && cp -r /opt/geant4.9/geant4.9.6.p04/environments/g4py27/python27/lib/* /usr/local/lib/python2.7/dist-packages/


USER ncastello

#RUN cd ~/GEANT4/source/geant4.9.6.p04/environments/g4py; \
#    mkdir -p ~/GEANT4/source/geant4.9.6.p04/environments/g4py/python34; \
#    ./configure_edit_lib64_python34 linux64 --with-python3 --enable-openglxm \
#    --enable-raytracerx --enable-openglx --with-g4install-dir=/usr/local \
#    --with-boost-libdir=/usr/lib/x86_64-linux-gnu \
#    --with-boost-python-lib=boost_python-py34 \
#    --prefix=~/GEANT4/source/geant4.9.6.p04/environments/g4py/python34; \
#    make -j`grep -c processor /proc/cpuinfo`; \
#    make install; \
#    cd ~/GEANT4/source/geant4.9.6.p04/environments/g4py/python34/lib/Geant4; \
#    python3 -c 'import py_compile; py_compile.compile( \"colortable.py\" )'; \
#    python3 -c 'import py_compile; py_compile.compile( \"g4thread.py\" )'; \
#    python3 -c 'import py_compile; py_compile.compile( \"g4viscp.py\" )'; \
#    python3 -c 'import py_compile; py_compile.compile( \"hepunit.py\" )'; \
#    python3 -c 'import py_compile; py_compile.compile( \"__init__.py\" )'; \
#    python3 -O -c 'import py_compile; py_compile.compile( \"colortable.py\" )'; \
#    python3 -O -c 'import py_compile; py_compile.compile( \"g4thread.py\" )'; \
#    python3 -O -c 'import py_compile; py_compile.compile( \"g4viscp.py\" )'; \
#    python3 -O -c 'import py_compile; py_compile.compile( \"hepunit.py\" )'; \
#    python3 -O -c 'import py_compile; py_compile.compile( \"__init__.py\" )'; \
#    cd ~/GEANT4/source/geant4.9.6.p04/environments/g4py/python34/lib/g4py; \
#    python3 -c 'import py_compile; py_compile.compile( \"emcalculator.py\" )'; \
#    python3 -O -c 'import py_compile; py_compile.compile( \"emcalculator.py\" )'; \
#    python3 -c 'import py_compile; py_compile.compile( \"mcscore.py\" )'; \
#    python3 -O -c 'import py_compile; py_compile.compile( \"mcscore.py\" )'; \
#    python3 -c 'import py_compile; py_compile.compile( \"__init__.py\" )'; \
#    python3 -O -c 'import py_compile; py_compile.compile( \"__init__.py\" )'; \
#    cp -r ~/GEANT4/source/geant4.9.6.p04/environments/g4py/python34/lib/* /usr/local/lib/python3.4/dist-packages/


# Boot container with GEANT4 started
WORKDIR /damic_geant4

ENV HOME /home/ncastello

ENTRYPOINT ["/bin/bash"]


