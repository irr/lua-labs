local ffi = require "ffi"
local C = ffi.C

 ffi.cdef [[
    int mkdir (const char * path, int mode);
    int system(const char *command);
    char * strerror(int errnum);
]]

function mkdir (path, mode)
    if not mode then
        mode = 0x1FF
    end
    local rc = C.mkdir(path, mode)
    if rc ~= 0 then
        return false, string(C.strerror (ffi.errno()))
    end
    return true
end

function system(command)
    return C.system(command)
end

os.execute("rm -rf /tmp/irr")

print(mkdir("/tmp/irr"))

print(system("ls /tmp/irr2 &> /dev/null"))

