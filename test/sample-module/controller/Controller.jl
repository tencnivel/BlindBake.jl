function greeting(user::AppUser)
    println("Hello [$(user.lastname)]")
end

function greeting(user::AppUser, date::Date)
    println("Hello[$(user.lastname)] on[$date]")
end

function function1()
    println("In function1")
end
