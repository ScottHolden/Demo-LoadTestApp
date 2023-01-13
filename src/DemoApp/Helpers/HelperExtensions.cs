using Microsoft.Azure.Functions.Worker.Http;
using System.Net;
using System.Text.Json;
using System.Text.Json.Serialization;

namespace DemoApp.Helpers;

public static class HelperExtensions
{
	public static HttpResponseData Ok(this HttpRequestData req, string? body = null)
	{
		var response = req.CreateResponse(HttpStatusCode.OK);

		if (!string.IsNullOrEmpty(body))
		{
			response.Headers.Add("Content-Type", "text/plain; charset=utf-8");
			response.WriteString(body);
		} 

		return response;
	}

	public static HttpResponseData Ok<T>(this HttpRequestData req, T body)
	{
		var response = req.CreateResponse(HttpStatusCode.OK);

		response.Headers.Add("Content-Type", "application/json");
		response.WriteString(JsonSerializer.Serialize(body));

		return response;
	}

	public static HttpResponseData NotFound(this HttpRequestData req)
		=> req.CreateResponse(HttpStatusCode.NotFound);
}
