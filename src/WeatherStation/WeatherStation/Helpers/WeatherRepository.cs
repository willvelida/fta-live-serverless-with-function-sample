using Microsoft.Azure.Cosmos;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WeatherStation.Helpers.Interfaces;
using WeatherStation.Models;

namespace WeatherStation.Helpers
{
    public class WeatherRepository : IWeatherRepository
    {
        private readonly CosmosClient _cosmosClient;
        private readonly Container _weatherContainer;
        private readonly IConfiguration _configuration;
        private readonly ILogger<WeatherRepository> _logger;

        public WeatherRepository(CosmosClient cosmosClient, IConfiguration configuration, ILogger<WeatherRepository> logger)
        {
            _cosmosClient = cosmosClient;
            _configuration = configuration;
            _weatherContainer = _cosmosClient.GetContainer(_configuration["DatabaseName"], _configuration["ContainerName"]);
            _logger = logger;
        }

        public async Task AddWeatherReading(WeatherReading weatherReading)
        {
            try
            {
                ItemRequestOptions itemRequestOptions = new ItemRequestOptions
                {
                    EnableContentResponseOnWrite = false
                };

                await _weatherContainer.CreateItemAsync(weatherReading, new PartitionKey(weatherReading.Id), itemRequestOptions);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception thrown in {nameof(AddWeatherReading)}: {ex.Message}");
                throw;
            }
        }
    }
}
