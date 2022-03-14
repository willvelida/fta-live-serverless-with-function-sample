using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WeatherStation.Models
{
    public class WeatherReading
    {
        [JsonProperty(PropertyName = "id")]
        public string Id { get; set; }
        public string Location { get; set; }
        public DateTime Date { get; set; }
        public int TemperatureC { get; set; }
        public int TemperatureF => 32 + (int)(TemperatureC / 0.5556);
    }
}
