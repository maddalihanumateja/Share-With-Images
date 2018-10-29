# Share-With-Images
AR iOS app for a vision-based tangible interface. This extends work by my advisor, [Dr. Amanda Lazar](https://amandalazar.net/index.html), in supporting [Digital Social Sharing for People with Dementia](https://amandalazar.net/papers/2017_p2149-lazar.pdf). The idea for the app is, as the name suggests, to use images to indicate actions, objects, and other categories of inputs that can be used to trigger apps on your iPhone through a simple communication model. I've used image-recognition functionality provided by ARKit 2.0 for this and provided a template that will allow me, or other developers, to adapt this communication model for the needs of the end users (See Issues and Pull requests for discussions, thoughts, sketches, and referred publications on topics like [communication](https://github.com/maddalihanumateja/Share-With-Images/issues/16), [AI assistants](https://github.com/maddalihanumateja/Share-With-Images/issues/22) etc.). It needs to be mentioned that this app hasn't been tested by any users. So its a good prototype to present to a focus group and break apart in discussions of what it does well and what it fails at for a certain population (e.g. Older adults might actually hate it, I dont know).

This [issue](https://github.com/maddalihanumateja/Share-With-Images/issues/6) and its related pull-requests talk about the currently working functionality: Saying you want to send an email (desired action as input) and to whom (person as input). Its hardcoded for a [Gmail image](https://raw.githubusercontent.com/maddalihanumateja/Share-With-Images/master/Share%20With%20Images/Assets.xcassets/Sample%20Images/gmail.imageset/gmail.png), and [Obama image](https://raw.githubusercontent.com/maddalihanumateja/Share-With-Images/master/Share%20With%20Images/Assets.xcassets/Sample%20Images/obama.imageset/obama.jpeg). As an example of sequential presentation of inputs, showing the image of the gamil app first followed by obama gives a different response to the reverse case. Try it out. This can also be changed to a non-sequential presentation of inputs as well.

A question you might have is why I'm even using AR specific libraries at all, why not just OpenCV? Well, they seemed to have good set of marker tracking libraries which I could easy use when developing for mobile. This is why I was initially interested in ARKit. I also had this idea of being able to create personalized AR spaces for memory-related activites (Display old photographs on the wall, preserve models of objects that hold meaning ...). These could, once again, use a lot of feedback from the community of older adults I planned to design this app for. But I definitely see potential for AR/VR in enabling shared experiences for a multigenerational userbase that includes older adults and this app is a practise exercise.

Requirements

 - Tech:
   - Device with iOS 11.3 or greater
   - XCode 9.3 or greater to build the code (with ARKit)
  
 - Knowledge: Ability to read, understand and/or write iOS app code. Don't worry if you're a novice or outright beginner. I've used and adapted apple tutorial code myself to write this app. Go through the following tutorials and links in the given order and you should be able to understand my code
   - [Get started with Swift](https://developer.apple.com/library/content/documentation/Swift/Conceptual/Swift_Programming_Language/index.html#//apple_ref/doc/uid/TP40014097)
   - [Get started with iOS apps](https://developer.apple.com/library/content/referencelibrary/GettingStarted/DevelopiOSAppsSwift/index.html#//apple_ref/doc/uid/TP40015214-CH2-SW1): This gives a good intro to XCode as well
   - [Build your first AR Experience](https://developer.apple.com/documentation/arkit/building_your_first_ar_experience)
   - [Image recognition using ARKit and other related examples](https://developer.apple.com/documentation/arkit/recognizing_images_in_an_ar_experience)
   There are swift playgrounds in most of these links. Download them and try playing around with the code.
   
Expected Future Work:

 - Work on the UI (the look and feel) (Dont want it to resemble the tutorial app too much :))
 - Work on an AI component (See issue #16).
 - The big one: extend to 3D objects and not just images as inputs. ~~Maybe ARKit already has an object detection function implemented somewhere?~~ Edit: The latest release of ARKit has 3D object scanning and detection capabilites (It currently doesn't seem too robust). We could now use, for example, a watch associated with a friend's memory to represent that friend for our tangible interface.
 - Unknown ...
 - Extend to android and desktop? (I've used ARKit in this one. Maybe there could be an equivalent version that uses some open source AR SDK?)
   
