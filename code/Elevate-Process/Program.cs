using System;
using System.Diagnostics;

namespace ElevateProcess
{
    class Program
    {
        static int Main(string[] args)
        {
            var exitCode = 0;
            try
            {
                var procInfo = new ProcessStartInfo
                                   {
                                       UseShellExecute = true,
                                       FileName = args[0],
                                       Arguments = string.Join(" ", args, 1, args.Length - 1),
                                       WorkingDirectory = Environment.CurrentDirectory,
                                   };
                if (Environment.OSVersion.Version.Major >= 6)
                    procInfo.Verb = "runas";
                var process = Process.Start(procInfo);  //Start that process.
                if (process == null) throw new Exception(procInfo.FileName + " could not be started.");
                process.WaitForExit();
                exitCode = process.ExitCode;
            }
            catch (Exception ex)
            {
                Console.Out.Write(ex.Message);
                return -1;
            }
            return exitCode;
        }
    }
}
