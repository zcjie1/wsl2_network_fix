using SharpPcap;

namespace wsl2_network_fix;

public class Worker : BackgroundService
{
    private readonly ILogger<Worker> _logger;
    private ICaptureDevice? _loopback;

    public Worker(ILogger<Worker> logger)
    {
        _logger = logger;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        try
        {
            _logger.LogInformation("Starting WSL2 network fix service");

            var devices = CaptureDeviceList.Instance;
            var targetDevice = @"\Device\NPF_Loopback";

            if (!devices.Any(d => d.Name == targetDevice))
            {
                _logger.LogError("NPF Loopback device not found!");
                return;
            }

            _loopback = devices[targetDevice];
            _loopback.Open();

            _logger.LogInformation("Open NPF Loopback device successfully");

            await WaitUntilCancelled(stoppingToken);
        }
        catch (TaskCanceledException)
        {
            _logger.LogInformation("WSL2 network fix Service shutdown requested");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Service fatal error");
            Environment.ExitCode = 1;
            throw;
        }
    }

    private static async Task WaitUntilCancelled(CancellationToken stoppingToken)
    {
        var tcs = new TaskCompletionSource<bool>();
        using var registration = stoppingToken.Register(() => tcs.TrySetResult(true));
        await tcs.Task;
    }

    public override async Task StopAsync(CancellationToken stoppingToken)
    {
        _logger.LogInformation("Service is stopping...");

        try
        {
            if (_loopback?.Started == true)
            {
                _loopback.Close();
                _logger.LogInformation("NPF Loopback device closed successfully");
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error closing loopback device");
        }

        await base.StopAsync(stoppingToken);
    }
}