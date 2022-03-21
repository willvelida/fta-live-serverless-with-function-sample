using Microsoft.Azure.WebJobs;
using Microsoft.Extensions.Logging;
using System.IO;

namespace WeatherStation.Functions
{
    public class ProcessWeatherFileBlob
    {
        [FunctionName("ProcessWeatherFileBlob")]
        public void Run([BlobTrigger("blobtriggercontainer/{name}", Connection = "BlobTriggerStorageConnection")] Stream myBlob, string name, ILogger log)
        {
            log.LogInformation($"C# Blob trigger function Processed blob\n Name:{name} \n Size: {myBlob.Length} Bytes");
        }
    }
}
