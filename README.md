# Welcome to my Bank Application with UI.

This is a submodule git.

Related to (MAIN REPO): https://github.com/Michael679089/CS319_Flutter-Application-Development

Things to remembers:
1. main.dart is the DRIVER Class.
2. bank_logic.dart holds all the variables.

# Updates:
1. Separated the different pages into different files.
2. Put all the pages in the "pages" folder.
3. Currently the log_out function is crashing the application.
    1. Alright I fixed the code. Basically I just did this:

    ```dart
    void _logout(BuildContext context) {
        // Reset global state
        loggedIn = false;

        // Navigate back to the login/setup page and remove all previous routes
        Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const PinSetupOrLoginPage()),
        (route) => false,
        );
    }
    ```

    2. and then replaced the AppBar IconButton part with this:

    ```dart
    IconButton(
        icon: const Icon(Icons.logout),
        tooltip: "Logout",
        onPressed: () => _logout(context),
    ),
    ```

    the bank_application UI should be working as expected.