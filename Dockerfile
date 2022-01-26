# build as:
# sudo docker build  --tag abarth/divand-jupyterhub:$(date --utc +%Y-%m-%dT%H%M)  --tag abarth/divand-jupyterhub:latest .


FROM jupyterhub/singleuser:2.0

MAINTAINER Alexander Barth <a.barth@ulg.ac.be>

EXPOSE 8888

USER root

RUN apt-get update
RUN apt-get install -y libnetcdf-dev netcdf-bin unzip
RUN apt-get install -y ca-certificates curl libnlopt0 make gcc 
RUN apt-get install -y emacs-nox git g++

ENV JUPYTER /opt/conda/bin/jupyter
ENV PYTHON /opt/conda/bin/python
ENV LD_LIBRARY_PATH /opt/conda/lib/

RUN conda install -y ipywidgets
RUN conda install -y matplotlib
RUN conda install -c conda-forge jupyterlab-git

RUN wget -O /usr/share/emacs/site-lisp/julia-mode.el https://raw.githubusercontent.com/JuliaEditorSupport/julia-emacs/master/julia-mode.el

# Install julia
ADD install_julia.sh .
RUN bash install_julia.sh; rm install_julia.sh

# install packages as user (to that the user can temporarily update them if necessary)
# and precompilation

USER jovyan

ENV LD_LIBRARY_PATH=
ENV JULIA_PACKAGES="CSV DataAssim DIVAnd DataStructures FFTW FileIO Glob HTTP IJulia ImageIO Images Interact Interpolations JSON Knet MAT Missings NCDatasets PackageCompiler PhysOcean PyCall PyPlot Roots SpecialFunctions StableRNGs VideoIO"

RUN julia --eval 'using Pkg; Pkg.add(split(ENV["JULIA_PACKAGES"]))'


USER root
# avoid warning
# curl: /opt/conda/lib/libcurl.so.4: no version information available (required by curl)
RUN mv -i /opt/conda/lib/libcurl.so.4 /opt/conda/lib/libcurl.so.4-conda

# remove unused kernel
RUN rm -R /opt/conda/share/jupyter/kernels/python3

# Download notebooks
RUN mkdir /data
RUN cd   /data;  \
    wget -O master.zip https://github.com/gher-ulg/Diva-Workshops/archive/master.zip; unzip master.zip; \
    rm /data/master.zip

USER jovyan
ADD emacs /home/jovyan/.emacs
RUN mkdir -p /home/jovyan/.julia/config
ADD startup.jl /home/jovyan/.julia/config/startup.jl

RUN julia --eval 'using Pkg; pkg"precompile"'

USER root
# Example Data
RUN mkdir /data/Diva-Workshops-data
RUN curl https://dox.ulg.ac.be/index.php/s/Px6r7MPlpXAePB2/download | tar -C /data/Diva-Workshops-data -zxf -
RUN ln -s /opt/julia-* /opt/julia

USER jovyan

RUN julia -e 'using IJulia; IJulia.installkernel("Julia with 4 CPUs",env = Dict("JULIA_NUM_THREADS" => "4"))'


# Pre-compiled image with PackageCompiler
RUN julia --eval 'using Pkg; pkg"add PackageCompiler"'
ADD DIVAnd_precompile_script.jl .
ADD make_sysimg.sh .
RUN ./make_sysimg.sh
RUN mkdir -p /home/jovyan/.local
RUN mv sysimg_DIVAnd.so DIVAnd_precompile_script.jl make_sysimg.sh  DIVAnd_trace_compile.jl  /home/jovyan/.local
RUN rm -f test.xml Water_body_Salinity.3Danl.nc Water_body_Salinity.4Danl.cdi_import_errors_test.csv Water_body_Salinity.4Danl.nc Water_body_Salinity2.4Danl.nc
RUN julia -e 'using IJulia; IJulia.installkernel("Julia-DIVAnd precompiled", "--sysimage=/home/jovyan/.local/sysimg_DIVAnd.so")'
RUN julia -e 'using IJulia; IJulia.installkernel("Julia-DIVAnd precompiled, 4 CPUs)", "--sysimage=/home/jovyan/.local/sysimg_DIVAnd.so",env = Dict("JULIA_NUM_THREADS" => "4"))'

#ENV JUPYTER_ENABLE_LAB yes



USER root
ADD run.sh /usr/local/bin/run.sh
USER jovyan

## use 33 (www-data) as nextcloud
#USER root
## user id 33 -> 200 (unused)
#RUN usermod -u 200 www-data
#RUN groupmod -g 200 www-data
## user id 1000 -> 33
#RUN usermod -u 33 jovyan
#RUN find /home /var /tmp -user 1000 -exec chown 33.100 {} \;
#RUN find /home /var /tmp -user 33 -exec chown 200.200 {} \;
##RUN ls -ld /home
#USER jovyan


COPY ./healthcheck_notebook.sh /bin/healthcheck.sh
HEALTHCHECK --interval=30s --timeout=10s CMD /bin/healthcheck.sh

CMD ["bash", "/usr/local/bin/run.sh"]
