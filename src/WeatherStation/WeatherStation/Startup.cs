using Microsoft.Azure.Cosmos;
using Microsoft.Azure.Functions.Extensions.DependencyInjection;
using Microsoft.Extensions.Azure;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WeatherStation;
using WeatherStation.Helpers;
using WeatherStation.Helpers.Interfaces;

[assembly: FunctionsStartup(typeof(Startup))]
namespace WeatherStation
{
    public class Startup : FunctionsStartup
    {
        public override void Configure(IFunctionsHostBuilder builder)
        {
            var config = new ConfigurationBuilder()
                .SetBasePath(Directory.GetCurrentDirectory())
                .AddJsonFile("local.settings.json", optional: true, reloadOnChange: true)
                .AddEnvironmentVariables()
                .Build();

            builder.Services.AddLogging();
            
            builder.Services.AddSingleton<IConfiguration>(config);

            builder.Services.AddSingleton(sp =>
            {
                IConfiguration configuration = sp.GetService<IConfiguration>();
                CosmosClientOptions cosmosClientOptions = new CosmosClientOptions
                {
                    MaxRetryAttemptsOnRateLimitedRequests = 3,
                    MaxRetryWaitTimeOnRateLimitedRequests = TimeSpan.FromSeconds(60)
                };
                return new CosmosClient(configuration["CosmosDbConnectionString"], cosmosClientOptions);
            });

            builder.Services.AddTransient<IWeatherRepository, WeatherRepository>();
        }
    }
}
