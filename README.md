# Udacity-iOS-OnTheMap

OnTheMap is an app with a map that shows information posted by other students.
The map will contain pins that show the location where other students have reported studying.
By tapping on the pin users can see a URL for something the student finds interesting.
The user will be able to add their own data by posting a string that can be reverse geocoded to a location,
and a URL.

The project is base on **Unidirectional Data Flow UIViewController**

## Requirements
- Xcode 8.3
- Swift 3.1

## About Unidirectional Data Flow UIViewController

Unidirectional Data Flow UIViewController will help to make a UIViewController
to be more testable and to improve the maintainability.
In this project, it helps to seperate the following importand concerns of a view controller

- `State`: The state of a view controller, which decides the UI of this view controller
- `Action`: The action to change the current state
- `Command`: The command is used to handle asynchronous operation and side effects
- `Reducer`: A function takes a `State` and an `Action`, acts the `Action` on the `State`
    and return a new `State` and a optional `Command` to handle side effects.
- `Store`: The place to store `State` and act `Action`

The relationships among these components is like following graph:
![Relationships](https://onevcat.com/assets/images/2017/view-controller-states.svg)
(The image if from [OneV's Den](https://onevcat.com/2017/07/state-based-viewcontroller/))



