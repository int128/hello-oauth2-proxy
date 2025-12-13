CONTAINER := container

all:

.PHONY: nginx
nginx:
	-$(CONTAINER) stop nginx
	-$(CONTAINER) rm nginx
	$(CONTAINER) run --rm --name nginx -v $(CURDIR)/nginx-conf.d:/etc/nginx/conf.d:ro nginx

.PHONY: oauth2-proxy
oauth2-proxy:
	-$(CONTAINER) stop oauth2-proxy
	-$(CONTAINER) rm oauth2-proxy
	$(CONTAINER) run --rm --name oauth2-proxy -v $(CURDIR)/oauth2-proxy:/etc/oauth2-proxy:ro quay.io/oauth2-proxy/oauth2-proxy --config /etc/oauth2-proxy/oauth2-proxy.cfg

.PHONY: clean
clean:
	-$(CONTAINER) stop nginx oauth2-proxy
	-$(CONTAINER) rm nginx oauth2-proxy
