// Default URL for triggering event grid function in the local environment.
// http://localhost:7071/runtime/webhooks/EventGrid?functionName={functionname}
using Microsoft.Azure.EventGrid.Models;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.EventGrid;
using Microsoft.Extensions.Logging;
using System.Threading.Tasks;

namespace WeatherStation.Functions
{
    public static class ProcessWeatherFileEventGrid
    {
        [FunctionName("ProcessWeatherFileEventGrid")]
        public static async Task Run(
            [EventGridTrigger] EventGridEvent eventGridEvent,
            ILogger log)
        {
            log.LogInformation(eventGridEvent.Data.ToString());
        }
    }
}
