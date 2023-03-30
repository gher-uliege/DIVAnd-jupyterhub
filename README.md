

## Build

```bash
docker build . --no-cache --tag abarth/divand-jupyterhub:$(date --utc +%Y-%m-%dT%H%M)  --tag abarth/divand-jupyterhub:latest
docker push abarth/divand-jupyterhub:latest
```

Link to registery:

https://hub.docker.com/repository/docker/abarth/divand-jupyterhub

## Deploy


```bash
docker pull abarth/divand-jupyterhub:latest
```


## Testing

The docker image is intended to be run with JupyterHub, to test the container locally independently from JupyterHub one can use:

```
docker run -it  -p 8888:8888  abarth/divand-jupyterhub:latest  jupyter-lab
```

## Precompiled DIVAnd with `PackageCompiler`


Load-time of DIVAnd and simple analysis without precompiled image:

```julia
julia> @time using DIVAnd
@time include(joinpath(dirname(pathof(DIVAnd)),"..","test","test_product.jl"))
  6.423211 seconds (11.08 M allocations: 549.436 MiB, 2.36% gc time)

julia> @time include(joinpath(dirname(pathof(DIVAnd)),"..","test","test_product.jl"))
[ Info: download bathymetry /home/jovyan/.julia/packages/DIVAnd/gsgEt/test/../../DIVAnd-example-data/Global/Bathymetry/gebco_30sec_16.nc
[ Info: download observations /home/jovyan/.julia/packages/DIVAnd/gsgEt/test/../../DIVAnd-example-data/Provencal/WOD-Salinity.nc
188.275971 seconds (754.34 M allocations: 49.429 GiB, 7.16% gc time)
```

When you first load and run a package in a session, Julia needs to compile it first. This creates some overhead on first use with can be removed by using a precompiled image:


```julia
julia> @time using DIVAnd
  0.000500 seconds (226 allocations: 12.203 KiB)

julia> @time include(joinpath(dirname(pathof(DIVAnd)),"..","test","test_product.jl"))
[ Info: download bathymetry /home/jovyan/.julia/packages/DIVAnd/gsgEt/test/../../DIVAnd-example-data/Global/Bathymetry/gebco_30sec_16.nc
[ Info: download observations /home/jovyan/.julia/packages/DIVAnd/gsgEt/test/../../DIVAnd-example-data/Provencal/WOD-Salinity.nc
 80.839016 seconds (472.02 M allocations: 35.777 GiB, 11.47% gc time)
```
