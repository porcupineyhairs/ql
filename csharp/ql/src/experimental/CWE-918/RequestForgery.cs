namespace RequestForgery.Controllers
{
    public class SSRFController : Controller
    {
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Bad(string url)
        {
            var request = new HttpRequestMessage(HttpMethod.Get, url);

            var client = _clientFactory.CreateClient();
            var response = await client.SendAsync(request);

            return View();
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Good(string url)
        {
            Uri baseUri = new Uri("www.mysecuresite.com/");
            if (baseUri.IsBaseOf(new Uri(url)))
            {
                var request = new HttpRequestMessage(HttpMethod.Get, url);
                var client = _clientFactory.CreateClient();
                var response = await client.SendAsync(request);
            }

            return View();
        }
    }
}
