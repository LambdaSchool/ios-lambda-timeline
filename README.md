# Lambda Timeline

## Introduction

The goal of this project is to take an existing project called LambdaTimeline and add features to it throughout this sprint. 

Today you will be adding audio comments.

## Instructions

Create a new branch in the repository called `audio` or `audio/noFirebase` and work off of it from where you left off yesterday.

You're welcome to fulfill these instructions however you want. If you'd like suggestions on how to implement something, open the disclosure triangle and there are some suggestions for most of the instructions.

### Part 0 (optional): Audio UI Prototyping

If you choose to, you can prototype this audio feature and the accompanying UI. If you would rather implement it in the Timeline project to begin with, skip to part 1.

1. Create a new Xcode project for prototyping called `AudioComments`
2. Create UI that allows the user to create an audio comment. 
    1. The UI should allow the user to record, stop, cancel, and send the recording.
3. Create Table View UI that displays audio comments in a custom table view cell.
    1. The UI should allow the user to play, pause, and scrub through a recording. 
    
For inspiration, look at how the Phone app works with Voicemail, or how the Voice Memos app works.

### Part 1: Lambda Timeline Audio Integration

Integrate your custom recording UI into the Lambda Timeline project.

1. Change the `Comment` to be either a text comment or an audio comment.

    <details><summary>Comment Suggestions</summary>
    <p>

    - In the `Comment` object, change the `text`'s type to be an optional string, and create a new `audioURL: URL?` variable as well. Modify the `init?(text: ...)` to accomodate the `audioURL` and the now optional `text` string.

    </p>
    </details>

2. In the `PostController`, add the ability to create a comment with the audio data that the user records and add the comment to its post.

    <details><summary>Post Controller Suggestions</summary>
    <p>

      - Create a separate function to create a comment with the audio data.

    </p>
    </details>
3. Users should be able to create an audio comment (in addition to a text comment).
    <details><summary>Recording UI Suggestions</summary>
    <p>

      - In the `ImagePostDetailViewController`, change the `createComment` action to allow the user select whether they want to make a text comment or an audio comment, then create a new view controller with the required UI. The view controller could be presented modally or as a popover.
      
      - Alternatively, you could modify the `ImagePostDetailViewController` to hold the audio recording UI.

    </p>
    </details>
    
4. Create a new table view cell that displays at least the author of the audio comment, and a button to play the comment.

5. Implement the ability to play a comment's audio from the new audio comment cell from step 2. As you implement the `AVAudioRecorder`, remember to add a microphone usage description in the Info.plist.

## Go Further

- Add a label (if you don't have one already) to your recording UI that will show the recording time as the user is recording.
- Change the audio comment cell to display the duration of the audio, as well as show the current time the audio is at when playing.
