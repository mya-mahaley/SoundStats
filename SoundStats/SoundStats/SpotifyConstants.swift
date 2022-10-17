import Foundation

let accessTokenKey = "access-token-key"
let redirectUri = URL(string:"soundstats://")!
let spotifyClientId = "f5e3ab4b386d4d0fad1841a3e60cb806"
let spotifyClientSecretKey = "3881360eaef64507b701dad23847a013"

/*
Scopes let you specify exactly what types of data your application wants to
access, and the set of scopes you pass in your call determines what access
permissions the user is asked to grant.
For more information, see https://developer.spotify.com/web-api/using-scopes/.
*/
let scopes: SPTScope = [
                            .userReadEmail, .userReadPrivate,
                            .userReadPlaybackState, .userModifyPlaybackState, .userReadCurrentlyPlaying,
                            .streaming, .appRemoteControl,
                            .playlistReadCollaborative, .playlistModifyPublic, .playlistReadPrivate, .playlistModifyPrivate,
                            .userLibraryModify, .userLibraryRead,
                            .userTopRead, .userReadPlaybackState, .userReadCurrentlyPlaying,
                            .userFollowRead, .userFollowModify,
                        ]
let stringScopes = ["streaming","user-read-email", "user-read-private",
                    "user-read-playback-state", "user-modify-playback-state", "user-read-currently-playing",
                    "streaming", "app-remote-control",
                    "playlist-read-collaborative", "playlist-modify-public", "playlist-read-private", "playlist-modify-private",
                    "user-library-modify", "user-library-read",
                    "user-top-read", "user-read-playback-position", "user-read-recently-played",
                    "user-follow-read", "user-follow-modify"]


