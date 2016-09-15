//
//  AccelerometerSensor.swift
//  SensorApp
//
//  Copyright © 2016 Zühlke Engineering AG. All rights reserved.
//



import CoreMotion

/**
 The purpose of the `AccelerometerSensor` class is to provide the data that is generated by the accelerometer of the device.
 For details of this sensor see https://en.wikipedia.org/wiki/Accelerometer
 
 The `AccelerometerSensor` class is a subclass of the `AbstractSensor`, and it conforms to the `DeviceSensor` protocol.
 */
class AccelerometerSensor: AbstractSensor, DeviceSensor {
    
    private weak var manager : CMMotionManager?
    
    /// A Bool that indicates that the accelerometer is available on the device
    var isAvailable : Bool{
        
        get{
            return manager!.accelerometerAvailable
        }
    }
    
    /// The type of class is Accelerometer
    var type : SensorType {
        get{
            return .Accelerometer
        }
    }
    
    /**
    Public initializer that takes `CMMotionManager` and `FileWriterService` as an argument.
     `CMMotionManager` must be injected because Apple recommends to have only one instance of it for performance reasons as it is used in multiple sensor classes.
     `FileWriterService` is used to save the measured results.
     */
    init(motionManager: CMMotionManager, fileWriterService: FileWriterService) {
        super.init(fileWriterService: fileWriterService, deviceType: .Accelerometer)
        manager = motionManager
    }
    
    /**
        Method to start the reporting of sensor data. The data is read with the interval specified by `accelerometerUpdateInterval`
     */
    func startReporting(){
        
        guard isAvailable else {
            print("AccelerometerSensor not available")
            return
        }
        guard let manager = manager else {return }
        
        _isReporting = true
        
        manager.accelerometerUpdateInterval = 0.1
        manager.startAccelerometerUpdatesToQueue(NSOperationQueue()) {
            (data: CMAccelerometerData?, error: NSError?) in

            self.persistData(data)
        }
    }
    
    ///method that writes the data from the sensor into a dictionary structur for later JSON generation
    private func persistData(data: CMAccelerometerData?){
        
        guard let data = data else {return}
        
        var params = [String:AnyObject]()
        params["type"] = "Accelerometer"
        params["date"] = dateFormatter.stringFromDate(NSDate())
        params["x"] = data.acceleration.x
        params["y"] = data.acceleration.y
        params["z"] = data.acceleration.z
        
        fileWriter?.addLine(params)
    }
    
    ///method that stops sensor reading and generation of data
    func stopReporting(){
        guard let manager = manager else {return}
        manager.stopAccelerometerUpdates()
        _isReporting = false
    }

}
