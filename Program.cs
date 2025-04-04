using wsl2_network_fix;

var builder = Host.CreateApplicationBuilder(args);

// Windows event log configuration
builder.Logging.AddEventLog(eventLogSettings =>
{
    eventLogSettings.SourceName = "WSL2 Network Fix Service";
    eventLogSettings.LogName = "Application";
    eventLogSettings.Filter = (_, level) => level >= LogLevel.Information;
});

builder.Services.AddWindowsService(options => 
{
    options.ServiceName = "WSL2 Network Fix Service";
});

builder.Services.AddHostedService<Worker>();

var host = builder.Build();
host.Run();
