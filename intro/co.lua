co = coroutine.wrap(function (x) print(x) end)
co("alo")

co = coroutine.wrap(function (x)
                        print(x)
                        coroutine.yield()
                        print(2*x)
                    end)
co(20)
co()

co = coroutine.wrap(function ()
                        for i = 1, 10 do 
                            coroutine.yield(i) 
                        end
                        return "fim"
                    end)


for i = 1, 11 do
    print(co())
end