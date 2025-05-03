/*
    RingAI Agents - GUI Application
    Author: Azzeddine Remmal
    Date: 2025
*/

# Load the GUI library
load "guilib.ring"


# Load the main window
load "src/gui/main_window.ring"

# Start the application
oApp = new QApp {
    ? applicationState()
    # Create and show the main window
    oWindow = new MainWindow()
    exec()
     ? applicationState()
}
