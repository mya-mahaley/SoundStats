# soundstats
### Contributions:
Evelyn Vo (33% Beta release, 31% overall):
- Set up connection to Spotify API
- Wrote the functions to pull user's top tracks and top chart tracks
- Created the data structures to decode JSON responses
- Set up Core Data entities to store track data
- Load and read core data from and to TrackItem objects

Sonya Pieklik (33% Beta release, 24% overall):
- Created Home Screen, Friends Feed, Settings, and Customization View Controllers
- Settings: Dark Mode/Light Mode, Change Profile Picture (it doesn’t save but it will upload a photo from your camera roll), Logout, Notification
- Spotify: Creating the statistic ranking system and comparing the two userTracks and globalTracks for similarities (still work in progress)

Mya Mahaley (33% Beta release, 44% overall):
- Created Launch Screen
- Setup Firebase
- Login with Google and Email successful
- Facebook Authentication attempted
- Switched Home Screen views to Tab Bar Controller
- Attempted Apple Music connection
- Integrated individual Storyboard Files into one.
    
### Deviations:
### Alpha Release
- Sonya was dealing with a family emergency, and will be making up for the contribution difference in the next phase
- Evelyn had two job interviews during this phase
- Due to time constraints, and several errors, the Login with Facebook button could not be implemented. We will try again in the following phase, but we are considering removing the feature because it doesn't provide any additional functionality to the app
- The Apple Music API costs $100, so we cannot use it for this project, and will be focusing on Spotify Users


### Beta Release
- Evelyn had a job interview during this phase
- We were able to go beyond our Beta release committment of displaying statistics in a basic text form. Mya fleshed out the visualizations
to be much more graphical.
- We began implementing the mood indicator stretch feature, but it is not completely fleshed out.
- We had a lot of issues getting the Spotiy API requests to work across everyone's phones.
- Core data will clear and reload the user's data everytime the Connect to Spotify button is pressed. In the next release, we will let this be triggered by a button that the user must explicitly press.
- Some default values still appear in the visualizations (mood feature, username, etc).


### Additional Note:
How to run SoundStats on your phone:
- Put your phone in developer mode
- Plug your phone into your Mac
- In XCode, choose your iPhone as your simulation device
    - Run the code
    - The app should appear on your phone. If you cannot open it, try the following;
        -  Change the bundle identifier of the app to something unique
        -  For “team”, use your personal account
        -  On your iPhone, go to Settings > General > VPN & Device Management, then trust the developer that appears there
        -  Re-run the code, you should be able to open SoundStats now
        -  When you press the “Connect to Spotify” button, you will be asked to authorize SoundStats to access your Spotify data 
        -   Once you grant access, your Spotify may begin playing music

- For the Spotify API requests to work, your Spotify email and SoundStats bundle identifier may need to be added to our Spotify developer dashboard.
- For the visualizations to load, your bundle identifier may need to be added to Placid. 
- Please email us to add these to our development tools!

