import md5
import logging
import tornado.httpserver
import tornado.ioloop
import tornado.options
import tornado.web

from tornado.options import define, options

define("port", default=8888, help="REST server port", type=int)

class MainHandler(tornado.web.RequestHandler):
    def initialize(self):
        self.set_header("Server", "REST1.0")
        self.set_header("Content-Type", "text/plain; charset=UTF-8")

    def get(self):
        k = self.get_argument("key")
        m = md5.new()
        m.update(k)
        d = m.hexdigest()    
        s = (int(d, 16) % 3) + 1
        server = "server%d" % s
        logging.info("MAP: key=%s (%s) to upstream=%s" % (k, d, server))        
        self.write("REST:%s:REST" % server)


def main():
    tornado.options.parse_command_line()
    application = tornado.web.Application([
        (r"/", MainHandler),
    ])
    http_server = tornado.httpserver.HTTPServer(application)
    http_server.listen(options.port)
    tornado.ioloop.IOLoop.instance().start()


if __name__ == "__main__":
    main()
