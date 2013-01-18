import md5
import logging
import memcache
import tornado.httpserver
import tornado.ioloop
import tornado.options
import tornado.web

from tornado.options import define, options

define("port", default=8888, help="REST server port", type=int)

def log(tag, headers, msg):    
    logging.info("%s: headers=%s" % (tag, headers))
    logging.info("%s: msg=%s" % (tag, msg))

class MainHandler(tornado.web.RequestHandler):
    def initialize(self):
        self.tag = "REST1.0"
        self.set_header("Server", self.tag)
        self.set_header("Content-Type", "text/plain; charset=UTF-8")

    def get(self):
        k = self.get_argument("key")
        s = "called with key=%s" % (k, )
        log(self.tag, self.request.headers, s)        
        self.write(s)

class MapHandler(tornado.web.RequestHandler):
    def initialize(self):
        self.tag = "REST1.0"
        self.set_header("Server", self.tag)
        self.set_header("Content-Type", "text/plain; charset=UTF-8")
        self.mc = memcache.Client(['127.0.0.1:11211'])

    def get(self):
        k = self.get_argument("key")
        m = md5.new()
        m.update(k)
        d = m.hexdigest()    
        s = (int(d, 16) % 3) + 1
        server = "server%d" % s
        self.mc.set(k.encode("ISO-8859-1"), server)
        log(self.tag, self.request.headers, "key=%s (%s) to upstream=%s" % (k, d, server))        
        self.write("REST:%s:REST" % server)

def main():
    tornado.options.parse_command_line()
    application = tornado.web.Application([
        (r"/", MainHandler),
        (r"/map", MapHandler),
    ])
    http_server = tornado.httpserver.HTTPServer(application, xheaders=True)
    http_server.bind(options.port)
    http_server.start(tornado.process.cpu_count())
    tornado.ioloop.IOLoop.instance().start()


if __name__ == "__main__":
    main()
