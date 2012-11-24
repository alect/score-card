import BaseHTTPServer
import sys
import socket
import traceback

def run(server_class=BaseHTTPServer.HTTPServer,
        handler_class=BaseHTTPServer.BaseHTTPRequestHandler):
    server_address = ('localhost', 8000)
    httpd = server_class(server_address, handler_class)
    httpd.serve_forever()


def build_req():
    req = 'GET /flash/API_AS3_6b71feefd6b6a5f1d55e863385a09c69.swf HTTP/1.1\n'
    req += 'Host: chat.kongregate.com\n'
    req += 'User-Agent:	Mozilla/5.0 (Macintosh; Intel Mac OS X 10.7; rv:16.0) Gecko/20100101 Firefox/16.0\n'
    req += 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8\n'
    req += 'Accept-Language: en-US,en;q=0.5\n'
    req += 'Accept-Encoding: gzip, deflate\n'
    req += 'Connection: keep-alive\n'
    req += 'Referer: http://chat.kongregate.com/gamez/0014/9470/live/RDRQ.swf?kongregate_game_version=1341698093\n'
    req += 'Cookie: __gads=ID=45fd4183ee20b502:T=1341118455:S=ALNI_MYsPABfZ3-CRMjj8AsjQm5KeknBgg\n'
    return req

def send_req(host, port, req):
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    print("Connecting to %s:%d..." % (host, port))
    sock.connect((host, port))

    print("Connected, sending request...")
    print req
    sock.send(req)

    print("Request sent, waiting for reply...")
    rbuf = sock.recv(1024)
    resp = ""
    while len(rbuf):
	resp = resp + rbuf
	rbuf = sock.recv(1024)

    print("Received reply.")
    sock.close()
    return resp


class HTTPProxy(BaseHTTPServer.BaseHTTPRequestHandler):
    def do_GET(self):
        if (self.path=='/kongregate-proxy'):
            swf = send_req('chat.kongregate.com', 80, build_req())
            print swf
            self.wfile.write(swf)
        else:
            self.send_error(404, 'Service not defined')

if __name__ == '__main__':
    run(handler_class=HTTPProxy)
