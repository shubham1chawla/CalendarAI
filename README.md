# WellnessAI

WellnessAI is an iOS app that focuses on your personal & personal well-being and an AI companion for mental health and happiness, powered by ChatGPT.

> Please note that the algorithms used by the application to measure the heart and respiratory rates are for demonstration purposes only.

## Technologies

![iOS](https://img.shields.io/badge/iOS-000000?style=for-the-badge&logo=ios&logoColor=white)
![Swift](https://img.shields.io/badge/swift-F54A2A?style=for-the-badge&logo=swift&logoColor=white)
![ChatGPT](https://img.shields.io/badge/chatGPT-74aa9c?style=for-the-badge&logo=openai&logoColor=white)

## Features

This section covers the primary functionality of the application.

![WellnessAI Introduction](/mockups/01.jpg)

### Prompts Fine-tuning & Optimization

The application sources information from the user's calendar, health information, and device's location to fetch nearby places using [Google Nearby Places API](https://developers.google.com/maps/documentation/places/web-service/search-nearby) and weather using [Open Weather API](https://openweathermap.org/api).

![WellnessAI Fine-tuning Prompts](/mockups/02.jpg)

### Calendar-related Suggestions

The application generates suggestions from the calendar and considers various use cases, including no upcoming events, most recent events, and busy calendar suggestions. All these suggestions focus on the user's well-being and self-care.

![WellnessAI Calendar Suggestions](/mockups/03.jpg)

### Built-in Health Tracking

WellnessAI uses a built-in health tracking feature to measure users' heart and respiratory rates and record their symptoms.

![WellnessAI Health](/mockups/04.jpg)

### Heart Rate Measurement

Using the device's camera, the application records a 45-second video of the user's index finger and measures their heart rate.

![WellnessAI Heart Rate Measurement](/mockups/05.jpg)

### Respiratory Rate Measurement

The application uses the gyroscope to measure the user's respiratory rate.

![WellnessAI Respiratory Rate Measurement](/mockups/06.jpg)

### Health-related Suggestions

WellnessAI generates suggestions based on the health information the user saves. These shall include stale or no health information, any health-related calendar event reminder, persistent symptoms, and abnormal heart or respiratory rates. The application uses ChatGPT to classify abnormal heart and respiratory rates.

![WellnessAI Health Suggestions](/mockups/07.jpg)

## Setup

Once you built the application on your device, you must open the Settings app on the iPhone and find the WellnessAI application. You'll need to add the Google Nearby Places, Open Weather, and Open AI API keys for the application to function as indicated.