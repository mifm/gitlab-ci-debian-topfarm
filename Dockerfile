# Docker file for gitlab CI test image

FROM buildpack-deps:jessie

MAINTAINER Frederik Zahle <frza@dtu.dk>

ENV SHELL /bin/bash
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:/usr/local/lib
ENV CONDA_ENV_PATH /opt/miniconda
ENV PATH $CONDA_ENV_PATH/bin:$PATH

RUN apt-get update \
 && apt-get install --fix-missing -y -q \
    gfortran \
    git-all \
    curl \
    build-essential libhdf5-8 libhdf5-dev \
 && apt-get autoremove -y \
 && apt-get clean -y
RUN wget https://www.open-mpi.org/software/ompi/v1.6/downloads/openmpi-1.6.5.tar.gz \
  && tar -xzf openmpi-1.6.5.tar.gz \
  && cd openmpi-1.6.5 \
  && ./configure --prefix=/usr/local --disable-dlopen \
  && make all install

# Install miniconda to /miniconda
RUN wget --quiet \
    https://repo.continuum.io/miniconda/Miniconda-latest-Linux-x86_64.sh && \
    bash Miniconda-latest-Linux-x86_64.sh -b -p $CONDA_ENV_PATH && \
    rm Miniconda-latest-Linux-x86_64.sh && \
    chmod -R a+rx $CONDA_ENV_PATH
RUN conda update --quiet --yes conda \
  && conda create -y -n py35 python=3.5 \
  && conda create -y -n py27 python=2.7 \
  && /bin/bash -c "source activate py27 \
  && conda install pip numpy scipy nose hdf5" \
  && /bin/bash -c "source activate py35 \
  && conda install pip numpy scipy nose hdf5"

RUN echo 'ulimit -s unlimited' >> .bashrc
