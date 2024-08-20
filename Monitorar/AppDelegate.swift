import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    var monitor: MonitorDeDiretorio?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        monitor = MonitorDeDiretorio()
        monitor?.iniciarMonitoramento()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        monitor?.pararMonitoramento()
    }
}
