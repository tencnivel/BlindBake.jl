# BlindBake.jl

BlindBake is a Julia package that executes every function of a module on every
available core (`from i in 1:nprocs()`) with default mock arguments.
This is useful when one wants to spare the users of a Julia app the lag caused by the compilation of a method when called for the first time on a core.

Depending on your use case, you may find the following packages more useful:

  * https://github.com/timholy/SnoopCompile.jl
  * https://github.com/JuliaLang/PackageCompiler.jl

BlindBake is not redundant with SnoopCompile because BlindBake executes the method when SnoopCompile only precompiles it.

## Installation

`add https://github.com/tencnivel/BlindBake.jl`

## Usage


```
using BlindBake
BlindBake.invokeMethodsOfModule(MyModule)
```

You can use the optional argument to skip some functions:

```
using BlindBake
BlindBake.invokeMethodsOfModule(MyModule
                               ;[function1])
```

Also see `test/runtests.jl`

### HOWTO specify a special default value

Suppose you have a method that expects a `LibPQ.Connection`. In that case you cannot rely on the default `createDefaultObject` because it would invoke
`LibPQ.Connection()` which does not exist.
In that case you will need to declare a new method for `createDefaultObject`.

Example:
```
function BlindBake.createDefaultObject(::Type{LibPQ.Connection})
    conn = LibPQ.Connection("host=localhost
                             port=5432
                             dbname=my_database
                             user=my_user
                             password=my_password
                             "; throw_error=true)
    return conn
end
```

### HOWTO overwrite the way the methods are called

Suppose you have a lot of methods that expects a `LibPQ.Connection`. If the
methods do not handle well the closing of connection when an error occurs, you
may run out of the max number of open connections. In that case you may want to
overwrite `function invoqueMethod(_function::Function, args::Vector, procID::Int64)`

Example:
```
function BlindBake.invoqueMethod(_function::Function, args::Vector, procID::Int64)

    argsTypesForPrinting = join(string.(typeof.(args)),", ")
    @info "Invoque $(_function)($argsTypesForPrinting) on procID[$procID]"

    # This is custom: check if one of the arguments is a Postgresql connection
    dbconn::Union{Missing,LibPQ.Connection} = missing
    for arg in args
        if isa(arg,LibPQ.Connection)
            dbconn = arg
        end
    end

    try
        future = @spawnat procID _function(args...)
        fetch(future)
    catch e
        error(e)
    finally
        # This is custom: Close the connection
        if !ismissing(dbconn)
            close(dbconn)
        end
    end

end
```


## Default values

The default values for the arguments are:

  * For numeric types (i.e. T <: Number): `0`
  * For String: `"Lorem Ipsum"`
  * For Date: `Dates.today()`
  * For Enum: the first possible value of the enum: `first(instances(_type))`
  * For other types: the result of the call to the constructor (eg. `MyStruct()`)

## Limitations

 * Does not compile functions in the submodules
 * Will fail on functions expecting abstract arguments
