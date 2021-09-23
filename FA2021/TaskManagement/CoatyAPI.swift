import Foundation
import CoatySwift
import DroneProtocol

class CoatyAPI{

    var container: Container?
    var droneController:DroneController
    func start(){
        let components = Components(controllers: [
            "DroneController": DroneController.self
        ],
                                    objectTypes: [
            Task.self,
            TaskControlResponse.self,
            TaskMessage.self
        ])
        // Create a configuration.
        guard let configuration = createSwitchLightConfiguration() else {
            print("Invalid configuration! Please check your options.")
            return
        }
        
        // Resolve your components with the given configuration and get
        // your CoatySwift controllers up and running.
        self.container = Container.resolve(components: components,
                                           configuration: configuration)
        self.droneController=container?.getController(name: "DroneController") as! DroneController
    }

    private func createSwitchLightConfiguration() -> Configuration? {
        return try? .build { config in
            
            // Adjusts the logging level of CoatySwift messages.
            config.common = CommonOptions()
            
            // Adjusts the logging level of CoatySwift messages, which is especially
            // helpful if you want to test or debug applications (default is .error).
            config.common?.logLevel = .info
            
            // Configure `name` of the container's identity here.
            // Do not change the given name, it is used by Coaty JS light
            // controller to track all active light and control agents.
            config.common?.agentIdentity = ["name": "Drone Agent"]
            
            // Here, we define initial values for specific options of
            // the light controller and the light control controller.
            
            
            // Define communication-related options, such as the host address of your broker
            // and the port it exposes. Also, make sure to immediately connect with the broker,
            // indicated by `shouldAutoStart: true`.
            //
            // Note: Keep alive for the broker connection has been reduced to 10secs to minimize
            // connectivity issues when running with a remote public broker.
            let mqttClientOptions = MQTTClientOptions(host: "localhost",
                                                      port: 8080,
                                                      keepAlive: 10)
            config.communication = CommunicationOptions(namespace: "coaty.examples.remoteops",
                                                        mqttClientOptions: mqttClientOptions,
                                                        shouldAutoStart: true)
        }
    }
}
