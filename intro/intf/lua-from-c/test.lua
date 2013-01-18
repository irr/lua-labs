-- scons -c && scons && ./test test.lua && scons -c && rm .sconsign.dblite

function msg()
    io.write("\nexecutando lua de dentro de <test.c>...\n")
end

result = (function (x) 
            msg()
            return x + 100 
          end)(10)