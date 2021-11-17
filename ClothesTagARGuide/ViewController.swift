//
//  ViewController.swift
//  ClothesTagARGuide
//
//  Created by Yujin Lee on 2021/11/16.
//

import UIKit
import SceneKit
import ARKit
import SafariServices

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var detectedImage = "non" // 감지된 이미지파일명
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        sceneView.autoenablesDefaultLighting = true // light
        
        UIApplication.shared.isIdleTimerDisabled = true
        
        
        // 하단에 버튼 세 개 만들기
        
        // x축 : 뷰 중간위치
        let centerPositionX = UIScreen.main.bounds.size.width / 2 - 50
        // y축 : 뷰 하단 위치
        let bottomPositionY = UIScreen.main.bounds.size.height - 130
        let btnWidth = 100.0 // 버튼 너비
        
        // 버튼 1. Fabric
        let btnFabric = CSButton(type: .btnFabric)
        btnFabric.frame = CGRect(x: centerPositionX - (btnWidth + 30), y: bottomPositionY, width: btnWidth, height: 50)
        btnFabric.addTarget(self, action: #selector(clicked(_:)), for: .touchUpInside) // 액션메소드
        self.view.addSubview(btnFabric)
        
        // 버튼 2. Wash
        let btnWash = CSButton(type: .btnWash)
        btnWash.frame = CGRect(x: centerPositionX, y: bottomPositionY, width: btnWidth, height: 50)
        btnWash.addTarget(self, action: #selector(clicked(_:)), for: .touchUpInside) // 액션메소드
        self.view.addSubview(btnWash)
        
        // 버튼 3. Support
        let btnSupport = CSButton(type: .btnSupport)
        btnSupport.frame = CGRect(x: centerPositionX + (btnWidth + 30), y: bottomPositionY, width: btnWidth, height: 50)
        btnSupport.addTarget(self, action: #selector(clicked(_:)), for: .touchUpInside) // 액션메소드
        self.view.addSubview(btnSupport)
    }
    
    // 버튼클릭 이벤트
    @objc func clicked(_ sender: UIButton) {
        
        // 버튼클릭 효과
        sender.layer.borderColor = UIColor.white.cgColor // 테두리 색 켜기
        playAudio("art.scnassets/audio/click_sound2.mp3", 0.0) // '딸칵' 소리
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            sender.layer.borderColor = UIColor.lightGray.cgColor // 테두리 색 끄기
        }
        
        if detectedImage == "non" { // 인식된 옷이 없을 경우
            playAudio("art.scnassets/audio/empty.mp3", 0.0) // "옷을 인식해주세요." 음성
        } else { // 옷 태그가 인식되었을 경우
            if sender.titleLabel?.text == "Fabric" { // Fabric 버튼을 눌렀을 경우
                if detectedImage == "eider_grey_knit" {
                    playAudio("art.scnassets/audio/fabric_eider_grey_knit.mp3", 1.0)
                } else if detectedImage == "kangol_black_shirt" {
                    playAudio("art.scnassets/audio/fabric_kangol_black_shirt.mp3", 1.0)
                } else if detectedImage == "list_beige_jacket" {
                    playAudio("art.scnassets/audio/fabric_list_beige_jacket.mp3", 1.0)
                }
            } else if sender.titleLabel?.text == "Wash" { // Wash 버튼을 눌렀을 경우
                if detectedImage == "eider_grey_knit" {
                    playAudio("art.scnassets/audio/wash_eider_grey_knit.mp3", 1.0)
                } else if detectedImage == "kangol_black_shirt" {
                    playAudio("art.scnassets/audio/wash_kangol_black_shirt.mp3", 1.0)
                } else if detectedImage == "list_beige_jacket" {
                    playAudio("art.scnassets/audio/wash_list_beige_jacket.mp3", 1.0)
                }
            } else if sender.titleLabel?.text == "Support" { // Support 버튼을 눌렀을 경우
                
                if detectedImage == "eider_grey_knit" {
                    accessUrl("https://www.eider.co.kr/customercenter")
                } else if detectedImage == "kangol_black_shirt" {
                    accessUrl("https://kangolkorea.com/board/product/list.html?board_no=6")
                } else if detectedImage == "list_beige_jacket" {
                    accessUrl("https://www.idfmall.co.kr/board/?db=basic_2")
                }
            }
        }
        print(detectedImage)
    }
    
    // 오디오 플레이
    func playAudio(_ audioFile:String, _ delay:Double) {
        var soundAction = SCNAction()
        let soundNode = SCNNode()
        let audioSource = SCNAudioSource.init(named: audioFile)!
        
        audioSource.volume = 0.5
        audioSource.loops = false
        audioSource.load()
        
        soundAction = SCNAction.playAudio(audioSource, waitForCompletion: false)
        
        sceneView.scene.rootNode.addChildNode(soundNode)

        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            soundNode.runAction(soundAction)
        }
        // soundNode.runAction(soundAction)
    }
    
    // url 접속
    func accessUrl(_ address:String) {
        let url = URL(string: address)
        let safariViewController = SFSafariViewController(url: url!)
        present(safariViewController, animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let location = touches.first!.location(in: sceneView)
                
        // Let's test if a 3D Object was touch
        var hitTestOptions = [SCNHitTestOption: Any]()
        hitTestOptions[SCNHitTestOption.boundingBoxOnly] = true
        
        let hitResults: [SCNHitTestResult] = sceneView.hitTest(location, options: hitTestOptions)
        
        if hitResults.first != nil {
            playAudio("art.scnassets/audio/hello.mp3", 0.0)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (ARWorldTrackingConfiguration.isSupported) {
            // Create a session configuration
            let configuration = ARWorldTrackingConfiguration()
            
            if let imageToTrack = ARReferenceImage.referenceImages(inGroupNamed: "Tags", bundle: Bundle.main) {
                configuration.detectionImages = imageToTrack
                configuration.maximumNumberOfTrackedImages = 1
            }

            // Run the view's session
            sceneView.session.run(configuration)
        }

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
        if let imageAnchor = anchor as? ARImageAnchor {
            
            let plane = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width, height: imageAnchor.referenceImage.physicalSize.height)
            plane.firstMaterial?.diffuse.contents = UIColor(white: 1.0, alpha: 0.5)
            
            let planeNode = SCNNode(geometry: plane)
            planeNode.eulerAngles.x = -Float.pi / 2
            
            node.addChildNode(planeNode)
            
            if let characterScene = SCNScene(named: "art.scnassets/enoch2.dae") {
                
                for child in characterScene.rootNode.childNodes {
                    planeNode.addChildNode(child)
                }
                
                playAudio("art.scnassets/audio/hello.mp3", 0.0)

//                if let characterNode = characterScene.rootNode.childNodes.first {
//                    //characterNode.eulerAngles.x = .pi / 2
//                    planeNode.addChildNode(characterNode)
//                }
                
            }
            
            detectedImage = imageAnchor.referenceImage.name ?? "non"
            
//            if imageAnchor.referenceImage.name == "eider_grey_knit" {
//
//            } else if imageAnchor.referenceImage.name == "kangol_black_shirt" {
//
//            } else if imageAnchor.referenceImage.name == "list_beige_jacket" {
//
//            }
        } else {
            detectedImage = "non"
        }
        
        return node
    }
    

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
