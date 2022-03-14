using Bogus;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WeatherStation.Models;

namespace WeatherStation.Helpers
{
    public static class DataGenerator
    {
        public static List<WeatherReading> GenerateWeatherReadings(int numberOfReadings)
        {
            var readings = new Faker<WeatherReading>()
                .RuleFor(i => i.Id, r => Guid.NewGuid().ToString())
                .RuleFor(i => i.Date, r => DateTime.Now)
                .RuleFor(i => i.Location, r => r.PickRandom(new string[] {"London", "Auckland", "Los Angeles", "Seattle", "Toyko"}))
                .RuleFor(i => i.TemperatureC, r => r.Random.Int(0, 35))
                .Generate(numberOfReadings);

            return readings;
        }
    }
}
