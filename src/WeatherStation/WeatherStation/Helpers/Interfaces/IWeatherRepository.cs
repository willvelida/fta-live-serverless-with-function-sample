using System.Threading.Tasks;
using WeatherStation.Models;

namespace WeatherStation.Helpers.Interfaces
{
    public interface IWeatherRepository
    {
        Task AddWeatherReading(WeatherReading weatherReading);
    }
}
