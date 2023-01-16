using DemoApp.Contexts;
using DemoApp.Services;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Configuration;
using Microsoft.Azure.Functions.Worker;

var host = new HostBuilder()
	.ConfigureFunctionsWorkerDefaults(builder => {
		builder.AddApplicationInsights()
				.AddApplicationInsightsLogger();
	})
	.ConfigureServices((ctx, services) => {
		services.AddTransient<BookService>();
		services.AddDbContext<BookDb>(opt => opt.UseSqlServer(ctx.Configuration.GetConnectionString("SqlDb")));
	})
	.Build();

using var booksDb = host.Services.GetRequiredService<BookDb>();
await booksDb.Database.EnsureCreatedAsync();

await host.RunAsync();
