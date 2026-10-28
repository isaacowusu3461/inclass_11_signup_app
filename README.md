# Midnight Guestbook – Activity 11

## Project Information

- **Course:** CSC 6360 – Mobile App Development
- **Activity:** 11 – The Haunted Signup Mansion
- **Student:** Isaac Owusu
- **Track:** Graduate
- **Extension:** Task C – The Guarded Crypt

## Project Description

For Activity 11, I extended my signup app from Activity 10 into a three-screen Flutter application. I decided to call it Midnight Guestbook and gave it a simple Halloween theme with purple colors and a few animations. The app starts with a welcome screen, takes the user to a signup form, and displays a personalized success screen after the form is completed correctly. I kept the validation and local signup coach features from Activity 10 and added a birth-date picker, loading animation, and confetti. For the graduate extension, I chose Task C, which focuses on handling situations that could cause problems with navigation or form submission.

## Project Structure

```text
lib/
├── main.dart
└── screens/
    ├── welcome_screen.dart
    ├── signup_screen.dart
    └── success_screen.dart
```

I separated the screens into different files to keep the code organized. The `main.dart` file only sets up the app theme and opens the welcome screen.

## Features

### Welcome Screen

The welcome screen displays the Midnight Guestbook title using a typewriter animation from the `animated_text_kit` package. I used a dark-purple background and an orange button to give it a simple Halloween look. When the user clicks "Enter the Mansion," the app opens the signup screen using `Navigator.push()`. This allows the user to return to the welcome screen using the Back button.

### Signup Screen

I reused the form validation from Activity 10. The form checks that the name is not empty, the email has a valid format, and the password contains at least eight characters. I also kept the password visibility toggle and password coach. The password coach gives feedback based on the length of the password. For Activity 11, I added a birth-date picker. Users must select a date before submitting the form, and the picker does not allow future dates. After a valid submission, the app displays a loading indicator for two seconds before opening the success screen.

### Local Signup Coach

The local signup coach from Activity 10 is still included. It displays preset password tips stored directly in the application. I kept the normal, error, and empty-data test modes, along with the Retry button. The feature does not use the information entered in the signup form or connect to an external AI service.

### Success Screen

After a valid signup, the app opens the success screen and displays a personalized welcome message using the name entered in the form. I used the `confetti` package to display a short celebration animation when the screen opens. There is also a button that takes the user back to the welcome screen. I used `Navigator.pushReplacement()` when moving from the signup screen to the success screen. This removes the signup screen from the navigation stack so the user cannot return to the completed form using the Back button.

## Graduate Extension – Task C: The Guarded Crypt

For my graduate extension, I chose Task C because I wanted to make the app handle unexpected user actions more safely. I implemented three protections.

**1. Empty name protection**

The success screen checks whether the name passed to it is empty. If there is no valid name, the app redirects the user to the welcome screen instead of displaying an incomplete welcome message.

**2. Double-submission protection**

I added a `_submitting` variable that checks whether a signup is already being processed. Once the user submits a valid form, the button becomes disabled. The submission method also checks `_submitting` before starting, so another call cannot start a second submission.

**3. Safe navigation during loading**

The app waits two seconds before navigating to the success screen. During that delay, the user might leave the signup screen. I used `if (!mounted) return;` after the delay to make sure the screen still exists before navigating. This prevents the app from trying to use a screen that has already been removed.

## Testing

I tested the application on my Android emulator, including the form validation, screen navigation, animations, and graduate extension.

All 15 test cases passed.

| Test Case | Result | Status |
|---|---|---|
| Welcome screen | Animated title and entrance button appeared | Pass |
| Back navigation | Back returned to the welcome screen | Pass |
| Empty form | Required-field validation messages appeared | Pass |
| Invalid email | Invalid email was rejected | Pass |
| Short password | Password under 8 characters was rejected | Pass |
| Password visibility | Password could be shown and hidden | Pass |
| Birth-date picker | Calendar opened and future dates were unavailable | Pass |
| Valid signup | Loading indicator appeared before navigation | Pass |
| Personalized greeting | Success screen displayed the entered name | Pass |
| Confetti animation | Confetti played on the success screen | Pass |
| Success navigation | Back did not return to the completed form | Pass |
| Double submission | Repeated taps did not create multiple success screens | Pass |
| Leaving during loading | No crash or unwanted navigation occurred | Pass |
| Empty success name | App redirected to the welcome screen | Pass |
| Local signup coach | Normal tips, errors, empty data, and retry worked | Pass |

### Testing Reflection

I tested the normal signup process first to make sure the three screens worked together. I then tried submitting the form with empty fields, an invalid email, and a short password. The validation messages appeared correctly, and the app only moved to the success screen when the form was valid. I also tested the graduate extension by trying to submit the form more than once, leaving the screen during loading, and passing an empty name to the success screen. All three cases behaved as expected. The app also kept the local signup coach functionality from Activity 10 without any issues.


## Navigation and State Management

I used `Navigator.push()` to move from the welcome screen to the signup screen because the user should be able to go back if they change their mind.

After a successful signup, I used `Navigator.pushReplacement()` instead. This removes the signup screen from the navigation stack and prevents the user from returning to the completed form.

The signup information is managed using `TextEditingController` objects inside the signup screen. I dispose of these controllers when the screen is removed to release their resources.

The user's name is passed to the success screen through its constructor. I only pass the name because the success screen does not need the email or password.

## Design Choices and Trade-offs

I kept the design simple because I wanted the main features to be easy to use and understand. I used a purple theme, a typewriter animation on the welcome screen, and confetti on the success screen to make the app a little different without adding too much code. One trade-off I made was using a fixed two-second delay to simulate signup processing. It makes the loading state easy to demonstrate, but a real signup application would normally wait for a response from a server. If I were improving the app, I would replace the simulated delay with an actual signup process and show an error message if the request failed.

## Challenges and What I Learned

One part I had to think about was what happens when a user leaves the signup screen while the app is still loading. Since the delay is asynchronous, the code could continue running even after the screen is removed. I handled this by checking `mounted` before navigating. I also learned more about how Flutter navigation works. Using `push()` and `pushReplacement()` helped me understand how screens are added to or removed from the navigation stack. Another useful part was separating the application into different files. It made the code easier to follow because each screen has its own responsibility.

## Limitations

The application is still a signup demonstration and does not create real accounts or store user information. The password coach only checks password length, so it does not guarantee that a password is secure. The local signup coach also uses preset tips rather than a real AI service.

## How to Run the Application

Make sure Flutter is installed and an Android emulator or physical device is available. Open a terminal in the project folder and run:

```bash
flutter pub get
flutter run
```

## Dependencies

The application uses two additional Flutter packages:

- `animated_text_kit` – For the animated welcome title.
- `confetti` – For the celebration animation on the success screen.

These packages can be installed using:

```bash
flutter pub add animated_text_kit
flutter pub add confetti
```

## Building the APK

To build the release APK, run:

```bash
flutter build apk --release
```

The APK will be generated at:

`build/app/outputs/flutter-apk/app-release.apk`

If a debug APK is needed, run:

```bash
flutter build apk --debug
```

The debug APK will be generated at:

`build/app/outputs/flutter-apk/app-debug.apk`
