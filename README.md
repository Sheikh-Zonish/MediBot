# MediBot – iOS Medication Safety and Adherence Application

## Overview

MediBot is an iOS application developed using SwiftUI to support medication safety and adherence. The system allows users to browse medications, check interactions, manage reminders, and review safety-related insights.

This repository contains the frontend of the project. The application depends on a separate FastAPI backend.

---

## How to Run the Project

### Prerequisites

To run this project, the following are required:

* macOS
* Xcode installed
* iOS Simulator
* Python 3 installed
* The backend repository downloaded locally

Backend repository:
https://github.com/Sheikh-Zonish/Medibot-backend

---

### Step 1: Run the Backend

Before launching the iOS application, the backend server must be started.

1. Open Terminal
2. Navigate to the backend folder:

```bash
cd Medibot-backend
```

3. Start the FastAPI server:

```bash
python3 -m uvicorn main:app --reload
```

4. Confirm that the backend is running at:

```text
http://127.0.0.1:8000
```

---

### Step 2: Run the iOS Application

1. Open the frontend project in Xcode:

```text
MediBot.xcodeproj
```

2. Select an iPhone simulator

3. Build and run the project in Xcode

---

## Important Configuration Note

The application is configured to communicate with the backend using the following base URL:

```text
http://127.0.0.1:8000
```

Therefore:

* the backend must be running before the application is launched
* the application should be tested using the iOS Simulator
* if a physical device is used, the API base URL would need to be changed accordingly

---

## How to Use the Application

After launching the app:

1. Open the **Medications** section
2. Select a medication from the list
3. Choose relevant lifestyle factors such as alcohol, caffeine, or supplements
4. Run the interaction check
5. Review the result and severity level
6. Navigate to **Safety History** to view previous checks
7. Navigate to **Insights** to review adherence and safety information
8. Open **Profile** to access reminder settings, privacy information, and application details

---

## Main Features

* Medication browsing, searching, and filtering
* Medication interaction checking
* Daily reminder configuration
* Safety history tracking
* Adherence insights dashboard
* Profile and settings management

---

## Technology Stack

* Swift
* SwiftUI
* URLSession
* Codable
* FastAPI backend integration

---

## Project Structure

```text
MediBot/
├── App/
├── Views/
├── Models/
├── Networking/
└── Components/
```

---

## Backend Dependency

This application is the frontend component of a full-stack project. It depends on the backend for:

* retrieving medication data
* checking interactions
* logging doses
* loading safety history
* loading insights

---

## API Endpoints Used

* GET /medications
* POST /check-interaction
* GET /insights
* GET /safety-checks
* GET /home/upcoming
* POST /log-dose
* DELETE /log-dose/latest

---

## Limitations

* The backend must be run locally
* The project uses prototype/demo data
* No authentication is included

---

## Author

Zonish Sheikh
