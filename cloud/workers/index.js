export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    const urlPath = url.pathname;
    const query = url.search;
    let scheme, count;

    if (urlPath == "/") {
      return new Response("Hello world!", { status: 200 });
  
    } else {
      if (urlPath.startsWith("/http/")) {
        scheme = "http";
        count = 6;

      } else if (urlPath.startsWith("/https/")) {
        scheme = "https";
        count = 7;

      } else {
        return new Response("404 Not Found", { status: 404 });
      }

      const newURL = new URL(scheme + "://" + (urlPath + query).substring(count));
      const newRequest = new Request(newURL, request);
      newRequest.headers.set("X-Forwarded-For", "");
      newRequest.headers.set("X-Real-IP", "");
      return await fetch(newRequest);
    }
  }
}
