using Azure.Messaging.EventHubs;
using Microsoft.Azure.WebJobs;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using System;
using System.Text;
using System.Threading.Tasks;
using WeatherStation.Helpers.Interfaces;
using WeatherStation.Models;

namespace WeatherStation.Functions
{
    public class ProcessReadings
    {
        private readonly IWeatherRepository _weatherRepository;
        private readonly ILogger<ProcessReadings> _logger;

        public ProcessReadings(IWeatherRepository weatherRepository, ILogger<ProcessReadings> logger)
        {
            _weatherRepository=weatherRepository;
            _logger=logger;
        }


        [FunctionName("ProcessReadings")]
        public async Task Run([EventHubTrigger("readings", Connection = "EventHubConnectionString")] EventData[] readingEvents)
        {
            _logger.LogInformation("Reading events of readings event hub.");

            try
            {
                foreach (var reading in readingEvents)
                {
                    var messageBody = Encoding.UTF8.GetString(reading.EventBody);

                    var weatherJson = JsonConvert.DeserializeObject<WeatherReading>(messageBody);

                    await _weatherRepository.AddWeatherReading(weatherJson);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception thrown in {nameof(ProcessReadings)}: {ex.Message}");
                throw;
            }
        }
    }
}
