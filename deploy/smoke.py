import sys
import time
import urllib.request
from html.parser import HTMLParser

class Page(HTMLParser):
    def __init__(self):
        super().__init__()
        self.revision = None
        self.links = []
    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)
        if tag == "meta" and attrs.get("name") == "deployment-revision":
            self.revision = attrs.get("content")
        if tag == "a":
            self.links.append(attrs.get("href", ""))

for attempt in range(12):
    try:
        request = urllib.request.Request("https://provansov.ru/", headers={"Cache-Control": "no-cache"})
        with urllib.request.urlopen(request, timeout=15) as response:
            assert response.status == 200
            page = Page()
            page.feed(response.read().decode("utf-8"))
        assert page.revision == sys.argv[1]
        assert "https://app.provansov.ru" in page.links
        assert not any("127.0.0.1" in link or "localhost" in link for link in page.links)
        print(f"Landing HTTPS: 200; deployed revision: {page.revision}; CRM links: OK")
        break
    except Exception:
        if attempt == 11:
            raise SystemExit("Landing smoke failed: check HTTP status, revision and application links. No rollback performed.")
        time.sleep(3)
