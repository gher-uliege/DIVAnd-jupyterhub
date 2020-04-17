#!/usr/bin/env julia                                                                                                                              

using PackageCompiler

run(`julia  --trace-compile=DIVAnd_trace_compile.jl DIVAnd_precompile_script.jl`)

PackageCompiler.create_sysimage(
    [:DIVAnd];
    sysimage_path="sysimg_DIVAnd.so",
    #precompile_execution_file="make_sysimg_commands.jl")                                                                                         
    precompile_statements_file="DIVAnd_trace_compile.jl")




