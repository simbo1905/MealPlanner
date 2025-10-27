# User Edit Form: Diagrams

## Component Tree

```mermaid
graph TD
    MyApp[MyApp]
    MyApp --> UserEditScreen["UserEditScreen<br/>(holds userId)"]
    UserEditScreen --> AppBar["AppBar"]
    UserEditScreen --> Body["Body<br/>SingleChildScrollView"]
    UserEditScreen --> BottomNav["BottomNavigationBar<br/>_BottomButtonPanel"]
    
    AppBar --> TitlePanel["_TitlePanel<br/>(watches: editedUser, age)"]
    Body --> EditPanel["_EditPanel<br/>(watches: editedUser, age)"]
    
    TitlePanel -.watches.-> NameField["Text: name"]
    TitlePanel -.watches.-> AgeDisplay["Text: Age (computed)"]
    
    EditPanel --> NameTextField["TextField<br/>onChanged → updateName"]
    EditPanel --> DoBPicker["GestureDetector<br/>onTap → DatePicker"]
    EditPanel --> ComputedAge["Text: Computed Age"]
    
    BottomNav --> CancelBtn["Cancel Button"]
    BottomNav --> SaveBtn["Save Button"]
```

---

## Riverpod Provider Dependency Graph

```mermaid
graph LR
    Firebase["Firebase<br/>Firestore"]
    
    Firebase -->|read| fetchUser["fetchUser<br/>(userId)"]
    fetchUser -->|data| currentEditedUser["currentEditedUser<br/>(computed)"]
    
    userEditStateNotifier["userEditStateNotifier<br/>(mutable)"]
    userEditStateNotifier -->|state| currentEditedUser
    userEditStateNotifier -->|state| ageComputed["currentAge<br/>(computed)"]
    
    currentEditedUser -->|input| userSaveNotifier["userSaveNotifier<br/>(save to Firestore)"]
    
    UI["UI Components"]
    UI -->|watch| fetchUser
    UI -->|watch| currentEditedUser
    UI -->|watch| ageComputed
    UI -->|notify| userEditStateNotifier
    
    userSaveNotifier -->|reset| userEditStateNotifier
    userSaveNotifier -->|write| Firebase
```

---

## State Flow: User Interaction Sequence

```mermaid
sequenceDiagram
    participant User
    participant UI as UI Components
    participant RiverPod as Riverpod Providers
    participant Firestore
    participant Firebase as Firebase SDK<br/>(offline)
    
    User->>UI: Open edit form
    UI->>RiverPod: watch(fetchUser)
    RiverPod->>Firestore: GET users/{id}
    Firestore-->>RiverPod: User{name, dob}
    
    Note over RiverPod: fetchUser loading
    UI->>UI: Show spinner
    
    Firestore-->>RiverPod: data returned
    RiverPod->>RiverPod: initializeFromUser()
    UI->>UI: Render form
    
    User->>UI: Edit name
    UI->>RiverPod: updateName('Bob')
    RiverPod->>RiverPod: userEditStateNotifier.state updated
    RiverPod->>RiverPod: currentEditedUser re-computes
    UI->>UI: Title + TextField update
    
    User->>UI: Change DoB
    UI->>RiverPod: updateDateOfBirth(newDate)
    RiverPod->>RiverPod: userEditStateNotifier.state updated
    RiverPod->>RiverPod: currentAge re-computes
    UI->>UI: Age display updates
    
    User->>UI: Click Save
    UI->>RiverPod: userSaveNotifier.save(editedUser)
    RiverPod->>RiverPod: state = loading
    UI->>UI: Show spinner on Save btn
    
    RiverPod->>Firebase: set(users/{id}, userData)
    Firebase-->>Firebase: Queue for sync (offline ok)
    Firebase-->>Firestore: (if online) flush write
    
    Note over Firestore,Firebase: Online → write persists<br/>Offline → queued locally
    
    Firestore-->>Firebase: ack
    Firebase-->>RiverPod: Future completes
    RiverPod->>RiverPod: reset edit state
    UI->>UI: Pop screen
```

---

## Edit State Machine

```mermaid
stateDiagram-v2
    [*] --> Loading
    Loading --> Idle: fetchUser complete
    
    Idle --> Editing: user edits name/dob
    Editing --> Editing: multiple edits
    
    Editing --> Saving: user clicks Save
    Saving --> Idle: Firestore persists
    
    Editing --> Cancelled: user clicks Cancel
    Cancelled --> [*]
    
    Saving --> Error: Firestore error
    Error --> Editing: user can retry
    
    Note right of Idle
        currentEditedUser = null
        (no mutations in flight)
    End Note
    
    Note right of Editing
        currentEditedUser = User{...edits...}
        currentAge recomputes
    End Note
    
    Note right of Saving
        Firestore.set() in flight
        UI buttons disabled
    End Note
```

---

## Data Flow: Component Updates

```mermaid
graph TB
    State["userEditStateNotifier<br/>UserEditState"]
    
    State -->|name: String| Derived1["currentEditedUser<br/>User"]
    State -->|dateOfBirth: DateTime| Derived1
    
    Derived1 -->|extracted| Derived2["currentAge<br/>int"]
    
    Derived1 --> Title["_TitlePanel"]
    Derived1 --> EditPanel["_EditPanel"]
    Derived2 --> Title
    Derived2 --> EditPanel
    
    Title --> TitleText["AppBar Title<br/>name + age"]
    EditPanel --> NameInput["Name TextField"]
    EditPanel --> DoBDisplay["DoB Picker Display"]
    EditPanel --> AgeText["Computed Age Label"]
    
    User["User Input"]
    User -->|enters text| NameInput
    NameInput -->|onChanged| UpdateName["updateName()"]
    UpdateName -->|setState| State
    
    User -->|taps picker| DoBDisplay
    DoBDisplay -->|picks date| UpdateDoB["updateDateOfBirth()"]
    UpdateDoB -->|setState| State
    
    State -.watches.-> TitleText
    State -.watches.-> AgeText
    
    Note right of Title
        Stateless + ConsumerWidget
        Re-renders on watched provider change
    End Note
```

---

## Firebase + Offline Sync (Under the Hood)

```mermaid
graph TB
    subgraph App["Flutter App"]
        UI["User Edit Screen"]
        Riverpod["Riverpod"]
    end
    
    subgraph Firebase["Firebase SDK"]
        Local["Local Cache<br/>SQLite on Device"]
        Queue["Write Queue<br/>(offline buffer)"]
    end
    
    subgraph Backend["Firestore Backend"]
        Cloud["Cloud Firestore"]
    end
    
    UI -->|set(user)| Riverpod
    Riverpod -->|set() call| Firebase
    
    Firebase -->|Always<br/>persists locally| Local
    Firebase -->|Queues if offline| Queue
    
    Local -.reads from.-> UI
    
    Firebase -->|if online| Cloud
    Cloud -->|ack| Firebase
    Firebase -->|clears queue| Queue
    
    Note over Firebase
        Firebase SDK handles all sync logic
        App just calls await set()
        Returns when write is accepted
        (queued or persisted)
    End Note
```

---

## Testing Flow

```mermaid
graph LR
    A["Unit Tests<br/>test/providers/"] --> Age["Age calculation"]
    A --> JSON["User.fromJson<br/>roundtrip"]
    
    B["Integration Tests<br/>integration_test/"] --> Load["Load user display"]
    B --> Edit["Edit name/dob"]
    B --> Save["Save persists"]
    B --> Cancel["Cancel discards"]
    
    C["Test Harness<br/>flutter_test_server.sh"] --> Chrome["Launch Chrome"]
    C --> Emulator["Start emulator"]
    C --> Monitor["Monitor logs"]
    
    Age -->|fast| CI["CI Pipeline"]
    JSON -->|fast| CI
    Load -->|slower| CI
    Edit -->|slower| CI
    Save -->|slower| CI
    Cancel -->|slower| CI
```
