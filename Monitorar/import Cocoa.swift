import Cocoa

class MonitorDeDiretorio {
    private var referenciaDeStream: FSEventStreamRef?
    private let urlArquivoDeLog: URL

    init() {
        let nomeDoArquivoDeLog = "log_de_atividade.txt"
        let diretorioDaAreaDeTrabalho = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first!
        self.urlArquivoDeLog = diretorioDaAreaDeTrabalho.appendingPathComponent(nomeDoArquivoDeLog)

        if !FileManager.default.fileExists(atPath: urlArquivoDeLog.path) {
            FileManager.default.createFile(atPath: urlArquivoDeLog.path, contents: nil, attributes: nil)
        }
    }

    func iniciarMonitoramento() {
        let callback: FSEventStreamCallback = { (
            streamRef: ConstFSEventStreamRef,
            clientCallBackInfo: UnsafeMutableRawPointer?,
            numEvents: Int,
            eventPaths: UnsafeMutableRawPointer,
            eventFlags: UnsafePointer<FSEventStreamEventFlags>,
            eventIds: UnsafePointer<FSEventStreamEventId>
        ) in
            let paths = unsafeBitCast(eventPaths, to: NSArray.self) as! [String]
            for path in paths {
                let dataHora = Date()
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let dataHoraFormatada = formatter.string(from: dataHora)
                
                let usuario = self.obterNomeDoUsuario()
                let grupo = self.obterNomeDoGrupo()

                let mensagemDeLog = "Mudança detectada no caminho: \(path) em \(dataHoraFormatada) pelo usuário \(usuario) do grupo \(grupo)\n"
                print(mensagemDeLog)

                if let clientCallBackInfo = clientCallBackInfo {
                    let monitor = Unmanaged<MonitorDeDiretorio>.fromOpaque(clientCallBackInfo).takeUnretainedValue()
                    monitor.adicionarLog(mensagem: mensagemDeLog)
                }
            }
        }

        let eventStream = FSEventStreamCreate(
            kCFAllocatorDefault,
            callback,
            UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()),
            ["/" as CFArray] as CFArray,
            FSEventStreamEventId(kFSEventStreamEventIdSinceNow),
            1.0,
            UInt32(kFSEventStreamCreateFlagFileEvents | kFSEventStreamCreateFlagNoDefer)
        )

        referenciaDeStream = eventStream
        FSEventStreamScheduleWithRunLoop(eventStream, CFRunLoopGetMain(), CFRunLoopMode.defaultMode.rawValue)
        FSEventStreamStart(eventStream)
    }

    func pararMonitoramento() {
        if let eventStream = referenciaDeStream {
            FSEventStreamStop(eventStream)
            FSEventStreamInvalidate(eventStream)
            FSEventStreamRelease(eventStream)
        }
    }

    private func obterNomeDoUsuario() -> String {
        let nomeUsuarioProcesso = Process()
        nomeUsuarioProcesso.executableURL = URL(fileURLWithPath: "/usr/bin/id")
        nomeUsuarioProcesso.arguments = ["-un"]
        
        let pipe = Pipe()
        nomeUsuarioProcesso.standardOutput = pipe
        
        do {
            try nomeUsuarioProcesso.run()
        } catch {
            print("Erro ao obter o nome do usuário: \(error)")
            return "desconhecido"
        }
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        if let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) {
            return output
        }
        
        return "desconhecido"
    }

    private func obterNomeDoGrupo() -> String {
        let nomeGrupoProcesso = Process()
        nomeGrupoProcesso.executableURL = URL(fileURLWithPath: "/usr/bin/id")
        nomeGrupoProcesso.arguments = ["-gn"]
        
        let pipe = Pipe()
        nomeGrupoProcesso.standardOutput = pipe
        
        do {
            try nomeGrupoProcesso.run()
        } catch {
            print("Erro ao obter o nome do grupo: \(error)")
            return "desconhecido"
        }
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        if let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) {
            return output
        }
        
        return "desconhecido"
    }

    private func adicionarLog(mensagem: String) {
        do {
            let fileHandle = try FileHandle(forWritingTo: urlArquivoDeLog)
            fileHandle.seekToEndOfFile()
            if let data = mensagem.data(using: .utf8) {
                fileHandle.write(data)
            }
            fileHandle.closeFile()
        } catch {
            print("Falha ao escrever no arquivo de log: \(error)")
        }
    }
}
