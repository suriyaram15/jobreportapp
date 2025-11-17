# Job Report App

A comprehensive time-tracking and reporting application built with Flutter. This app enables users to efficiently report their day-to-day tasks, track working hours, and generate detailed reports.

## Live Demo

You can view the live deployed application here: **[https://jobreportapp-1.onrender.com/](https://jobreportapp-1.onrender.com/)**

## Features

- **User Authentication:** Secure login and registration system using email and password.
- **Automated Time Tracking:** Automatically tracks active, idle, and on-meeting time.
- **Task Management:** Create, manage, and complete daily tasks.
- **Idle Time Detection:** Automatically detects and logs periods of user inactivity.
- **Offline & Sleep Recovery:** Gracefully handles unexpected browser closures and sleep mode, ensuring no data is lost.
- **Hourly Prompts:** Reminds users to log their activity every hour.
- **Detailed Reporting:**
  - In-app report screen with data visualizations (pie chart) of time distribution.
  - Granular data table of all work periods.
  - JSON and email export capabilities.
- **Logout Summary:** Generates a comprehensive daily report upon logout, comparing worked hours to a standard 8-hour day.
- **Persistent Data:** User data is securely stored and persists across sessions.

## Project Setup

To set up and run this project locally, follow these steps:

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) installed.
- A code editor like [VS Code](https://code.visualstudio.com/) with the Flutter extension.
- A modern web browser like Chrome.

### Installation

1.  **Clone the repository:**
    ```sh
    git clone https://github.com/suriyaram15/jobreportapp.git
    cd jobreportapp
    ```

2.  **Enable Web Support:**
    This project requires Flutter's web support. If you haven't enabled it yet, run:
    ```sh
    flutter create . --platforms web
    ```

3.  **Get Dependencies:**
    Fetch all the required packages.
    ```sh
    flutter pub get
    ```

4.  **Run the App:**
    Run the application on a local development server. The app will open in your default browser.
    ```sh
    flutter run -d chrome
    ```

## Building for Production

To create an optimized production build for the web, run the following command:

```sh
flutter build web
```

This will generate the necessary static files in the `build/web` directory, which can then be deployed to any static web hosting service.
