Dockerfile:
MAINTAINER VIB Bioinformatics Core <bits@vib.be>

# get the debian image as starting point - consider removing to make things lighter:
FROM debian:jessie

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

RUN apt-get update --fix-missing && apt-get install -y wget bzip2 ca-certificates \
   libglib2.0-0 libxext6 libsm6 libxrender1 \
   r-base\
   git mercurial subversion

# Useful stuff to edit things once the image is created (debugging)
# RUN apt-get update && apt-get install -y \
#   less \
#   vim
  
# Add required R packages: 
ADD ./R_packages/ /R_packages/

# Install Dependencies first...
RUN Rscript -e "install.packages(c('RColorBrewer','scales'), repos='http://cran.rstudio.com/')"
RUN Rscript -e "install.packages(c('plyr', 'gtable', 'reshape2', 'scales', 'proto', 'digest'), repos='http://cran.rstudio.com/')"

# ... Then packages
RUN R CMD INSTALL /R_packages/ggplot2_1.0.1.tar.gz
RUN R CMD INSTALL /R_packages/gridExtra_0.9.1.tar.gz
RUN rm -rf /R_packages


####### replace here for a dedicated veroion - add line of variable to set: 
ENV CONDA_VERSION 4.5.1
RUN wget --quiet https://repo.continuum.io/miniconda/Miniconda3-${CONDA_VERSION}-Linux-x86_64.sh -O ~/miniconda.sh && \
   /bin/bash ~/miniconda.sh -b -p /opt/conda && \
   rm ~/miniconda.sh && \
   /opt/conda/bin/conda clean -tipsy && \
   ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
   echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
   echo "conda activate base" >> ~/.bashrc



ENV TINI_VERSION v0.16.1
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /usr/bin/tini

RUN chmod +x /usr/bin/tini

ENV PATH /opt/conda/bin:$PATH
RUN conda config --add channels conda-forge
#### check if we need to add version to MOFA
RUN pip install git+git://github.com/PMBio/MOFA

RUN R -e " \
devtools::install_github('PMBio/MOFA', subdir='MOFAtools'); \
"