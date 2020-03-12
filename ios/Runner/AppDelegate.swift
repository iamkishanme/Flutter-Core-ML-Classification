import UIKit
import Flutter

@available(iOS 12.0, *)
@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
    let model = Intel_Classifier_1()
    var predictionDict = [String: String]()
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        let mlChannel = FlutterMethodChannel(name: "caxondeviceimageclassify",
                                             binaryMessenger: controller.binaryMessenger)
        
        mlChannel.setMethodCallHandler({
            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            if call.method == "classifyFromImagePath" {
                let inputVariables = call.arguments
                self.predict(predictionResult: result, inputVariables: inputVariables as! String)
            }
        })
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    private func predict(predictionResult: @escaping FlutterResult, inputVariables: String){
        print("From IOS")
        print(inputVariables)
        
        let image = UIImage.init(contentsOfFile: inputVariables)
        
        let predictionItem  = self.processImage(image: image!)
        print(predictionItem)
        self.predictionDict["category"] = predictionItem
        self.predictionDict["confidence"] = ""
        predictionResult(predictionDict)
    }
    
    private func processImage(image: UIImage) -> String? {
        if let pixelBuffer = ImageProcessor.pixelBuffer(forImage: (image.cgImage!)){
            guard let predictNow = try? model.prediction(image: pixelBuffer) else {
                fatalError("Runtime Error")
            }
            print(predictNow.classLabelProbs)
            return predictNow.classLabel
        }
        return nil
    }
}
