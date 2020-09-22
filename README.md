# iOS ARViewer 임포트 가이드



## Overview



## Getting Started

ARViewer 는 iOS 의 ARKit 에 기반한 정적 라이브러리입니다.
아래의 조건에서 정상적으로 동작합니다.
iOS 11.3 이상 필요. iPhone 6s 또는 iPhone SE(1세대) 이상의 기기.

## Importing SDK

### SDK 파일 추가

Project 폴더에 ARViewer.framework 파일 붙여넣기

<div style="text-align : center;">
  <a href="https://ub-mobile.s3.ap-northeast-2.amazonaws.com/img_import_guide/img_import_guide_1.png"><img width="450" src="https://ub-mobile.s3.ap-northeast-2.amazonaws.com/img_import_guide/img_import_guide_1.png" alt="img_sdk_to_folder" title="프로젝트 폴더에 framework 붙여넣기"></a>
</div>



프로젝트 파일의 Frameworks, Libraries, and Embedded Content > __+__ 를 선택한 뒤 framework 파일을 추가합니다.



<div style="text-align : center;">
  <a href="https://ub-mobile.s3.ap-northeast-2.amazonaws.com/img_import_guide/add_framework_1.png"><img width="500" src="https://ub-mobile.s3.ap-northeast-2.amazonaws.com/img_import_guide/add_framework_1.png" alt="img_sdk_to_folder" title="add_framework_1"></a>
</div>



<div style="text-align : center;">
  <a href="https://ub-mobile.s3.ap-northeast-2.amazonaws.com/img_import_guide/add_framework_2.png"><img width="400" src="https://ub-mobile.s3.ap-northeast-2.amazonaws.com/img_import_guide/add_framework_2.png" alt="img_sdk_to_folder" title="add_framework_2"></a>
</div>



<div style="text-align : center;">
  <a href="https://ub-mobile.s3.ap-northeast-2.amazonaws.com/img_import_guide/add_framework_3.png"><img width="400" src="https://ub-mobile.s3.ap-northeast-2.amazonaws.com/img_import_guide/add_framework_3.png" alt="img_sdk_to_folder" title="add_framework_3"></a>
</div>



### 권한 설정

Info.plist 에 카메라 권한을 추가합니다.

```swift
NSCameraUsageDescription
```




<div style="text-align : center;">
  <a href="https://ub-mobile.s3.ap-northeast-2.amazonaws.com/img_import_guide/camera_permission_to_plist.png"><img width="400" src="https://ub-mobile.s3.ap-northeast-2.amazonaws.com/img_import_guide/camera_permission_to_plist.png" alt="img_sdk_to_folder" title="camera_permission_to_plist"></a>
</div>



Info.plist 에 API Key 를 추가합니다.

``` swift
kUBARViewer
```



<div style="text-align : center;">
  <a href="https://ub-mobile.s3.ap-northeast-2.amazonaws.com/img_import_guide/api_key_to_plist.png"><img width="400" src="https://ub-mobile.s3.ap-northeast-2.amazonaws.com/img_import_guide/api_key_to_plist.png" alt="img_sdk_to_folder" title="api_key_to_plist"></a>
</div>



### 종속성(dependency) 설정

CocoaPods 를 사용하여 ARViewer 의 종속성을 설치하여야 합니다. Cocoapods 를 설치하려면 [설치안내][1] 를 따릅니다.

```bash
$ cd your-project directory
$ pod init
```

설치할 pod 을 추가합니다. 다음과 같이 Podfile 에 pod 을 포함할 수 있습니다.



<div style="text-align : center;">
  <a href="https://ub-mobile.s3.ap-northeast-2.amazonaws.com/img_import_guide/6_podfile_edit.png"><img width="400" src="https://ub-mobile.s3.ap-northeast-2.amazonaws.com/img_import_guide/6_podfile_edit.png" alt="img_sdk_to_folder" title="podfile_edit"></a>
</div>



``` swift
pod 'AFNetworking', '~> 3.0', :subspecs => ['Reachability', 'Serialization', 'Security', 'NSURLSession']
pod 'UICircularProgressRing', '~>6.1.0'
pod 'lottie-ios'
```

pod 을 설치하고 .xcworkspace 파일을 열어 XCode 에서 프로젝트를 확인합니다.

```bash
$ pod install
$ open your-project.xcworkspace
```

[1]: https://guides.cocoapods.org/using/getting-started.html#getting-started

### Scheme 설정

ARViewer 의 원활한 개발환경을 위해 아래의 설정을 적용합니다.



<div style="text-align : center;">
  <a href="https://ub-mobile.s3.ap-northeast-2.amazonaws.com/img_import_guide/edit_scheme.png"><img width="400" src="https://ub-mobile.s3.ap-northeast-2.amazonaws.com/img_import_guide/edit_scheme.png" alt="img_sdk_to_folder" title="edit_scheme"></a>
</div>



Runtime API Checking 의 __Main Thread Checker__ 를 __해제__합니다.



<div style="text-align : center;">
  <a href="https://ub-mobile.s3.ap-northeast-2.amazonaws.com/img_import_guide/edit_scheme_main_thread_checker.png"><img width="400" src="https://ub-mobile.s3.ap-northeast-2.amazonaws.com/img_import_guide/edit_scheme_main_thread_checker.png" alt="img_sdk_to_folder" title="edit_scheme_main_thread_checker"></a>
</div>



Metal API Validation 을 __Disabled__ 로 설정합니다.



<div style="text-align : center;">
  <a href="https://ub-mobile.s3.ap-northeast-2.amazonaws.com/img_import_guide/edit_scheme_metal_validation.png"><img width="400" src="https://ub-mobile.s3.ap-northeast-2.amazonaws.com/img_import_guide/edit_scheme_metal_validation.png" alt="img_sdk_to_folder" title="edit_scheme_metal_validation"></a>
</div>



## Initializing Session

Storyboard 나 Xib 을 통해 ARViewer 를 정적 로드합니다.



<div style="text-align : center;">
  <a href="https://ub-mobile.s3.ap-northeast-2.amazonaws.com/img_import_guide/add_to_storyboard.png"><img width="400" src="https://ub-mobile.s3.ap-northeast-2.amazonaws.com/img_import_guide/add_to_storyboard.png" alt="img_sdk_to_folder" title="add_to_storyboard"></a>
</div>



코드를 통해 동적 로드도 가능합니다.

``` swift
let arViewer = ARViewer(frame: UIScreen.main.bounds)
```

구현부를 통해 ARViewer 의 세션을 실행시킵니다.

``` swift
//
//  ARViewController.swift
//  arviewer-sample
//
//  Created by urbanbase on 2020/08/20.
//  Copyright © 2020 urbanbase. All rights reserved.
//

import UIKit
import ARViewer

class ARViewController: UIViewController {

    @IBOutlet var arViewer: ARViewer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureARViewer()
    }
    
    func configureARViewer() {
        arViewer.delegate = self
          arViewer.run()
    }
}
```
