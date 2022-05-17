# 📱 <동기화 메모장> 시연 영상

> Dropbox 실시간 연동이 가능한 메모장 앱

https://user-images.githubusercontent.com/71127966/160789726-37672a1c-b9d1-4e88-a212-4d20812db493.mov

<br>

# ✨ 핵심 키워드

- `UIKit with MVC 패턴` (iOS 14.3+)
- Core Data
- UISplitViewController
- UISearchController
- UIActivityViewController
- 외부 라이브러리 사용 (SwiftyDropbox, SwiftLint)
- iPad 멀티태스킹 모드 대응
- 지역화(Localization)
- 다이나믹 타입, 다크 모드

<br>

# ⚙️ [STEP 4] 검색 기능, 지역화, 접근성

<details>
<summary><h3>1️⃣ NSPredicate 활용한 검색 조건 설정</h3></summary>

- 메모의 '제목(title)'만으로 검색하는 것보다는, '내용(body)' 까지 검색 대상에 포함시키는 것이 더 정확한 검색 결과를 보여줄 수 있을 것이라 생각했습니다.

- 이에 `NSPredicate` 를 활용하여 원하는 조건을 request 에 넣어주고자 했습니다.
  - 제목 혹은 내용에 검색된 키워드가 포함되어 있으면 검색 결과로 반환시켜주고자 했기에 아래와 같이 구현했습니다.

```swift
func search(for keyword: String) -> [Memo] {
    let request = Memo.fetchRequest()
    var predicates = [NSPredicate]()
    predicates.append(NSPredicate(format: "title CONTAINS[cd] %@", keyword))
    predicates.append(NSPredicate(format: "body CONTAINS[cd] %@", keyword))
    request.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: predicates)
    let searchedMemos = try? context.fetch(request)

    return searchedMemos ?? []
}
```
</details>

<details>
<summary><h3>2️⃣ 검색 결과를 선택한 상태로 다시 리스트로 돌아갈 때 indexPath 변경 대응</h3></summary>

- 검색 결과에서 메모를 선택하고 다시 메인 메모 리스트로 돌아갔을 때 `select` 가 유지되지 않거나, indexPath 가 변경되어 다른 메모가 선택되는 문제가 있었습니다.
  
- `UISearchController` 가 dismiss 될 때 가장 마지막으로 선택된 indexPath 및 선택된 메모에 대한 정보를 가지고 있기에, 이를 기준으로 memoDetail, memoTableView 가 가지는 `indexPath 를 업데이트` 시켰습니다.

- 이는 `UISearchControllerDelegate` 의 `willDismissSearchController` 메서드를 통해 적합한 시점에 전달해주도록 구현했습니다.

<p align="left"><img src="https://camo.githubusercontent.com/9a4b1fd5aef4c7235c085a60211f9b523954d07df3d2f4d502b46bc44b77a162/68747470733a2f2f692e696d6775722e636f6d2f527a41514e6c612e676966" width="40%"></p>
  
</details>

<details>
<summary><h3>3️⃣ 지역화 (Localization)</h3></summary>

- 지역화를 지원하기 위해 우선 다양한 국가에서 사용하는 언어인 `영어를 base 언어`로 설정했습니다.
  - 이외에도 `한국어, 일본어를 지원`하여 사용자가 작성한 메모를 제외한 모든 텍스트가 지역화 되도록 구현했습니다!

- `Localizable.strings` 파일을 생성하여 key, value 매칭하는 방식으로 구현했습니다.

|🇰🇷|🇺🇸|🇯🇵|
|:-:|:-:|:-:|
|<img src="https://camo.githubusercontent.com/4bd02ba914100c549a5a55292d3f331c12b921e64806546ad511ec9b80091524/68747470733a2f2f692e696d6775722e636f6d2f376d3577556a562e706e67">|<img src="https://camo.githubusercontent.com/b42ce87ef3665b576700d34d8be90d62358de8827df031ea4ccda67b518d49da/68747470733a2f2f692e696d6775722e636f6d2f54563131716e612e706e67">|<img src="https://camo.githubusercontent.com/9981efb500d251a11c7215b988ad23ae299f7be59d3dee69a1aceb145d937b5e/68747470733a2f2f692e696d6775722e636f6d2f5236474b7a73312e706e67">|

</details>

<details>
<summary><h3>4️⃣ 접근성 (다이나믹 타입)</h3></summary>

- 기존에 다른 UI 요소들은 `다이나믹 타입` 지원이 되었으나 `UITextView` 내부의 텍스트는 크기가 변경되지 않는 이슈가 있었습니다.

- 이에 명시적으로 `adjustsFontForContentSizeCategory` 프로퍼티 값을 `true` 로 설정하여 정상 작동하도록 수정했습니다.
  
<p align="left"><img src="https://camo.githubusercontent.com/b7a49e072be27d31ca2497d00816581391ee6290eccb3b63b871aecb109de3d9/68747470733a2f2f692e696d6775722e636f6d2f63776b424235562e676966" width="40%"></p>

</details>

<br>

# ⚙️ [STEP 3] Dropbox 클라우드 연동

<details>
<summary><h3>1️⃣ App 단에서 데이터를 관리하기 위한 방법</h3></summary>

- Dropbox 를 연동함에 따라 데이터를 어느 계층에서 관리해줘야 할지에 대해서 고민했습니다.
  - 기존에는 `MemoSplitViewController`가 가지도록 해줬으나, 데이터는 앱의 전반적인 부분과 관련이 있다고 판단했습니다.

- 우선, CoreDataManager, DropboxManager 타입을 관리하는 상위 객체인 `MemoStorage` 를 구현하고 프로토콜도 추가 생성했습니다.
  - 그리고 `MemoStorage` 인스턴스는 `AppDelegate`에서 생성해주었습니다.

```swift
// MemoStorage.swift

final class MemoStorage {
    private let coreDataManager = CoreDataManager()
    private let dropboxManager = DropboxManager()
    // 메서드들 ..
}
```
</details>

<details>
<summary><h3>2️⃣ Core Data <-> Dropbox 동기화 시점</h3></summary>

- Core Data 를 중심으로 앱의 데이터가 관리되고 있다보니, 어느 시점에 Dropbox 에 동기화되어야 하는지 고민했습니다.
  - 불필요하게 잦은 Dropbox API 호출을 지양하고, 필요한 상황에만 호출하게 했습니다.

- `Core Data -> Dropbox` (앱이 종료되는 경로를 고민하여, 아래 2가지 경우에 Dropbox 로 데이터를 보내도록 했습니다.)
  - SceneDelegate의 `sceneDidEnterBackground()`
    - 앱을 백그라운드로 보낼 때에도 Dropbox 로 데이터를 보내도록 했습니다.
  - UITextView의 `textViewDidEndEditing()`
    - 텍스트 편집을 마치는 시점에 Core Data 에서 Dropbox 로 데이터를 보내도록 했습니다. 
- `Dropbox -> Core Data`
  - Dropbox 연동 성공시
    - Dropbox에 연동 성공하는 시점에 Dropbox 의 최신 데이터를 Core Data 에 동기화합니다.
  - 앱이 실행될 때, Dropbox 연동 정보가 true인 경우
    - `UserDefaults`에 Dropbox 연동 정보를 Bool 타입으로 저장하여, 앱이 실행될 때 해당 key에 대한 값이 true인 경우 Dropbox의 데이터를 Core Data 로 받도록 구현했습니다.

</details>
  
<details>
<summary><h3>3️⃣ Dropbox 연동을 하지 않아도 앱을 사용할 수 있게 구현</h3></summary>

- 앱을 실행할 때 바로 Dropbox 연동 여부를 묻는 것이 아니라, 버튼을 두어 `연동 여부를 사용자가 직접 선택`할 수 있도록 했습니다.

- 네트워크가 불가능한 상황에서는 `Local DB` 인 Core Data 만으로 메모를 관리하고, 추후 Dropbox 를 연동하면, 모든 메모가 동기화되도록 구현했습니다.

- 또한 연동 성공/실패 여부에 따라 `Alert` 를 띄워 사용자에게 연동 성공/실패 여부를 보여주도록 했습니다. 

</details>
  
<br>

# ⚙️ [STEP 2] Core Data 이용한 Local DB 구현

<details>
<summary><h3>1️⃣ UITextView 내부의 첫 번째 줄바꿈을 기준으로 제목(title), 내용(body) 폰트가 달라지는 기능</h3></summary>

- 제목과 내용을 시각적으로 구분할 수 있도록, `첫 번째 줄바꿈을 기준으로 폰트가 변경되는 기능`을 구현하고 싶었습니다.
  - 데이터를 가져와서 UITextView 에 보여줄 때 `attributedString` 을 활용하여 각각 다른 attribute 를 가지도록 구현했습니다.

- 사용자가 편집하는 도중에도 다이나믹하게 적용될 수 있도록, [textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String)](https://developer.apple.com/documentation/uikit/uitextviewdelegate/1618630-textview) 메서드를 사용했습니다.
  - range 의 location 과 줄바꿈 부호로 구분했을 때 얻을 수 있는 range 의 location 을 비교하여, 첫 번째 줄은 `largeTitle`, 그 다음부터는 `title2` 폰트가 적용되도록 했습니다.

```swift
func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    let textAsNSString = textView.text as NSString
    let replacedString = textAsNSString.replacingCharacters(in: range, with: text) as NSString
    let titleRange = replacedString.range(of: .lineBreak)
    
    if titleRange.location > range.location {
        textView.typingAttributes = TextAttribute.title
    } else {
        textView.typingAttributes = TextAttribute.body
    }
    
    return true
}  
```

<p align="left"><img src="https://user-images.githubusercontent.com/45652743/154242847-ad91eab8-4b11-4016-b0fe-75b647d4755b.gif" width="40%"></p>
  
</details>

<details>
<summary><h3>2️⃣ Delegation 패턴 적용</h3></summary>

- 기존에 `MemoSplitViewController` 를 거쳐 `MemoTableViewController` 와 `MemoDetailViewController` 간 소통을 도왔던 구조에서 Delegation 패턴을 적용했습니다.
  - 기존 하위 컨트롤러인 `MemoTableViewController` 가 `splitViewController` 프로퍼티를 사용하여 상위 컨트롤러를 알지 못하더라도 delegate 을 통해 필요로 하는 기능들을 사용할 수 있도록 구현했습니다.
  - 이를 통해 자식 컨트롤러가 부모 컨트롤러를 아는 부적절한 의존 관계를 제거할 수 있었습니다.

- Delegation 패턴 구현을 위해 생성한 프로토콜은 다음과 같습니다.
  - `MemoStorageManageable` → MemoStorage 의 CRUD 를 직접적으로 사용하여 데이터를 관리하는 역할
  - `MemoSplitViewManageable` → 전반적인 UISplitViewController 의 메서드나 하위 뷰컨 간 소통을 위한 역할
  - 위 두 프로토콜을 typealias 사용하여 MemoManageable 를 생성하고 delegate 의 타입으로 사용하도록 했습니다.

</details>
  
<details>
<summary><h3>3️⃣ NSManagedObjectContext 로서 newBackgroundContext() 사용</h3></summary>

- 먼저, `CoreDataManager` 라는 클래스 타입을 생성하고, 내부 프로퍼티로 `NSPersistentContainer` 를 만들고, 자주 호출될 `context` 또한 변수로 구현했습니다.

- 이때 [viewContext](https://developer.apple.com/documentation/coredata/nspersistentcontainer/1640622-viewcontext) 를 사용하지 않고 [newBackgroundContext()](https://developer.apple.com/documentation/coredata/nspersistentcontainer/1640581-newbackgroundcontext) 를 사용했습니다.
  - 이유는 viewContext 는 `main queue`를 사용하지만, newBackgroundContext 메서드로 생성한 context 는 `private queue`를 따로 생성해서 사용하기 때문입니다. 굳이 메인 스레드를 사용하며 연산 비용을 높여주고 싶지 않았습니다.

```swift
// CoreDataManager.swift

lazy var context = persistentContainer.newBackgroundContext()
private var persistentContainer: NSPersistentContainer = {
    let container = NSPersistentContainer(name: "CloudNotes")
    container.loadPersistentStores { _, error in
        if let error = error {
            fatalError("persistent stores Loading Failure : \(error)")
        }
    }
    return container
}()  
```
</details>

<details>
<summary><h3>4️⃣ 앱 최초 실행 시, 새로운 메모를 미리 생성</h3></summary>

- 앱을 최초로 실행했을 때는 저장된 메모가 없고, 만약 아이패드의 `SplitView` 환경이라면 사이드바(메모 리스트)는 비어있고, 우측의 `UITextView` 만 사용자에게 보이게 됩니다.
  - 이때 편집을 제한하지 않으면, 저장된 메모는 없지만 텍스트 입력이 가능한 상황이 생길 수 있는데요, 이는 에러를 유발할 가능성이 매우 큽니다.
  - 이러한 상황을 막기 위해, 편집을 제한하기 보다는 최초 실행 시, `1개의 새로운 메모를 미리 생성`해두는 방식을 선택했습니다.

- 메모가 텅 비어있다면, 메모 리스트의 '미리보기'에는 `"새로운 메모"`, `"추가 텍스트 없음"` placeholder 가 나타나도록 구현했습니다.

- 메모는 반드시 최소 1개 존재할 수 있도록, 마지막 메모를 삭제하려고 시도할 경우, 삭제할 수 없다는 `Alert`가 띄워집니다.

|최초 실행 시 새로운 메모 생성|마지막 메모는 삭제 불가 Alert|
|:-:|:-:|
|<img src="https://user-images.githubusercontent.com/71127966/160877281-2655318e-d1e1-4e7b-b4ac-946c4787ba37.png">|<img src="https://user-images.githubusercontent.com/71127966/160877329-c5e4a01b-9076-4d03-87ee-3a747dccf626.png">|

</details>
  
<details>
<summary><h3>5️⃣ 메모들은 lastModified 기준으로 내림차순 정렬</h3></summary>

- Memo 타입의 인스턴스 배열은 항상 마지막 편집 일자를 의미하는 `lastModified` 프로퍼티를 기준으로 내림차순 정렬되도록 했습니다.
  - 해당 데이터 배열에 접근하여 값을 변경할 때 마다 매번 정렬되도록 프로퍼티 옵저버인 `didSet`을 사용했습니다.

- 또한, 새로운 메모가 추가되면 `+ 버튼`을 비활성화 시키는 로직도 `didSet` 내부에 들어있습니다.
  - `+ 버튼`은 메모의 내용을 Core Data 에 업데이트하는 다른 메서드에서 다시 활성화됩니다.

```swift
private var memos = [Memo]() {
    didSet {
        memos.sort { $0.lastModified > $1.lastModified }
        
        let isFirstMemoEmpty = memos.first?.title == String.blank
        memoTableViewController.changeAddButtonState(disabled: isFirstMemoEmpty)
    }
}
```
</details>

<details>
<summary><h3>6️⃣ 메모 삭제에 따른 selectedIndexPath 대응 로직</h3></summary>

- `UITableView` 의 `swipeAction` 혹은 더보기 버튼을 선택하여 메모를 삭제했을 때, 현재 보여질 메모를 나타내기 위한 `selectedIndexPath` 업데이트 로직을 고민했습니다.

- selectedIndexPath 보다 앞의 indexPath 에 해당하는 메모를 지우는 경우
  - 현재 보여지는 화면이 유지되어야 하기 때문에 selectedIndexPath 의 row 를 1만큼 빼주고 업데이트

- selectedIndexPath 에 해당하는 메모를 지우는 경우
  - 데이터의 개수와 비교하여 마지막에 해당한다면 row 를 1만큼 빼주고 업데이트
  - 데이터의 개수와 비교하여 마지막이 아니라면 indexPath 를 유지하고 화면만 업데이트

- selectedIndexPath 보다 뒤의 indexPath 에 해당하는 메모를 지우는 경우
  - 기존의 화면이 보이도록 selectedIndexPath 유지

- 위의 로직을 구성하여 코드에 반영하여, 사용자가 메모를 삭제했을 때 자연스럽게 주변 메모로 이동하여 보여줄 수 있도록 구현했습니다.

</details>

<br>

# ⚙️ [STEP 1] 리스트 및 화면 UI 구현

<details>
<summary><h3>1️⃣ 다크 모드 대응</h3></summary>

- 텍스트나 버튼의 색상이 `다크 모드`에 대응할 수 있도록 만들었습니다.

- 선택된 메모의 배경색은 default 로는 짙은 회색인데요, `가시성`을 높이기 위해 `systemBlue` 색상으로 변경했습니다.

|light mode|dark mode|
|:---:|:---:|
|![](https://i.imgur.com/ACzf8p6.png)|![](https://i.imgur.com/pXxuGDa.png)|

</details>

<details>
<summary><h3>2️⃣ 키보드가 콘텐츠를 가리지 않도록 구현</h3></summary>

- `UITextView` 를 터치하여 키보드가 올라올 때 일부 콘텐츠를 가리는 현상이 있었습니다.

- `UIResponder`의 `keyboardWillShowNotification`, `keyboardWillHideNotification` notification 을 받아 키보드가 등장하고 사라질 때 실행될 메서드를 각각 구현했습니다.
  - 우선 키보드가 완전히 등장했을 때의 높이를 notification의 userInfo 를 통해 얻었습니다.
  - 이후 키보드의 높이 값을 `UITextView`의 `contentInset.bottom`에 할당하여 키보드의 높이만큼 `UITextView`의 inset을 추가해서, 콘텐츠가 가려지는 문제를 해결했습니다.

<p align="left"><img src="https://i.imgur.com/MSQX7Bt.gif" width="40%"></p>

</details>

<details>
<summary><h3>3️⃣ 멀티태스킹 모드 대응</h3></summary>

- 아이패드에서 `멀티태스킹 모드`로 진입하게 되면, `UISplitViewController`가 collapsed 되어 `single container`가 되는데요, 이때 초기 화면으로 `secondary view` 에 해당하는 MemoDetailView 가 사용자에게 먼저 보이게 되는 현상이 있었습니다.

- 이러한 현상이 문제는 아니지만, 메모의 내용이 보이는 것 보다 `primary`에 해당하는 메모 리스트인 MemoTableView 가 먼저 보이는 것이 더 자연스러울 것 같다고 판단했습니다.
  - 이에 `UISplitViewControllerDelegate`의 메서드인 [splitViewController(_:topColumnForCollapsingToProposedTopColumn:)](https://developer.apple.com/documentation/uikit/uisplitviewcontrollerdelegate/3580925-splitviewcontroller) 를 활용하여 collapsed 되었을 때 `primary view` 가 우선적으로 보이도록 구현했습니다.
  - 이 과정에서, collapsed 여부를 확인하기 위해 `UISplitViewController` 타입의 연산 프로퍼티인 `isCollapsed`를 활용했습니다.

```swift
// MARK: - UISplitViewControllerDelegate

extension MemoSplitViewController: UISplitViewControllerDelegate {
    func splitViewController(_ svc: UISplitViewController, topColumnForCollapsingToProposedTopColumn proposedTopColumn: UISplitViewController.Column) -> UISplitViewController.Column {
        return .primary
    }
}
```

<p align="left"><img src="https://i.imgur.com/wha0IMw.gif" width="40%"></p>

</details>
  
<details>
<summary><h3>4️⃣ TableView extension 으로 register, dequeueReusableCell 메서드 구현</h3></summary>

- `UITableView` 를 구성하기 위해 `cell의 identifier`를 알고 있어야 한다는 점이 부담스러울 수 있다고 판단했습니다.
  - 따라서, identifier 몰라도 cell 을 사용할 수 있도록 UITableView extension 으로 register, dequeueReusableCell 메서드를 별도 구현 후 사용했습니다.

- 아래와 같이 구현하는 경우, 두 가지 이점을 얻을 수 있습니다.
  - cell 의 identifier 를 신경쓰지 않아도 된다.
  - 반환되는 cell 이 optional 이 아니다.

```swift
extension UITableView {
    func register<T: UITableViewCell>(cellWithClass name: T.Type) {
        register(T.self, forCellReuseIdentifier: String(describing: name))
    }
    
    func dequeueReusableCell<T: UITableViewCell>(withClass name: T.Type, for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: String(describing: name), for: indexPath) as? T else {
            fatalError("cell dequeue failed")
        }
        
        return cell
    }
}  
```

</details>
