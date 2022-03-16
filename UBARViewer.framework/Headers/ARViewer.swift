//
//  ARViewer.swift
//  ARViewer
//
//  Created by 이우석 on 11/12/2018.
//  Copyright © 2018 이우석. All rights reserved.
//

import Foundation
import ARKit
import SceneKit
import AFNetworking
import UBGear

/// Values for feature mode.
///
/// You can set of viewer mode, see below.
///
///     arViewer.setViewerMode(.AR)
///
@objc public enum FeatureType: Int {
    
    /// A feature type that detects surfaces and tracking session.
    ///
    /// - Attention: If possible, avoid setting AR mode. ARViewer set the mode automatically and manage efficiently.
    case AR = 0
    
    /// A feature type that detects a QR code.
    case QR
    
    /// A feature type that tracking session without detects surfaces.
    ///
    /// - Note:
    /// You shoud use this, If your turning back to AR mode.
    case ECO
    
    /// A feature type that measure the surfaces.
    case Measure
}

@available(iOS 11.3, *)
@objc public enum TrackingMode: Int {
    var planeDetection: ARWorldTrackingConfiguration.PlaneDetection {
        switch self {
        case .none:
            return []
        case .horizontal:
            return [.horizontal]
        case .vertical:
            return [.vertical]
        case .all:
            return [.horizontal, .vertical]
        }
    }
    
    /// Tracking surfaces continuously, but not updating extents of surfaces.
    case none
    
    /// Tracking surfaces that are perpendicular to gravity.
    case horizontal
    
    /// Tracking surfaces that are parallel to gravity.
    case vertical
    
    /// Tracking surfaces both horizontal and vertical.
    case all
}

/// The `ARViewerDelegate` protocol defines methods that allow you to manage the session and behavior. The methods of this protocol are all optional.
@available(iOS 11.3, *)
@objc public protocol ARViewerDelegate {
    
    /// Tells the delegate that the app has permission for camera type.
    /// - Parameter authorized: `true` if the app has permission.
    @objc optional func permissionAuthorized(_ authorized: Bool)
    
    /// Tells the delegate that plane (a.k.a surface) was detected.
    @objc optional func findPlane()
    
    /// (@deprecated) Tells the delegate that `ARViewer` was closed.
    @objc optional func closeARViewer()
    
    /// Tells the delegate that the figure was placed.
    /// - Parameter figure: The figure being placed.
    @objc optional func didPlace(figure: Figure)
    
    /// Tells the delegate that the figure was selected.
    /// - Parameter selectedFigure: The figure being selected.
    @objc optional func selectProduct(selectedFigure: Figure?)
    
    /// Tells the delegate that the figure was rotated.
    /// - Parameter selectedFigure: The figure being rotated.
    @objc optional func rotateChanged(selectedFigure: Figure)
    
    /// Tells the delegate that the figure was scaled.
    /// - Parameter selectedFigure: The figure being scaled.
    @objc optional func scaleChanged(selectedFigure: Figure)
    
    /// Tells the delegate that the QR code was detected.
    /// - Parameter url: The URL of QR code.
    @objc optional func qrDetected(url: URL?)
    
    /// Tells the delegate that the camera is indicating inside of a surface.
    /// - Parameters:
    ///   - time: The current system time, in seconds. Use this parameter for any time-based elements of your logic.
    ///   - rayingInPlane: `true` if the camera is indicating insde of a surface. otherwise, `false`.
    @objc optional func session(updateAtTime time: TimeInterval, rayingInPlane: Bool)
    
    /// Tells the delegate that the camera session state is changed.
    /// - Parameter changed: The detecting state being changed.
    @objc optional func session(state changed: DetectingState)
}

/**

 # ARViewer

 This is the class that implemented Augmented Reality.
 You can configure `ARViewer` programmatically or in your storyboard file.

 This is the `UIView` subclass that creates and handles virtual object (a.k.a `Figure`).

 ## Author
 Wooseok Lee
 
 ## Copyright
 Copyright © 2018 Urbanbase Inc.

*/
@available(iOS 11.3, *)
open class ARViewer: UIView {
    
    @objc public enum State: Int {
        case Configure = 0
        case Run
        case Paused
        case Invalid
    }
    
    /**
     A view that enables you to display an AR experience.
     It is subclass of `ARSCNView`.
     */
    @objc public var arSceneView: ARViewerSCNView
    @objc public var session: ARSession {
        return arSceneView.session
    }
    
    /// Returns an array of figures currently loaded in the scene.
    @objc public internal(set) var loadedFigures = [Figure]()
    
    var screenCenter: CGPoint {
        return CGPoint(x: bounds.midX, y: bounds.midY)
    }
    
    lazy var planeDetection = PlaneDetection(arView: self, planeMode: .Boundary, enableReticle: false)
    
    var figureInteraction: UBARInteraction
    
    lazy var behaviour: Behaviour = PreloadBehaviour(self)
    var placementManager: RaycastStrategy!
    
    weak var attachedView: UIView?
    
    var toBePlacedProduct: (assetId: String?, token: String?)? //uuid
    
    var mode: FeatureType = .AR {
        didSet {
            guard mode != oldValue else { return }
            switch mode {
            case .AR:
                behaviour = PreloadBehaviour(self)
                resume(trackingMode: .all)
                loadedFigures.forEach { $0.isHidden = false }
                planeDetection.showPlane(isHidden: false)
                setReticle(isHidden: true)
            case .ECO:
                behaviour = PreloadBehaviour(self)
                pause()
                loadedFigures.forEach { $0.isHidden = false }
                planeDetection.showPlane(isHidden: true)
                setReticle(isHidden: true)
            case .Measure:
                behaviour = MeasureBehaviour(self)
                resume(trackingMode: .all)
                loadedFigures.forEach { $0.isHidden = false }
                planeDetection.showPlane(isHidden: true)
                setReticle(isHidden: false)
            case .QR:
                behaviour = QRBehaviour(self)
                pause()
                loadedFigures.forEach { $0.isHidden = true }
                planeDetection.showPlane(isHidden: true)
                setReticle(isHidden: true)
            }
        }
    }
    
    /// A feature mode of ARViewer.
    @objc public var featureMode: FeatureType {
        return mode
    }
    
    /// The object that acts as the delegate of the `ARViewer`.
    @objc public weak var delegate: ARViewerDelegate?
    
    /// The figure which currently selected.
    @objc public var selectedFigure: Figure? {
        return figureInteraction.selectedFigure
    }
    
    @objc public internal(set) var state: State = .Configure {
        willSet {
            guard newValue == .Invalid else { return }
            stop()
        }
    }
    
    /// An object that manages the measuring.
    @objc public lazy var measurement = ARMeasurement(arViewer: self)
    
    @objc public var contentsURL: String {
        get {
            return UBApi.CLOUDFRONT_URL
        }
        set {
            UBApi.CLOUDFRONT_URL = newValue
        }
    }
    
    @objc public var isRRF: Bool {
        guard #available(iOS 12.0, *), let configuration = session.configuration as? ARWorldTrackingConfiguration else { return false }
        return configuration.environmentTexturing == .automatic
    }
    
    @objc public var isShadowEnabled: Bool {
        guard let lightingNode = arSceneView.lightingRootNode?.childNodes.first, let light = lightingNode.light else { return false }
        return light.castsShadow
    }
    
    @objc public var preferredFramePerSecond: Int {
        get {
            return arSceneView.preferredFramesPerSecond
        }
        set {
            arSceneView.preferredFramesPerSecond = newValue
        }
    }
    
    var onBoardingView: OnBoardingView?
    public var useOnBoardingView: Bool = false
    
    typealias SceneBlock = () -> Void
    var sceneBlocks = [SceneBlock]()
    
    override public init(frame: CGRect) {
        arSceneView = ARViewerSCNView(frame: frame)
        figureInteraction = UBARInteraction(sceneView: arSceneView)
        super.init(frame: frame)
        setPlacementStrategy()
        backgroundColor = .clear
        arSceneView.backgroundColor = .black
        addSubview(arSceneView)
        arSceneView.fitSuperview()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        arSceneView = ARViewerSCNView(frame: UIScreen.main.bounds)
        figureInteraction = UBARInteraction(sceneView: arSceneView)
        super.init(coder: aDecoder)
        setPlacementStrategy()
        backgroundColor = .clear
        arSceneView.backgroundColor = .black
        addSubview(arSceneView)
        arSceneView.fitSuperview()
    }
    
    func setPlacementStrategy() {
        if #available(iOS 13.0, *) {
            placementManager = Raycast(self)
        } else {
            placementManager = HitResult(self)
        }
    }
    
    deinit {
        removeAllFigures()
    }
}
