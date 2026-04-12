# Sampatti Bazar 🏠
### The Ultimate Real Estate & Comprehensive Service Ecosystem

Sampatti Bazar is a state-of-the-art Flutter application that redefines the property-seeking experience by merging a high-end real estate marketplace with a robust suite of legal and construction services. Built for reliability, speed, and precision, Sampatti Bazar serves as a vertical marketplace that handles everything from finding a home to managing its construction and legal compliance.

---

## 🚀 Vision & Objective

The real estate journey is often fragmented. Users find a property in one app, look for a lawyer in another, and source construction materials elsewhere. **Sampatti Bazar** solves this by providing:
- **Pinpoint Location Accuracy**: Moving away from vague addresses to precise coordinate-based navigation.
- **Service Integration**: A unified desk for legal agreements and construction tracking.
- **Premium User Experience**: A physics-based, animated UI that feels fluid and responsive.

---

## 🏗️ Architectural Overview

The project follows a **Feature-First Architecture**, ensuring high scalability and maintainability. This structure isolates features into independent modules, making it easy to test and extend.

### 📁 Directory Structure
- `lib/core`: The backbone of the app.
  - `router`: Centralized navigation using `GoRouter` and `StatefulNavigationShell`.
  - `theme`: A custom design system utilizing Material 3, custom extensions, and fine-tuned dark mode palettes.
  - `providers`: Global state providers (Theme, Locale, Feature Flags).
  - `utils`: Responsive design utilities, loggers, and coordinate handlers.
- `lib/features`: Feature-specific logic, UI, and data layers.
  - `auth`: Firebase-powered Phone and Email authentication logic.
  - `properties`: The core marketplace, property details, and map interaction.
  - `services`: The Construction and Legal service sub-modules.
  - `chat`: Real-time messaging infrastructure.
- `lib/shared`: Reusable widgets like Buttons, Inputs, and specialized Card components.

---

## 💎 Feature Deep-Dive

### 1. Advanced Property Marketplace
The property engine is designed for high engagement:
- **High-Precision Maps**: Every property listing is tied to exact `latitude` and `longitude` coordinates. Users can launch Google Maps with a single tap to get accurate turn-by-turn directions.
- **Dynamic Detail Views**: Property detail screens include synchronized owner profiles, trust scores, and dynamic deal counts.
- **Smart Filtering**: Filter properties by Sell/Rent, Price range, Property type, and precise location area names.

### 2. Construction Service Marketplace
A dedicated portal for building your dream project:
- **Material Sourcing**: Browse and order construction materials like Cement, Bricks, and Steel directly through the app.
- **Contractor Registry**: Connect with verified contractors and construction experts.
- **Project Tracking**: A comprehensive dashboard to monitor the progress of your ongoing construction services.

### 3. Legal & Documentation Desk
Simplifying property paperwork:
- **Digital Agreements**: Create and sign rent agreements or sale deeds within the app using the integrated `Signature` package.
- **Expert Consultations**: Hire legal professionals for property verification and title checks.
- **Document Management**: Securely manage your property-related files.

### 4. Financial Suite
Tools to help you make informed decisions:
- **EMI Calculator**: A detailed mortgage calculator with dynamic principal and interest breakdowns.
- **Valuation Tool**: Get estimated market values for properties based on current trends and precise location data.

---

## 🛠️ Technical Stack & Implementation

### **Frontend & Framework**
- **Flutter (Dart)**: Leverages the latest stable SDK features.
- **Material 3**: Full adoption of M3 design principles with custom branding.
- **Responsive Framework**: Custom logic (`responsive.dart`) ensures the UI scales perfectly from small Android devices to large iOS tablets.

### **State Management & Data Handling**
- **Riverpod**: Used for its robust, compile-time safe dependency injection and state management.
- **Repository Pattern**: Abstracted data layers for Auth, User Profiles, and Properties, allowing for easy swapping between Mock and Firebase data.

### **Backend & Cloud Integration**
- **Firebase Auth**: Supports both high-security Phone OTP and traditional Email/Password flows.
- **Cloud Firestore**: Real-time NoSQL database for property listings, user data, and service tracking.
- **Firebase Storage**: For high-resolution property images and legal document storage.
- **Crashlytics & Analytics**: Real-time error tracking and user behavior insights to drive performance optimizations.

---

## 🎨 Design System

**Sampatti Bazar** prioritizes "120Hz Feel" UI:
- **Typography**: The **Poppins** font family is used exclusively to maintain a professional yet approachable aesthetic.
- **Navigation**: Utilizes `google_nav_bar` for a modern, pill-shaped animated bottom navigation experience.
- **Interactive Components**: 
  - Glassmorphic effects in detail screens.
  - Physics-based spring animations for button presses.
  - Subtle micro-interactions for tab switching.
- **Accessibility**: High-contrast dark mode and localized labels (English/Hindi) ensure inclusivity.

---

## 🔧 Setup & Development Guide

### Prerequisites
- Flutter SDK (Latest Stable)
- Android Studio / VS Code
- Firebase Project setup

### Installation Steps
1. **Initialize Workspace**:
   ```bash
   flutter pub get
   ```
2. **Setup Firebase**:
   - Ensure `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) are in their respective directories.
   - Run `flutterfire configure` to sync options.
3. **Build Runners** (if applicable):
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```
4. **Environment Check**:
   ```bash
   flutter analyze
   ```

---

## 📅 Development Context & History
This project has undergone significant UI/UX refinement, including:
- **Coordinate Migration**: Shifting from string-based addresses to high-precision coordinate navigation.
- **Animation Overhaul**: Replacing static transitions with physics-based motion for a premium feel.
- **Feature Convergence**: Merging legal and construction services into a single marketplace ecosystem.

---
*Created by Shivansh Jasathi - Building the future of Real Estate in India.*
