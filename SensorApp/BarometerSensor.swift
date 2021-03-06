//
//  BarometerSensor.swift
//  SensorApp
//
//  Copyright © 2016 Zühlke Engineering AG. All rights reserved.
//

import CoreMotion

/**
 The purpose of the `BarometerSensor` class is to provide the data that is generated by the barometer of the device.
 For details of this sensor see https://en.wikipedia.org/wiki/Barometer
 
 The `BarometerSensor` class is a subclass of the `AbstractSensor`, and it conforms to the `DeviceSensor` protocol.
 */
class BarometerSensor: AbstractSensor, DeviceSensor {

    private var altimeter = CMAltimeter()

    /// A Bool that indicates that the barometer is available on the device
    var isAvailable : Bool{
        
        get{
            return CMAltimeter.isRelativeAltitudeAvailable()
        }
    }
    
    /// The type of class is Barometer
    var type : SensorType {
        get{
            return .Barometer
        }
    }
    
    /**
     Public initializer that takes `CMMotionManager` and `FileWriterService` as an argument.
     `CMMotionManager` must be injected because Apple recommends to have only one instance of it for performance reasons as it is used in multiple sensor classes.
     `FileWriterService` is used to save the measured results.
     */
    init(fileWriterService: FileWriterService) {
        super.init(fileWriterService: fileWriterService, deviceType: .Barometer)
    }
    
    /**
     Method to start the reporting of sensor data. The data is read every few seconds
     */
    func startReporting(){
        
        guard isAvailable else {
            print("Barometer not available")
            return
        }
        _isReporting = true
       
        altimeter.startRelativeAltitudeUpdatesToQueue(NSOperationQueue()) {
            (data:CMAltitudeData?, error:NSError?) in
            self.persistData(data)
        }
    }
    
    
    ///method that writes the data from the sensor into a dictionary structur for later JSON generation
    private func persistData(data: CMAltitudeData?){
        
        guard let data = data else {return}
        
        var params = [String:AnyObject]()
        params["type"] = "Barometer"
        params["date"] = dateFormatter.stringFromDate(NSDate())
        
        params["relativeAltitude"] = data.relativeAltitude
        params["pressure"] = data.pressure
        
        fileWriter?.addLine(params)
    }
    
    ///method that stops sensor reading and generation of data
    func stopReporting(){
        altimeter.stopRelativeAltitudeUpdates()
        _isReporting = false
    }
    
}
