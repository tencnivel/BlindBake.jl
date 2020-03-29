mutable struct AppUser
    id::Union{Missing,String}
    login::Union{Missing,String}
    password::Union{Missing,String}
    lastname::Union{Missing,String}
    firstname::Union{Missing,String}
    email::Union{Missing,String}


    # Convenience constructor that allows us to create a vector of instances
    #   from a JuliaDB.table using the dot syntax: `Myclass.(a_JuliaDB_table)`
    AppUser(args::NamedTuple) = AppUser(;args...)
    AppUser(;id = missing,
             login = missing,
             password = missing,
             lastname = missing,
             firstname = missing,
             email = missing) = (
                  # First call the default constructor with missing values only so that
                  #   there is no risk that we don't assign an argument to the wrong attribute
                  x = new(missing,missing,missing,missing,missing,
                          missing);
                  x.id = id;
                  x.login = login;
                  x.password = password;
                  x.lastname = lastname;
                  x.firstname = firstname;
                  x.email = email;

                  return x )

end
