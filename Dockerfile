# Docker file for gitlab CI test image

FROM buildpack-deps:jessie

MAINTAINER David Verelst <dave@dtu.dk>

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
  && conda create -y -n py36 python=3.6 \
  && /bin/bash -c "source activate py36 \
  && conda install pip numpy scipy nose hdf5 pandas pytest-cov \
  && conda install -c conda-forge utm --no-deps \
  && pip install sphinx-fortran --no-deps"

RUN echo 'ulimit -s unlimited' >> .bashrc
