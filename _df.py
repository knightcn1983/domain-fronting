import logging
from dataclasses import dataclass

from mitmproxy.addonmanager import Loader
from mitmproxy.http import HTTPFlow


@dataclass
class Mapping:
    server: str
    port: int


class HttpsDomainFronting:
    # configurations for regular ("example.com") mappings:
    host_mappings: dict[str, Mapping]

    # Configurations for star ("*.example.com") mappings:
    star_mappings: dict[str, Mapping]

    def __init__(self) -> None:
        self.host_mappings = {}
        self.star_mappings = {}
        self._load_df_hosts()

    def _resolve_addresses(self, host: str) -> Mapping | None:
        mapping = self.host_mappings.get(host)
        if mapping is not None:
            return mapping

        index = 0
        while True:
            index = host.find(".", index)
            if index == -1:
                break
            super_domain = host[(index + 1) :]
            mapping = self.star_mappings.get(super_domain)
            if mapping is not None:
                return mapping
            index += 1

        return None

    def _load_df_hosts(self) -> None:
        host_mappings: dict[str, Mapping] = {}
        star_mappings: dict[str, Mapping] = {}
        for mapping in df_hosts["mappings"]:
            item = Mapping(
                        server=mapping.get("server"), 
                        port=mapping.get("port")
                   )
            for pattern in mapping["patterns"]:
                if pattern.startswith("*."):
                    star_mappings[pattern[2:]] = item
                else:
                    host_mappings[pattern] = item
        self.host_mappings = host_mappings
        self.star_mappings = star_mappings

    def load(self, loader: Loader) -> None:
        loader.add_option(
            name="connection_strategy",
            typespec=str,
            default="lazy",
            help="set connection strategy to lazy",
        )

    def _is_proxy_host(self, host: str) -> bool:
        if host in proxy_hosts:
            return True

        index = 0
        while True:
            index = host.find(".", index)
            if index == -1:
                break
            super_domain = host[(index + 1) :]
            if super_domain in proxy_hosts:
                return True
            index += 1

        return False

    def responseheaders(self, flow: HTTPFlow) -> None:
        flow.response.stream = True

    def request(self, flow: HTTPFlow) -> None:
        # We use the host header to dispatch the request:
        target = flow.request.host_header
        if target is None:
            return

        scheme = flow.request.scheme
        if scheme == "https":
            # try domain fronting first
            mapping = self._resolve_addresses(target)
            if mapping is not None:
                logging.info(f"domain fronting for: {target}")
                flow.request.host = mapping.server
                flow.request.port = mapping.port
                flow.request.host_header = target
                return

        if SERVER is not None and self._is_proxy_host(target):
            if scheme == "https":
                url_prefix = "/https/"
            else:
                url_prefix = "/http/"
            logging.info(f"cloud proxy for: {target} {scheme}")
            url = f"https://{SERVER}:{PORT}{url_prefix}{target}{flow.request.path}"
            flow.request.url = url

        else:
            logging.info(f"direct connect for: {target}")


addons = [HttpsDomainFronting()]

