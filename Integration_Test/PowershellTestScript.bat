@echo off

REM Start screen recording asynchronously on Android
echo Starting screen recording on Android...
start "" adb shell screenrecord  /sdcard/Test_record.mp4

REM Run Flutter integration tests in the background
echo Running Flutter integration tests...
start "" flutter test integration_test.dart

REM Wait for a brief moment to allow the tests to start running
timeout /t 180

REM Wait for the test to complete before stopping the recording
echo Test completed, stopping screen recording...
adb shell pkill -l2 screenrecord

REM wait till recording stops
timeout /t 10

REM Pull the video to the local machine
echo Pulling video to local machine...
adb pull /sdcard/Test_record.mp4 .

REM Delete the recording file from the device
adb shell rm /sdcard/Test_record.mp4

echo Test completed. Recording saved as test_recording.mp4.
pause
