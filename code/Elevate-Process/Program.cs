using System;
using System.Diagnostics;

namespace ElevateProcess
{
    class Program
    {
        static void Main(string[] args)
        {
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
                Process.Start(procInfo);  //Start that process.
            }

            catch (Exception ex)
            {
                Console.Out.Write(ex.Message);
            }
        }
    }
}
