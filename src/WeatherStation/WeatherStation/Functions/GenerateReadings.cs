using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.Extensions.Logging;
using System;
using System.Threading.Tasks;
using WeatherStation.Helpers;
using WeatherStation.Models;

namespace WeatherStation.Functions
{
    public static class GenerateReadings
    {
        [FunctionName("GenerateReadings")]
        public static async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Anonymous, "get", "post", Route = "readings/{numberOfReadings}")] HttpRequest req,
            [EventHub("readings", Connection = "EventHubConnectionString")] IAsyncCollector<WeatherReading> outputEvents,
            ILogger log,
            int numberOfReadings)
        {
            try
            {
                log.LogInformation($"Starting GenerateReadings. Number of events to send: {numberOfReadings}");

                var weatherReadings = DataGenerator.GenerateWeatherReadings(numberOfReadings);

                foreach (var reading in weatherReadings)
                {
                    await outputEvents.AddAsync(reading);
                }

                log.LogInformation($"GenerateReadings Executed. Number of events sent: {weatherReadings.Count}");

                return new OkResult();
            }
            catch (Exception ex)
            {
                log.LogError($"Exception thrown in {nameof(GenerateReadings)}: {ex.Message}");
                throw;
            }
        }
    }
}
