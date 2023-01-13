using DemoApp.Helpers;
using DemoApp.Models;
using DemoApp.Services;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.Extensions.Logging;

namespace DemoApp;

public class HttpFunctions
{
    private readonly BookService _bookSvc;
    private readonly ILogger _logger;

    public HttpFunctions(BookService bookSvc, ILoggerFactory loggerFactory)
    {
        _bookSvc = bookSvc;
        _logger = loggerFactory.CreateLogger<HttpFunctions>();
    }

    [Function(nameof(ListBooks))]
    public async Task<HttpResponseData> ListBooks([HttpTrigger(AuthorizationLevel.Anonymous, "get", Route = "books")] HttpRequestData req)
        => req.Ok(await _bookSvc.ListBooksAsync());

    [Function(nameof(GetBook))]
    public async Task<HttpResponseData> GetBook([HttpTrigger(AuthorizationLevel.Anonymous, "get", Route = "book/{id:int}")] HttpRequestData req, int id)
        => await _bookSvc.GetBookAsync(id) switch
        {
            null => req.NotFound(),
            Book b => req.Ok(b)
        };

    [Function(nameof(LongCall))]
    public Task<HttpResponseData> LongCall([HttpTrigger(AuthorizationLevel.Anonymous, "get", Route = "longcall")] HttpRequestData req)
        => Task.Delay(500).ContinueWith(x => req.Ok());

    [Function(nameof(AddMoreBooks))]
    public Task<HttpResponseData> AddMoreBooks([HttpTrigger(AuthorizationLevel.Anonymous, "get", Route = "addbooks")] HttpRequestData req)
        => _bookSvc.AddRandomBooksAsync(100).ContinueWith(x => req.Ok());
}