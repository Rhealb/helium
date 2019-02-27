import os
import sys
import urllib2
import SocketServer
from BaseHTTPServer import BaseHTTPRequestHandler, HTTPServer

BIND_ADDR = os.environ.get("BIND_ADDR", "0.0.0.0")
SERVER_PORT = int(os.environ.get("SERVER_PORT", "80"))
URL_PREFIX = os.environ.get("URL_PREFIX", "").rstrip('/') + '/'
RESOURCE_MANAGER_HOST = ""


class ProxyHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        # redirect if we are hitting the home page
        if self.path in ("", URL_PREFIX):
            self.send_response(302)
            self.send_header("Location", URL_PREFIX + "proxy:" + RESOURCE_MANAGER_HOST)
            self.end_headers()
            return
        self.proxyRequest(None)

    def do_POST(self):
        length = int(self.headers.getheader('content-length'))
        postData = self.rfile.read(length)
        self.proxyRequest(postData)

    def proxyRequest(self, data):
        targetHost, path = self.extractUrlDetails(self.path)
        targetUrl = "http://" + targetHost + path

        print("get: " + self.path)
        print("host: " + targetHost)
        print("path: " + path)
        print("target: " + targetUrl)

        targetUrl = str(targetUrl);
        req = urllib2.Request(targetUrl, data);
        req.add_header('Cache-Control', 'no-cache');
        req.add_header('Accept', '*/*');
        req.add_header('Accept-Encoding', 'gzip, deflate, sdch');
        req.add_header('Connection', 'Keep-Alive');
        proxiedRequest = urllib2.urlopen(req);

        resCode = proxiedRequest.getcode()

        if resCode == 200:
            page = proxiedRequest.read()
            page = self.rewriteLinks(page, targetHost)
            self.send_response(200)
            if proxiedRequest.info().getheader('Content-Encoding') is not None:
                self.send_header('Content-Encoding', proxiedRequest.info().getheader('Content-Encoding'))
            self.end_headers()
            self.wfile.write(page)
        elif resCode == 302:
            self.send_response(302)
            self.send_header("Location", URL_PREFIX + "proxy:" + RESOURCE_MANAGER_HOST)
            self.end_headers()
        else:
            raise Exception("Unsupported response: " + resCode)

    def extractUrlDetails(self, path):
        if path.startswith(URL_PREFIX + "proxy:"):
            start_idx = len(URL_PREFIX) + 6  # len('proxy:') == 6
            idx = path.find("/", start_idx)
            targetHost = path[start_idx:] if idx == -1 else path[start_idx:idx]
            path = "" if idx == -1 else path[idx:]
        else:
            targetHost = RESOURCE_MANAGER_HOST
            path = path
        return (targetHost, path)

    def rewriteLinks(self, page, targetHost):
        target = "{0}proxy:{1}/".format(URL_PREFIX, targetHost)
        page = page.replace('href="//', 'href="$$$')
        page = page.replace('href="/', 'href="' + target)
        page = page.replace('href="$$$', 'href="/proxy:')
        page = page.replace('href="log', 'href="' + target + 'log')
        page = page.replace('href="http://', 'href="' + URL_PREFIX + 'proxy:')
        page = page.replace("href='http://", "href='" + URL_PREFIX + 'proxy:')
        page = page.replace('src="/', 'src="' + target)
        page = page.replace('action="', 'action="' + target)
        page = page.replace('"/api/v1/', '"' + target + 'api/v1/')
        return page


if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Usage: <proxied host:port> [<proxy port>]")
        sys.exit(1)

    RESOURCE_MANAGER_HOST = sys.argv[1]

    if len(sys.argv) >= 3:
        SERVER_PORT = int(sys.argv[2])

    print("Starting server on http://{0}:{1}".format(BIND_ADDR, SERVER_PORT))

    class ForkingHTTPServer(SocketServer.ForkingMixIn, HTTPServer):
        def finish_request(self, request, client_address):
            request.settimeout(30)
            HTTPServer.finish_request(self, request, client_address)

    server_address = (BIND_ADDR, SERVER_PORT)
    httpd = ForkingHTTPServer(server_address, ProxyHandler)
    httpd.serve_forever()