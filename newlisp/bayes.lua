local ffi = require("ffi")
local newlisp = ffi.load("newlisp")

ffi.cdef[[
char* newlispEvalStr(char *cmd);
]]

local lisp = [=[[cmd]
(load "/usr/share/newlisp/modules/zlib.lsp")
(bayes-train (parse (lower-case (zlib:gz-read-file "Doyle.txt.gz")) "[^a-z]+" 0) '() '() 'DDB)
(bayes-train '() (parse (lower-case (zlib:gz-read-file "Dowson.txt.gz")) "[^a-z]+" 0) '() 'DDB)
(bayes-train '() '() (parse (lower-case (zlib:gz-read-file "Beowulf.txt.gz")) "[^a-z]+" 0) 'DDB)
(println "Doyle test : "
(bayes-query (parse "adventures of sherlock holmes") 'DDB true)
(bayes-query (parse "adventures of sherlock holmes") 'DDB))
(println "Downson test: "
(bayes-query (parse "comedy of masks") 'DDB true)
(bayes-query (parse "comedy of masks") 'DDB))
(println "Beowulf test: "
(bayes-query (parse "hrothgar and beowulf") 'DDB true)
(bayes-query (parse "hrothgar and beowulf") 'DDB))
[/cmd]]=]

local code = ffi.new(string.format("char[%d]", #lisp), lisp)
local res = ffi.string(newlisp.newlispEvalStr(code))
print(res)

