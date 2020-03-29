function listFunctions(_module::Module)
    _names = names(_module; all=true)

    _functions = Function[]
    for _name in _names
        _function = getfield(_module, _name)
        if (
            typeof(_function) <: Function
         && !occursin("#",string(_name))
         && !(string(_function) in ["eval","include"])
         )
            push!(_functions, _function)
        end
    end

    _functions
end



function listMethods(_module::Module)
    _functions = listFunctions(_module)
    _methods = Method[]
    for _f in _functions
        _methodList = methods(_f)
        push!(_methods,_methodList.ms...)
    end
    _methods
end

function createDefaultArguments(method)
    @info "Create default arguments for method[$(method.name)]"
    sig = collect(method.sig.types)
    popfirst!(sig)

    argsAsVector = []
    for _type in sig
        push!(argsAsVector,
              createDefaultObject(getNonMissingTypeOfUnionType(_type)))
    end
    argsAsVector
end

function createDefaultObject(_type::DataType)

    if _type <: Number
        return _type(0)
    end
    if _type <: String
        return "lorem ipsum"
    end
    if _type <: Date
        return today()
    end
    if _type <: Enum
        return first(instances(_type))
    end

    return _type()
end

function createDefaultObject(::Type{Dict})
    return Dict()
end

function invokeMethod(_function::Function, args::Vector, procID::Int64)

    argsTypesForPrinting = join(string.(typeof.(args)),", ")
    @info "Invoke $(_function)($argsTypesForPrinting) on procID[$procID]"

    try
        future = @spawnat procID _function(args...)
        fetch(future)
    catch e
        error(e)
    end
end

function invokeMethod(_method::Method, args::Vector, procID::Int64)
    fct = getfield(_method.module, _method.name)
    invokeMethod(fct, args, procID)
end

function invokeMethodOnAllProcs(_method::Method)
    args = createDefaultArguments(_method)
    for procID in 1:nprocs()
        invokeMethod(_method, args, procID)
    end
end

function invokeMethodsOfModule(_module::Module
                              ;excludeMethods::Vector{Symbol} = Symbol[])

    methods = listMethods(_module)
    filter!(x-> !(x.name in excludeMethods),methods)

    for m in methods
        invokeMethodOnAllProcs(m)
    end
end


# This method exists so that we can call it even without having to test if the
#   argument is a Union
function getNonMissingTypeOfUnionType(arg::Any)
    return arg
end

# NOTE: We cannot say that this method returns a DataType (::DataType) because
#         arrays are not datatypes
function getNonMissingTypeOfUnionType(arg::Union)
    if arg.a != Missing
        return arg.a
    else
        return arg.b
    end
end
