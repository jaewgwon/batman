# Batman - Batch Manager 🦇

[English](#english) | [한국어](#korean) | [日本語](#japanese)

<img src="assets/batman_logo.png" alt="Batman Logo" width="200"/>

---

<a id="english"></a>
## English

### Overview
Batman is a Windows-only batch file manager that allows you to easily manage, run, and monitor your batch files. With a clean and intuitive interface, you can add your favorite batch files, run them individually or all at once, and see their running status in real-time.

### Features
- **Simple Management**: Add, remove, and organize your batch files
- **One-Click Execution**: Run batch files with a single click
- **Status Monitoring**: See which batch files are running (green) or stopped (red)
- **Run All**: Execute all batch files at once
- **Persistent Storage**: Your batch file list is saved between sessions

### Installation
1. Make sure you have Flutter installed on your system
2. Clone this repository
3. Install dependencies:
   ```
   flutter pub get
   ```
4. Run the application:
   ```
   flutter run -d windows
   ```

### Usage
1. Click the "+" button in the app bar to add batch files
2. The batch files will appear in the list with their status indicator
3. Click the play button to run a batch file or the stop button to terminate it
4. Use the floating action button to run all batch files at once

### Technology Stack
- Flutter (Windows)
- Dart
- process_run
- file_picker
- shared_preferences
- window_size

### Development
To run tests:
```
flutter test
```

[Back to top ↑](#batman---batch-manager-)

---

<a id="korean"></a>
## 한국어

### 개요
Batman은 Windows 전용 배치 파일 관리자로, 배치 파일을 쉽게 관리, 실행 및 모니터링할 수 있습니다. 깔끔하고 직관적인 인터페이스를 통해 자주 사용하는 배치 파일을 추가하고, 개별적으로 또는 한 번에 모두 실행하며, 실시간으로 실행 상태를 확인할 수 있습니다.

### 주요 기능
- **간편한 관리**: 배치 파일 추가, 제거 및 정리
- **원클릭 실행**: 한 번의 클릭으로 배치 파일 실행
- **상태 모니터링**: 실행 중인 배치 파일(녹색) 또는 중지된 배치 파일(빨간색) 상태 확인
- **일괄 실행**: 모든 배치 파일 한 번에 실행
- **설정 저장**: 앱을 재시작해도 배치 파일 목록 유지

### 설치 방법
1. Flutter가 시스템에 설치되어 있는지 확인
2. 이 저장소 복제
3. 의존성 설치:
   ```
   flutter pub get
   ```
4. 애플리케이션 실행:
   ```
   flutter run -d windows
   ```

### 사용 방법
1. 앱 바의 "+" 버튼을 클릭하여 배치 파일 추가
2. 상태 표시기와 함께 목록에 배치 파일 표시
3. 재생 버튼을 클릭하여 배치 파일 실행 또는 중지 버튼으로 종료
4. 플로팅 액션 버튼을 사용하여 모든 배치 파일 한 번에 실행

### 기술 스택
- Flutter (Windows)
- Dart
- process_run
- file_picker
- shared_preferences
- window_size

### 개발
테스트 실행:
```
flutter test
```

[맨 위로 ↑](#batman---batch-manager-)

---

<a id="japanese"></a>
## 日本語

### 概要
Batmanは、Windowsのみのバッチファイル管理ツールであり、バッチファイルを簡単に管理、実行、監視することができます。クリーンで直感的なインターフェイスにより、お気に入りのバッチファイルを追加し、個別または一度にすべて実行し、リアルタイムで実行状態を確認できます。

### 主な機能
- **シンプルな管理**: バッチファイルの追加、削除、整理
- **ワンクリック実行**: 一回のクリックでバッチファイルを実行
- **状態監視**: 実行中のバッチファイル（緑）または停止中のバッチファイル（赤）を表示
- **一括実行**: すべてのバッチファイルを一度に実行
- **永続的な保存**: セッション間でバッチファイルリストを保存

### インストール方法
1. システムにFlutterがインストールされていることを確認
2. このリポジトリをクローン
3. 依存関係をインストール:
   ```
   flutter pub get
   ```
4. アプリケーションを実行:
   ```
   flutter run -d windows
   ```

### 使用方法
1. アプリバーの「+」ボタンをクリックしてバッチファイルを追加
2. バッチファイルが状態インジケーターと共にリストに表示される
3. 再生ボタンをクリックしてバッチファイルを実行するか、停止ボタンを押して終了
4. フローティングアクションボタンを使用してすべてのバッチファイルを一度に実行

### 技術スタック
- Flutter (Windows)
- Dart
- process_run
- file_picker
- shared_preferences
- window_size

### 開発
テストを実行するには:
```
flutter test
```

[トップに戻る ↑](#batman---batch-manager-)
