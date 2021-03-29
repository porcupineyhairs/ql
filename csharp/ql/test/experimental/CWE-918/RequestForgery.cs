// semmle-extractor-options: /r:System.Text.RegularExpressions.dll /r:HtmlAgilityPack.dll /r:Microsoft.Extensions.Configuration.dll /r:System.Net.Http.dll /r:Microsoft.Extensions.Logging.dll /r:System.Threading.Tasks.dll /r:Microsoft.AspNetCore.Mvc.dll

using System;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using SsrfChallenge.Models;
using System.Net.Http;
using Microsoft.Extensions.Configuration;
using HtmlAgilityPack;
using System.Text.RegularExpressions;

namespace SsrfChallenge.Controllers
{
    public class HomeController : Controller
    {
        private readonly ILogger<HomeController> _logger;
        private readonly IHttpClientFactory _clientFactory;

        private readonly IConfiguration _config;

        public HomeController(ILogger<HomeController> logger, IHttpClientFactory clientFactory, IConfiguration config)
        {
            _logger = logger;
            _clientFactory = clientFactory;
            _config = config;
        }

        public IActionResult Index()
        {
            return View();
        }

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
