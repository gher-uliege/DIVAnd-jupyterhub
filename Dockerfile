# build as:
# sudo docker build  --tag abarth/divand-jupyterhub:$(date --utc +%Y-%m-%dT%H%M)  --tag abarth/divand-jupyterhub:latest .


FROM jupyterhub/singleuser:3.1

MAINTAINER Alexander Barth <a.barth@ulg.ac.be>

EXPOSE 8888

USER root

RUN apt-get update
RUN apt-get install -y libnetcdf-dev netcdf-bin unzip
RUN apt-get install -y ca-certificates curl libnlopt0 make gcc 
RUN apt-get install -y emacs-nox git g++

# ENV JUPYTER /opt/conda/bin/jupyter
# ENV LD_LIBRARY_PATH /opt/conda/lib/

# RUN conda install -c conda-forge ncurses
# RUN conda update -n base -c conda-forge conda
# RUN conda install -y ipywidgets
# RUN conda install -c conda-forge jupyterlab-git

# RUN wget -O /usr/share/emacs/site-lisp/julia-mode.el https://raw.githubusercontent.com/JuliaEditorSupport/julia-emacs/master/julia-mode.el

# Install julia
# RUN rm -r /home/jovyan/.julia
RUN curl -fsSL https://install.julialang.org | sh -s -- --yes --default-channel lts 
# RUN ln -s /home/jovyan/.juliaup/bin/julia /usr/local/bin
# RUN ln -s /home/jovyan/.juliaup/bin/juliaup /usr/local/bin
ENV PATH="/home/jovyan/.juliaup/bin:$PATH"
RUN chown jovyan:users -R /home/jovyan/.juliaup
RUN chown jovyan:users -R /home/jovyan/.julia
RUN juliaup self update
# RUN cat /home/jovyan/.juliaup/juliaupself.json 

# install packages as user (to that the user can temporarily update them if necessary)
# and precompilation

USER jovyan

ENV LD_LIBRARY_PATH=
ENV JULIA_PACKAGES="CairoMakie ColorSchemes Compat CSV DataAssim DIVAnd DataFrames DataStructures DelimitedFiles FFTW FileIO GeoArrays GeoDatasets GeoJSON GeoMakie GeometryOps GeometryTypes Glob GRIB HTTP IJulia ImageIO Images Interpolations JSON JupyterFormatter MAT Makie Missings NCDatasets PackageCompiler PhysOcean Roots SpecialFunctions StableRNGs Statistics TIFFDatasets VectorizationBase VideoIO"

RUN julia --eval 'using Pkg; Pkg.add(split(ENV["JULIA_PACKAGES"]))'

USER root
# avoid warning
# curl: /opt/conda/lib/libcurl.so.4: no version information available (required by curl)
RUN mv -i /opt/conda/lib/libcurl.so.4 /opt/conda/lib/libcurl.so.4-conda

# remove unused kernel
RUN rm -R /opt/conda/share/jupyter/kernels/python3

# Download notebooks
RUN mkdir -p /home/$NB_USER/
RUN cd   /home/$NB_USER/;  \
    wget -O master.zip https://github.com/gher-uliege/Diva-Workshops/archive/master.zip; unzip master.zip; \
    rm /home/$NB_USER/master.zip
 
RUN mv /home/$NB_USER/Diva-Workshops-main/notebooks /home/$NB_USER
RUN rm -r /home/$NB_USER/Diva-Workshops-main

USER jovyan
ADD emacs /home/jovyan/.emacs
RUN mkdir -p /home/jovyan/.julia/config
ADD startup.jl /home/jovyan/.julia/config/startup.jl

RUN julia --eval 'using Pkg; Pkg.precompile()'

USER root
# Example Data
RUN mkdir /data
RUN mkdir -pv /home/jovyan/notebooks/data
RUN mkdir -pv /home/jovyan/notebooks/figures
RUN mkdir -pv /home/jovyan/notebooks/output
RUN mkdir -pv /data/Diva-Workshops-data
RUN chown jovyan:users -R /home/jovyan/notebooks/data
RUN chown jovyan:users -R /home/jovyan/notebooks/figures
RUN chown jovyan:users -R /home/jovyan/notebooks/output
RUN curl https://dox.ulg.ac.be/index.php/s/Px6r7MPlpXAePB2/download | tar -C /data/Diva-Workshops-data -zxf -
RUN ln -s /opt/julia-* /opt/julia

USER jovyan

RUN julia -e 'using IJulia; IJulia.installkernel("Julia with 4 CPUs",env = Dict("JULIA_NUM_THREADS" => "4"))'


# Pre-compiled image with PackageCompiler
# RUN julia --eval 'using Pkg; Pkg.add("PackageCompiler")'
# ADD DIVAnd_precompile_script.jl .
# ADD make_sysimg.sh .
# RUN ./make_sysimg.sh
# RUN mkdir -p /home/jovyan/.local
# RUN mv sysimg_DIVAnd.so DIVAnd_precompile_script.jl make_sysimg.sh  DIVAnd_trace_compile.jl  /home/jovyan/.local
# RUN rm -f test.xml Water_body_Salinity.3Danl.nc Water_body_Salinity.4Danl.cdi_import_errors_test.csv Water_body_Salinity.4Danl.nc Water_body_Salinity2.4Danl.nc
# RUN julia -e 'using IJulia; IJulia.installkernel("Julia-DIVAnd precompiled", "--sysimage=/home/jovyan/.local/sysimg_DIVAnd.so")'
# RUN julia -e 'using IJulia; IJulia.installkernel("Julia-DIVAnd precompiled, 4 CPUs)", "--sysimage=/home/jovyan/.local/sysimg_DIVAnd.so",env = Dict("JULIA_NUM_THREADS" => "4"))'

#ENV JUPYTER_ENABLE_LAB yes

USER root
ADD run_galaxy.sh /usr/local/bin/run_galaxy.sh
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

# issue https://github.com/gher-uliege/DIVAnd-jupyterhub/issues/6
# This should not be necessary anymore for julia 1.9
# We are assuming the python is compiled with a newer libstdc++ than julia
# (otherwise the file should not be removed)
# RUN ["/bin/sh","-c","rm /opt/julia-1.8.*/lib/julia/libstdc++.so.*"]

CMD ["bash", "/usr/local/bin/run_galaxy.sh"]
